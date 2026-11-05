make_figures <- function(a, config) {
  colors <- stats::setNames(a$regions$color, a$regions$region_code)
  labels <- stats::setNames(gsub("\n", " ", a$regions$region_de), a$regions$region_code)
  source <- config$source
  figures <- list()
  export <- function(plot, name, question, height = 8) {
    out <- save_figure(plot, name, config, height = height)
    out[, question := question]
    figures[[length(figures) + 1L]] <<- out
  }
  world <- data.table::copy(a$world[order(year)])
  ends <- world[c(1L, .N)]
  ends[, label := paste0(fmt(below_3), " %")]
  p <- ggplot(world, aes(year, below_3)) +
    geom_line(color = "#315F87", linewidth = 1.2) +
    geom_point(data = ends, color = "#315F87", size = 3) +
    geom_text(data = ends, aes(label = label), vjust = -1.1, hjust = c(0, 1), size = 5,
              fontface = "bold", color = "#315F87") +
    scale_x_continuous(breaks = c(1990, 2000, 2010, config$end_year), expand = expansion(mult = c(.02, .02))) +
    scale_y_continuous(limits = c(0, ceiling(max(world$below_3) / 10) * 10), labels = percent_labels) +
    labs(title = paste0("Extreme Armut weltweit seit ", config$start_year),
         subtitle = "Anteil unter 3 internationalen Dollar pro Tag, Kaufkraft von 2021",
         x = NULL, y = "Anteil der Weltbevölkerung",
         caption = paste0(source, "\nWeltwerte sind modellierte Aggregate. Der dargestellte Zeitraum endet ", config$end_year, ".")) + analysis_theme()
  export(p, "01_weltweiter_verlauf", "Wie hat sich extreme Armut weltweit verändert?")

  regional <- data.table::copy(a$regional)
  regional[, region := factor(region_de, levels = a$regions$region_de)]
  endpoints <- regional[year == config$end_year]
  endpoints[, label := paste0(fmt(below_3), " %")]
  beginnings <- regional[year == config$start_year]
  beginnings[, label := paste0(fmt(below_3), " %")]
  upper <- ceiling(max(regional$below_3) / 10) * 10
  p <- ggplot(regional, aes(year, below_3)) +
    geom_line(aes(color = region_code), linewidth = .9) +
    geom_point(data = endpoints, aes(color = region_code), size = 2) +
    geom_text(data = endpoints, aes(label = label, color = region_code), hjust = 1, vjust = -1,
              size = 3.8, fontface = "bold") +
    geom_text(data = beginnings, aes(label = label, color = region_code), hjust = 0, vjust = -1,
              size = 3.5) +
    facet_wrap(~ region, ncol = 4) + scale_color_manual(values = colors, guide = "none") +
    scale_x_continuous(breaks = c(1990, 2005, 2024), limits = c(config$start_year, config$end_year + 1)) +
    scale_y_continuous(limits = c(0, upper + 4), breaks = seq(0, upper, 20), labels = percent_labels) +
    labs(title = "Die Weltregionen entwickeln sich unterschiedlich",
         subtitle = paste0("Extreme Armut unter 3 internationalen Dollar pro Tag, ", config$start_year, "–", config$end_year),
         x = NULL, y = "Anteil der Bevölkerung",
         caption = paste(source, "\nGemeinsame Skalen. Veröffentlichte Regionalaggregate, keine ungewichteten Ländermittelwerte.")) + analysis_theme()
  export(p, "02_regionale_verlaeufe", "Welche regionalen Unterschiede verdeckt die Weltlinie?", 8.5)

  countries <- data.table::copy(a$countries)
  cases <- data.table::copy(a$cases)
  cases[, point_label := paste0(country_de, "\n", start_year, "–", end_year)]
  cases[, label_hjust := ifelse(start_pct > 72, 1.05, -.08)]
  p <- ggplot(countries, aes(start_pct, end_pct)) +
    geom_abline(slope = 1, intercept = 0, color = "#8D969F", linetype = "dashed", linewidth = .6) +
    geom_point(aes(color = region_code), size = 2.8, alpha = .7) +
    geom_point(data = cases, shape = 21, fill = "white", color = "#283545", size = 4, stroke = .9) +
    geom_label(data = cases, aes(label = point_label, hjust = label_hjust), vjust = -.45,
               size = 3.5, linewidth = 0, fill = "white", lineheight = 1.05) +
    scale_color_manual(values = colors, breaks = a$regions$region_code, labels = labels) +
    scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = percent_labels) +
    scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = percent_labels) +
    coord_equal() + guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
    labs(title = "Armutsquoten zu Beginn und Ende des Länderzeitraums",
         subtitle = "Unter der Diagonalen: Rückgang. Darüber: Anstieg. Markiert sind die drei Fallbeispiele.",
         x = paste0("Armutsquote zu Beginn (nahe ", config$country_start, ")"),
         y = paste0("Armutsquote am Ende (nahe ", config$country_end, ")"),
         caption = paste0(source, "\n", nrow(countries), " Länder. Fenster ±", config$tolerance,
                          " Jahre, mindestens ", config$min_span, " Jahre Zeitspanne und ", config$min_surveys,
                          " Erhebungen. Tatsächliche Intervalle unterscheiden sich.")) + analysis_theme()
  export(p, "03_laendervergleich", "Welche Veränderungen zeigen vergleichbare Länderreihen?", 9)

  cases[, panel := paste0(country_de, "\n", case_role)]
  series <- data.table::copy(a$case_surveys)
  series[, panel := factor(cases$panel[match(country_code, cases$country_code)], levels = cases$panel)]
  regional_series <- data.table::copy(a$case_regions)
  regional_series[, panel := factor(cases$panel[match(country_code, cases$country_code)], levels = cases$panel)]
  cases[, panel := factor(panel, levels = panel)]
  p <- ggplot() +
    geom_rect(data = cases, aes(xmin = start_year, xmax = end_year, ymin = -Inf, ymax = Inf), fill = "#F1F4F6") +
    geom_line(data = regional_series, aes(year, below_3, color = "Region (modelliert)"), linewidth = .9) +
    geom_line(data = series[spell_n > 1], aes(year, poverty_pct,
              group = interaction(country_code, spell), color = "Land (Erhebungen)"), linewidth = .8) +
    geom_point(data = series, aes(year, poverty_pct, color = "Land (Erhebungen)"), size = 1.9) +
    facet_wrap(~ panel, nrow = 1) +
    scale_color_manual(values = c("Land (Erhebungen)" = "#315F87", "Region (modelliert)" = "#9A9FA5")) +
    scale_x_continuous(breaks = c(1990, 2005, 2024), limits = c(config$start_year, config$end_year)) +
    scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = percent_labels) +
    labs(title = "Ausgewählte Länder im regionalen Vergleich",
         subtitle = "Die Auswahl folgt der Veränderung und ihrer Abweichung vom Regionaltrend.",
         x = NULL, y = "Anteil unter 3 int. Dollar pro Tag",
         caption = paste(source, "\nHinterlegt ist das tatsächliche Vergleichsintervall. Länderlinien unterbrechen bei Vergleichbarkeitsbrüchen.\nDie Verläufe beschreiben Zusammenhänge und belegen keine Ursachen.")) + analysis_theme()
  export(p, "04_laender_im_regionalen_vergleich", "Wie verlaufen die ausgewählten Fälle gegenüber ihrer Region?")

  coverage <- merge(a$coverage_counts, a$regions[, .(region_code, region_de)], by = "region_code")
  coverage[, method := factor(method, levels = c("Einkommen", "Konsum", "Beide", "Keine aktuelle Erhebung"))]
  coverage[, label := ifelse(share_pct >= 7, paste0(fmt(share_pct, 0), " %"), "")]
  coverage[, ink := ifelse(method == "Keine aktuelle Erhebung", "#283545", "white")]
  region_n <- a$coverage[, .N, by = region_code]
  axis_labels <- paste0(a$regions$region_de, "\n(n = ", region_n$N[match(a$regions$region_code, region_n$region_code)], " Länder)")
  coverage[, region := factor(region_code, levels = rev(a$regions$region_code))]
  p <- ggplot(coverage, aes(region, share_pct, fill = method, group = method)) +
    geom_col(width = .65, position = position_stack(reverse = TRUE)) +
    geom_text(aes(label = label, color = ink), position = position_stack(vjust = .5, reverse = TRUE), size = 3.8) +
    scale_color_identity() +
    scale_fill_manual(values = c("Einkommen" = "#315F87", "Konsum" = "#A0523A", "Beide" = "#77764C",
                                 "Keine aktuelle Erhebung" = "#D9DEE3"), drop = FALSE) +
    scale_x_discrete(labels = stats::setNames(axis_labels, a$regions$region_code)) +
    scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = percent_labels, expand = c(0, 0)) +
    coord_flip() + guides(fill = guide_legend(nrow = 1)) +
    labs(title = "Welche Erhebungsarten stehen zur Verfügung?",
         subtitle = paste0("Jüngstes nationales Erhebungsjahr je Land innerhalb von ", config$coverage_start, "–", config$end_year),
         x = NULL, y = "Anteil der im Datensatz vertretenen Länder",
         caption = paste(source, "\nJedes Land zählt einmal. 'Beide' bedeutet Einkommen und Konsum im selben jüngsten Jahr.\nDie Grafik beschreibt die Verfügbarkeit im Kursdatensatz, nicht sämtliche nationalen Erhebungen.")) + analysis_theme()
  export(p, "05_erhebungsarten", "Wie ist die verfügbare Datengrundlage regional verteilt?", 9)

  summary <- data.table::copy(a$method_summary)
  pairs <- data.table::copy(a$method_pairs)
  summary[, country := factor(country_code, levels = summary$country_code)]
  pairs[, country := factor(country_code, levels = summary$country_code)]
  pair_labels <- paste0(summary$country_de, "  (n = ", summary$n_pairs, "; ", summary$start_year, "–", summary$end_year, ")")
  p <- ggplot(pairs, aes(difference_pp, country)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "#78848E", linewidth = .6) +
    geom_point(position = position_jitter(width = 0, height = .08, seed = 19), color = "#929DA8", size = 2, alpha = .7) +
    geom_point(data = summary, aes(median_pp, country), shape = 18, color = "#315F87", size = 4) +
    scale_y_discrete(labels = stats::setNames(pair_labels, summary$country_code)) +
    scale_x_continuous(labels = function(x) fmt(x), expand = expansion(mult = c(.08, .08))) +
    labs(title = "Einkommen und Konsum ergeben unterschiedliche Quoten",
         subtitle = "Graue Punkte: Land-Jahr-Paare. Blaue Rauten: Median je Land. Grenze: 3 int. Dollar pro Tag.",
         x = "Einkommensquote minus Konsumquote (Prozentpunkte)", y = NULL,
         caption = paste0(source, "\n", nrow(pairs), " Paare aus ", nrow(summary), " Ländern, ", config$start_year, "–", config$end_year,
                          ". Positive Werte: Einkommensquote höher. Negative Werte: Konsumquote höher.\nGleiches Land und Jahr garantieren keine identische Stichprobe. Kein isolierter Methodeneffekt.")) +
    analysis_theme() + theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(color = "#DFE4E8", linewidth = .3))
  export(p, "06_einkommen_konsum_differenzen", "Wie unterscheiden sich Quoten innerhalb derselben Länder und Jahre?", 10)

  if (isTRUE(config$include_thresholds)) {
    thresholds <- data.table::rbindlist(list(
      a$world[, .(series = "Welt", year, below_3, below_4_20, below_8_30)],
      a$regional[, .(series = region_de, year, below_3, below_4_20, below_8_30)]))
    thresholds <- data.table::melt(thresholds, id.vars = c("series", "year"), variable.name = "threshold", value.name = "share")
    thresholds[, series := factor(series, levels = c("Welt", a$regions$region_de))]
    thresholds[, threshold := factor(threshold, levels = c("below_3", "below_4_20", "below_8_30"),
                                       labels = c("3 int. Dollar", "4,20 int. Dollar", "8,30 int. Dollar"))]
    write_table(thresholds, "thresholds_plot_data")
    p <- ggplot(thresholds, aes(year, share, color = threshold)) + geom_line(linewidth = .75) +
      facet_wrap(~ series, ncol = 4) +
      scale_color_manual(values = c("3 int. Dollar" = "#8C4354", "4,20 int. Dollar" = "#B47728", "8,30 int. Dollar" = "#315F87")) +
      scale_x_continuous(breaks = c(1990, 2005, 2024)) +
      scale_y_continuous(limits = c(0, 100), breaks = c(0, 50, 100), labels = percent_labels) +
      labs(title = "Wie unterscheiden sich die Verläufe bei höheren Grenzen?",
           subtitle = "Anteil unter 3, 4,20 und 8,30 internationalen Dollar pro Tag, Kaufkraft von 2021",
           x = NULL, y = "Anteil der Bevölkerung",
           caption = paste0(source, "\nWelt und Regionen, ", config$start_year, "–", config$end_year,
                            ". Modellierte Aggregate. Niveaus und Veränderungen sind getrennt zu beurteilen.")) + analysis_theme()
    export(p, "07_alternative_armutsgrenzen", "Verändern höhere Armutsgrenzen die beobachteten Trends?", 8.5)
  }
  manifest <- data.table::rbindlist(figures)
  data.table::fwrite(manifest, "output/results/figure_manifest.csv", bom = TRUE)
  manifest
}
