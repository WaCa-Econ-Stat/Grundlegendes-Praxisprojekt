make_figures <- function(a, config) {
  ink <- "#315F87"
  accent <- "#934354"
  muted <- "#A7B1BA"
  source <- config$source
  figures <- list()
  headline <- function(x) paste(vapply(strsplit(x, "\n", fixed = TRUE)[[1]], function(line) {
    paste(strwrap(line, width = 76), collapse = "\n")
  }, character(1)), collapse = "\n")
  pp_label <- function(x) paste0(ifelse(x > 0, "+", ifelse(x < 0, "−", "")), fmt(abs(x)), " PP")
  export <- function(plot, name, question, takeaway, explanation, height = 8) {
    plot <- plot + labs(title = headline(takeaway))
    out <- save_figure(plot, name, config, height = height)
    out[, `:=`(question = question, takeaway = gsub("\n", " ", takeaway, fixed = TRUE), explanation = explanation,
               section = "Armut und Messung")]
    figures[[length(figures) + 1L]] <<- out
  }

  # 1. One line and its two endpoints support the worldwide decline.
  world <- data.table::copy(a$world[order(year)])
  ends <- world[c(1L, .N)]
  ends[, label := paste0(fmt(below_3), " %")]
  direction <- if (tail(world$below_3, 1) < world$below_3[1]) "sank" else "stieg"
  takeaway <- paste0("Der Anteil der Weltbevölkerung in extremer Armut\n", direction, " von ",
                    fmt(world$below_3[1]), " auf ", fmt(tail(world$below_3, 1)), " %")
  p <- ggplot(world, aes(year, below_3)) +
    geom_line(color = ink, linewidth = 1.4) +
    geom_point(data = ends, color = ink, size = 3.5) +
    geom_text(data = ends, aes(label = label), vjust = -1.1, hjust = c(0, 1),
              size = 5.5, fontface = "bold", color = ink) +
    scale_x_continuous(breaks = sort(unique(c(config$start_year, 2000, 2010, config$end_year))),
                       expand = expansion(mult = c(.02, .02))) +
    scale_y_continuous(limits = c(0, ceiling(max(world$below_3) / 10) * 10), labels = percent_labels) +
    labs(subtitle = paste0(config$start_year, "–", config$end_year,
                           ": Anteil unter 3 internationalen Dollar pro Tag, Kaufkraft von 2021"),
         x = NULL, y = "Anteil der Weltbevölkerung",
         caption = paste(source, "\nWeltwerte sind modellierte Aggregate.")) + analysis_theme()
  export(p, "01_weltweiter_verlauf", "Wie hat sich extreme Armut weltweit verändert?", takeaway,
         "Die Linie zeigt den weltweiten Rückgang. Die hervorgehobenen Endpunkte geben dessen Größenordnung an. Weltwerte sind modelliert.")

  # 2. Two time points on one axis replace seven separate time-series panels.
  regional <- merge(a$regional[year == config$start_year, .(region_code, start_pct = below_3)],
                    a$regional[year == config$end_year, .(region_code, end_pct = below_3)], by = "region_code")
  regional <- merge(regional, a$regions[, .(region_code, region_de)], by = "region_code")
  setorder(regional, end_pct)
  regional[, region := factor(region_code, levels = region_code)]
  regional[, highlight := ifelse(region_code == "SSF", accent, ink)]
  top <- regional[which.max(end_pct)]
  takeaway <- if (top$region_code == "SSF") {
    paste0("Subsahara-Afrika hatte ", config$end_year, " mit ", fmt(top$end_pct), " % die höchste regionale Armutsquote")
  } else paste0("Die höchste regionale Armutsquote lag ", config$end_year, " bei ", fmt(top$end_pct), " %")
  p <- ggplot(regional, aes(y = region)) +
    geom_segment(aes(x = start_pct, xend = end_pct, yend = region), color = "#CDD3D9", linewidth = 1.6) +
    geom_point(aes(start_pct, shape = as.character(config$start_year)), color = muted, size = 3.8, stroke = 1.2) +
    geom_point(aes(end_pct, shape = as.character(config$end_year), color = highlight), size = 3.8) +
    geom_text(aes(start_pct, label = paste0(fmt(start_pct), " %")), vjust = -1.1, color = "#78838D", size = 3.9) +
    geom_text(aes(end_pct, label = paste0(fmt(end_pct), " %"), color = highlight), vjust = 1.9, size = 4, fontface = "bold") +
    scale_color_identity() +
    scale_shape_manual(values = setNames(c(1, 16), as.character(c(config$start_year, config$end_year)))) +
    scale_y_discrete(labels = setNames(regional$region_de, regional$region_code), expand = expansion(add = .65)) +
    scale_x_continuous(limits = c(-2, ceiling(max(regional$start_pct, regional$end_pct) / 10) * 10 + 3),
                       breaks = seq(0, 100, 10), labels = percent_labels) +
    labs(subtitle = paste0("Armutsquoten der sieben Weltregionen, ", config$start_year, " und ", config$end_year),
         x = "Anteil unter 3 int. Dollar pro Tag", y = NULL,
         caption = paste(source, "\nOffene Kreise: Ausgangsjahr. Gefüllte Kreise: Endjahr. Veröffentlichte, modellierte Regionalwerte.")) +
    analysis_theme() + theme(panel.grid.major.y = element_blank(),
                            panel.grid.major.x = element_line(color = "#DFE4E8", linewidth = .3),
                            legend.position = "top")
  write_table(regional[, .(region_code, region_de, start_pct, end_pct)], "regional_endpoints_plot_data")
  export(p, "02_regionale_verlaeufe", "Wo bleibt die regionale Armutsquote besonders hoch?", takeaway,
         "Der Vergleich zeigt Ausgangs- und Endwerte auf einer gemeinsamen Skala. Subsahara-Afrika ist hervorgehoben, weil dort am Ende des Zeitraums die höchste der sieben Regionalquoten liegt.", 8.5)

  # 3. Direct signed changes answer the selected-country comparison without a diagonal.
  cases <- data.table::copy(a$cases)
  cases[, label := paste0(country_de, "\n", start_year, "–", end_year)]
  setorder(cases, change_pp)
  cases[, country := factor(country_code, levels = rev(country_code))]
  cases[, color := ifelse(change_pp > 0, accent, ink)]
  cases[, value_label := pp_label(change_pp)]
  falling <- cases[change_pp < 0]
  rising <- cases[change_pp > 0]
  takeaway <- if (nrow(falling) && nrow(rising)) {
    paste0("Die Armutsquote sank in ", falling$country_de[1], " und stieg in ", rising$country_de[1])
  } else "Die ausgewählten Länder unterscheiden sich im Ausmaß ihrer Armutsveränderung"
  p <- ggplot(cases, aes(change_pp, country)) +
    geom_vline(xintercept = 0, color = "#77848F", linewidth = .6) +
    geom_col(aes(fill = color), width = .5) + scale_fill_identity() +
    geom_text(aes(label = value_label, hjust = ifelse(change_pp >= 0, -.12, 1.12)),
              size = 5, fontface = "bold", color = "#283545") +
    scale_y_discrete(labels = setNames(cases$label, cases$country_code)) +
    scale_x_continuous(expand = expansion(mult = c(.23, .23))) +
    labs(subtitle = "Drei anhand der Daten ausgewählte Länder. Blau: Rückgang. Rot: Anstieg.",
         x = "Veränderung der Armutsquote (Prozentpunkte)", y = NULL,
         caption = paste0(source, "\nDrei Fälle aus ", nrow(a$countries),
                          " vergleichbaren Länderreihen. Die tatsächlichen Zeiträume stehen bei den Ländern.\nAbsolute Veränderungen, keine jährlichen Raten. Die Auswahl ist keine vollständige weltweite Rangliste.")) +
    analysis_theme() + theme(panel.grid.major.y = element_blank(),
                            panel.grid.major.x = element_line(color = "#DFE4E8", linewidth = .3),
                            axis.text.y = element_text(size = 13))
  write_table(cases[, .(country_code, country_de, start_year, end_year, start_pct, end_pct, change_pp)], "country_changes_plot_data")
  export(p, "03_laendervergleich", "Wie unterschiedlich entwickelten sich die ausgewählten Länder?", takeaway,
         "Ein Balken entspricht der Veränderung eines Landes. Links von null liegt ein Rückgang, rechts ein Anstieg. Die Zeiträume unterscheiden sich und sind deshalb direkt an den Ländern angegeben.")

  # 4. A single country illustrates an opposite regional trend.
  focus <- a$cases[opposite_trend == TRUE & annual_change_pp > 0][order(-abs(deviation_pp_year))]
  if (!nrow(focus)) focus <- a$cases[order(-abs(deviation_pp_year))]
  focus <- focus[1]
  focus_code <- focus$country_code
  comparison_start <- focus$start_year
  comparison_end <- focus$end_year
  national <- a$case_surveys[country_code == focus_code & year >= comparison_start & year <= comparison_end]
  reference <- a$case_regions[country_code == focus_code & year >= comparison_start & year <= comparison_end]
  region_label <- if (focus$region_code == "SSF") "Subsahara-Afrika" else "Weltregion"
  lines <- rbindlist(list(national[, .(year, share = poverty_pct, series = focus$country_de, kind = "Land")],
                          reference[, .(year, share = below_3, series = region_label, kind = "Region")]))
  ends <- lines[order(year), .SD[.N], by = kind]
  ends[, label := paste0(series, ": ", fmt(share), " %")]
  ends[, label_y := share]
  if (abs(diff(ends$share)) < 8) {
    ends[, label_y := share + ifelse(share == max(share), 2, -2)]
  }
  if (focus$annual_change_pp > 0 && focus$regional_annual_change_pp < 0) {
    takeaway <- paste0("In ", focus$country_de, " stieg die Armut entgegen dem Regionaltrend")
  } else takeaway <- paste0("Die Armutsentwicklung in ", focus$country_de, " wich vom Regionaltrend ab")
  span <- comparison_end - comparison_start
  p <- ggplot(lines, aes(year, share, color = kind)) +
    geom_line(aes(group = kind), linewidth = 1.15) +
    geom_point(data = lines[kind == "Land"], size = 3) +
    geom_segment(data = ends, aes(x = comparison_end, xend = comparison_end + span * .035,
                                 y = share, yend = label_y), linewidth = .5) +
    geom_text(data = ends, aes(x = comparison_end + span * .05, y = label_y, label = label),
              hjust = 0, fontface = "bold", size = 4.5) +
    scale_color_manual(values = c(Land = accent, Region = "#7E8994"), guide = "none") +
    scale_x_continuous(limits = c(comparison_start - span * .025, comparison_end + span * .48),
                       breaks = sort(unique(round(seq(comparison_start, comparison_end, length.out = 5))))) +
    scale_y_continuous(limits = c(0, ceiling((max(lines$share) + 5) / 10) * 10), labels = percent_labels) +
    labs(subtitle = paste0("Armutsquote im tatsächlichen Vergleichszeitraum ", comparison_start, "–", comparison_end),
         x = NULL, y = "Anteil unter 3 int. Dollar pro Tag",
         caption = paste(source, "\nLand: nationale Erhebungen einer vergleichbaren Reihe. Region: modelliertes Aggregat im selben Zeitraum.")) + analysis_theme()
  write_table(lines, "countertrend_plot_data")
  export(p, "04_laender_im_regionalen_vergleich", "Kann sich ein Land entgegen seiner Region entwickeln?", takeaway,
         paste0("Das Beispiel konzentriert sich auf ", focus$country_de, ". Beide Linien verwenden denselben Zeitraum. ",
                if (focus$opposite_trend) "Die nationale Reihe und das Regionalaggregat bewegen sich in entgegengesetzte Richtungen." else
                  "Die nationale Reihe und das Regionalaggregat unterscheiden sich im Ausmaß ihrer Veränderung."))

  # 5. Two regions give a concrete, readily legible contrast in survey concepts.
  coverage <- merge(a$coverage_counts[region_code %in% c("ECS", "SSF")],
                    a$regions[, .(region_code, region_de)], by = "region_code")
  method_levels <- c("Einkommen", "Konsum", "Beide", "Keine aktuelle Erhebung")
  coverage[, method := factor(method, levels = method_levels)]
  coverage[, label := ifelse(share_pct >= 8, paste0(fmt(share_pct, 0), " %"), "")]
  coverage[, text_color := ifelse(method == "Keine aktuelle Erhebung", "#283545", "white")]
  coverage[, region := factor(region_code, levels = c("SSF", "ECS"))]
  region_n <- coverage[, .(n = region_n[1]), by = region_code]
  region_labels <- setNames(paste0(c("Europa und Zentralasien", "Subsahara-Afrika"), "\n(n = ",
                                   region_n$n[match(c("ECS", "SSF"), region_n$region_code)], " Länder)"), c("ECS", "SSF"))
  takeaway <- "In Europa und Zentralasien überwiegen Einkommensdaten,\nin Subsahara-Afrika Konsumdaten"
  p <- ggplot(coverage, aes(region, share_pct, fill = method, group = method)) +
    geom_col(width = .48, position = position_stack(reverse = TRUE)) +
    geom_text(aes(label = label, color = text_color), position = position_stack(vjust = .5, reverse = TRUE),
              size = 5, fontface = "bold") +
    scale_color_identity() +
    scale_fill_manual(values = c(Einkommen = ink, Konsum = "#A0523A", Beide = "#77764C",
                                 "Keine aktuelle Erhebung" = "#D9DEE3"), drop = TRUE) +
    scale_x_discrete(labels = region_labels, expand = expansion(add = .6)) +
    scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25), labels = percent_labels, expand = c(0, 0)) +
    coord_flip() +
    labs(subtitle = paste0("Jüngstes verfügbares nationales Erhebungsjahr je Land, ", config$coverage_start, "–", config$end_year),
         x = NULL, y = "Anteil der im Datensatz vertretenen Länder",
         caption = paste(source, "\nZwei Regionen verdeutlichen den Unterschied. Jedes Land zählt einmal. Grau: keine Erhebung im betrachteten Fenster.\nDie vollständige Übersicht aller sieben Regionen steht in coverage_counts.csv.")) +
    analysis_theme() + theme(axis.text.y = element_text(size = 13))
  write_table(coverage[, .(region_code, method, n, region_n, share_pct)], "coverage_focus_plot_data")
  export(p, "05_erhebungsarten", "Wie unterscheiden sich die verfügbaren Erhebungsarten?", takeaway,
         "Die Balken zeigen einen deutlichen regionalen Unterschied der verfügbaren Daten. Ein pauschaler Vergleich aller Einkommens- mit allen Konsumwerten würde zugleich unterschiedliche Länder vergleichen.")

  # 6. One signed bar per country replaces the cloud of individual year pairs.
  summary <- data.table::copy(a$method_summary)
  summary[, country := factor(country_code, levels = country_code)]
  summary[, color := ifelse(median_pp > 0, ink, "#A0523A")]
  summary[, label := pp_label(median_pp)]
  income_higher <- sum(summary$median_pp > 0)
  takeaway <- paste0("In ", income_higher, " von ", nrow(summary),
                    " Ländern ist die Einkommensquote im Median höher")
  p <- ggplot(summary, aes(median_pp, country)) +
    geom_vline(xintercept = 0, color = "#77848F", linewidth = .6) +
    geom_col(aes(fill = color), width = .63) + scale_fill_identity() +
    geom_text(aes(label = label, hjust = ifelse(median_pp >= 0, -.12, 1.12)), size = 3.7) +
    scale_y_discrete(labels = setNames(paste0(summary$country_de, " (n = ", summary$n_pairs, ")"), summary$country_code)) +
    scale_x_continuous(expand = expansion(mult = c(.2, .18))) +
    labs(subtitle = "Ein Balken pro Land: Median der Jahresdifferenzen. Positive Werte bedeuten eine höhere Einkommensquote.",
         x = "Unterschied der Armutsquoten (Prozentpunkte)", y = NULL,
         caption = paste0(source, "\n", nrow(a$method_pairs), " Land-Jahr-Paare. n gibt die verfügbaren Vergleichsjahre je Land an.\nUnterschiedliche Befragungen verhindern die Interpretation als isolierten Methodeneffekt. Einzelwerte stehen in method_pairs.csv.")) +
    analysis_theme() + theme(panel.grid.major.y = element_blank(),
                            panel.grid.major.x = element_line(color = "#DFE4E8", linewidth = .3))
  write_table(summary[, .(country_code, country_de, n_pairs, start_year, end_year, median_pp)], "method_medians_plot_data")
  export(p, "06_einkommen_konsum_differenzen", "Welche Richtung haben die beobachteten Methodenunterschiede?", takeaway,
         paste0("Jedes Land erhält einen Balken. Er fasst die Differenzen seiner verfügbaren Jahrespaare durch den Median zusammen. Rechts liegt eine höhere Einkommensquote, links eine höhere Konsumquote. Der Befund gilt für diese ", nrow(summary), " Vergleichsländer."), 9.5)

  # 7. Three world lines answer the threshold question without eight panels.
  if (isTRUE(config$include_thresholds)) {
    thresholds <- melt(world[, .(year, below_3, below_4_20, below_8_30)], id.vars = "year",
                       variable.name = "threshold", value.name = "share")
    thresholds[, threshold := factor(threshold, levels = c("below_3", "below_4_20", "below_8_30"),
                                      labels = c("3 int. Dollar", "4,20 int. Dollar", "8,30 int. Dollar"))]
    last <- thresholds[year == config$end_year]
    first <- thresholds[year == config$start_year]
    last[, label := paste0(threshold, ": ", fmt(share), " %")]
    first[, label := paste0(fmt(share), " %")]
    changes <- merge(first[, .(threshold, before = share)], last[, .(threshold, after = share)], by = "threshold")
    takeaway <- if (all(changes$after < changes$before)) "Die weltweite Armutsquote sank auch bei höheren Grenzen" else
      "Die Armutsgrenze verändert die gemessene weltweite Entwicklung"
    span <- config$end_year - config$start_year
    p <- ggplot(thresholds, aes(year, share, color = threshold)) +
      geom_line(linewidth = 1.15) + geom_point(data = last, size = 2.5) +
      geom_text(data = first, aes(label = label), hjust = 0, vjust = -1, size = 4) +
      geom_text(data = last, aes(x = config$end_year + span * .025, label = label), hjust = 0,
                fontface = "bold", size = 4.5) +
      scale_color_manual(values = c("3 int. Dollar" = accent, "4,20 int. Dollar" = "#B47728", "8,30 int. Dollar" = ink), guide = "none") +
      scale_x_continuous(limits = c(config$start_year, config$end_year + span * .3),
                         breaks = sort(unique(c(config$start_year, 2000, 2010, config$end_year)))) +
      scale_y_continuous(limits = c(0, ceiling((max(thresholds$share) + 5) / 10) * 10), labels = percent_labels) +
      labs(subtitle = paste0("Weltbevölkerung unter drei Armutsgrenzen, ", config$start_year, "–", config$end_year,
                             ", Kaufkraft von 2021"),
           x = NULL, y = "Anteil der Weltbevölkerung",
           caption = paste(source, "\nAlle drei Reihen verwenden dieselbe Datenversion und denselben Zeitraum. Weltwerte sind modelliert.")) + analysis_theme()
    write_table(thresholds, "threshold_world_plot_data")
    export(p, "07_alternative_armutsgrenzen", "Bleibt die Richtung des Welttrends bei höheren Grenzen bestehen?", takeaway,
           "Alle drei Linien gehen über den gesamten Zeitraum zurück. Die höhere Grenze erfasst zugleich einen wesentlich größeren Anteil der Bevölkerung. Der Vergleich konzentriert sich auf die Weltreihe.")
  }
  figures <- c(figures, make_living_conditions_figures(a, config))
  manifest <- rbindlist(figures)
  fwrite(manifest, "output/results/figure_manifest.csv", bom = TRUE)
  manifest
}
