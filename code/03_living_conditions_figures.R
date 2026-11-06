# Original ggplot implementations inspired by the linked OWID charts.
# All observations still come from the fixed course dataset and roterFaden prep.
make_living_conditions_figures <- function(a, config) {
  ink <- "#315F87"
  accent <- "#934354"
  figures <- list()
  ref_scatter <- "https://ourworldindata.org/grapher/extreme-poverty-vs-child-mortality"
  ref_economy <- "https://ourworldindata.org/grapher/gini-coefficient-vs-gdp-per-capita-pip"
  ref_groups <- "https://ourworldindata.org/grapher/child-mortality-by-income-level-of-country"
  ref_line <- "https://ourworldindata.org/grapher/child-mortality"
  source_pip <- "Daten: Weltbank PIP, Kursdatensatz. Eigene Auswertung; Gestaltung inspiriert von Our World in Data."
  source_health <- "Daten: Weltbank PIP und UN IGME/Gapminder via OWID, Kursdatensatz. Eigene Auswertung."
  period <- paste0("Um ", config$indicator_year, " (±", config$indicator_tolerance, " Jahre)")
  number_labels <- function(z) fmt(z, if (all(abs(z - round(z)) < 1e-8, na.rm = TRUE)) 0L else 1L)
  region_colors <- setNames(a$regions$color, a$regions$region_code)
  region_names <- setNames(c("Ostasien und Pazifik", "Südasien", "Subsahara-Afrika",
                             "Nahost, Nordafrika,\nAfghanistan und Pakistan", "Lateinamerika und Karibik",
                             "Europa und Zentralasien", "Nordamerika"), a$regions$region_code)
  owid_theme <- function() {
    theme_minimal(base_size = 14, base_family = "sans") + theme(
      text = element_text(color = "#555555"),
      plot.title = element_text(family = "serif", size = 25, face = "bold", color = "#303030",
                                lineheight = 1.1, margin = margin(b = 10)),
      plot.subtitle = element_text(size = 13, lineheight = 1.2, margin = margin(b = 20)),
      plot.caption = element_text(size = 9, hjust = 0, lineheight = 1.2, margin = margin(t = 18)),
      plot.title.position = "plot", plot.caption.position = "plot",
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#DDDDDD", linewidth = .35, linetype = "dashed"),
      panel.grid.major.x = element_blank(), axis.title = element_text(size = 12),
      axis.text = element_text(size = 11), axis.line = element_line(color = "#BBBBBB", linewidth = .3),
      axis.ticks = element_blank(), strip.text = element_text(size = 13, face = "bold", hjust = 0),
      panel.spacing = grid::unit(1.5, "lines"), legend.title = element_text(size = 11, face = "bold"),
      legend.text = element_text(size = 10.5), legend.position = "right",
      legend.key.height = grid::unit(.65, "cm"), plot.margin = margin(20, 24, 18, 18),
      plot.background = element_rect(fill = "white", color = NA))
  }
  caption <- function(source, note) paste(source, paste(strwrap(note, width = 155), collapse = "\n"), sep = "\n")
  headline <- function(text) {
    lines <- strwrap(text, width = 69)
    if (length(lines) == 2L && nchar(lines[2L]) < 24L) {
      words <- strsplit(text, " ", fixed = TRUE)[[1L]]
      split <- which.min(abs(cumsum(nchar(words) + 1L) - (nchar(text) + 1L) / 2))
      lines <- c(paste(words[seq_len(split)], collapse = " "), paste(words[-seq_len(split)], collapse = " "))
    }
    paste(lines, collapse = "\n")
  }
  export <- function(plot, name, question, takeaway, explanation, reference, design_note,
                     height = 8, section = "Gesundheit und Kindersterblichkeit") {
    out <- save_figure(plot + labs(title = headline(takeaway)), name, config, height = height)
    out[, `:=`(question = question, takeaway = takeaway, explanation = explanation, section = section,
               owid_reference = reference, design_note = design_note)]
    figures[[length(figures) + 1L]] <<- out
  }
  fills <- function() scale_fill_manual(values = region_colors, labels = region_names, name = "Weltbankregion")
  colors <- function() scale_color_manual(values = region_colors, labels = region_names, guide = "none")
  population_sizes <- function() scale_size_area(max_size = 15, breaks = c(1e7, 1e8, 1e9),
                                               labels = c("10 Mio.", "100 Mio.", "1 Mrd."), name = "Bevölkerung")
  bubble_guides <- function() guides(fill = guide_legend(order = 1, override.aes = list(size = 4, alpha = 1)),
                                     size = guide_legend(order = 2, override.aes = list(fill = "#ADB8C1", alpha = .8)))
  case_points <- function(x) x[country_code %in% a$cases$country_code]
  selected <- copy(a$indicator_snapshot)
  selected[, country_de := country_labels(country_name)]

  # 8. OWID-style economic scatter: region colors and population-sized circles.
  x <- copy(selected[is.finite(reporting_gdp) & reporting_gdp > 0][order(-reporting_pop)])
  takeaway <- if (rank_association(x$reporting_gdp, x$pct_below_3) < -.3)
    "Länder mit höherem BIP pro Kopf haben meist weniger extreme Armut" else
    "BIP pro Kopf und Armutsquote zeigen keinen einheitlichen Zusammenhang"
  p <- ggplot(x, aes(reporting_gdp, pct_below_3)) +
    geom_point(aes(fill = region_code, size = reporting_pop), shape = 21, color = "white", stroke = .3, alpha = .8) +
    geom_label(data = case_points(x), aes(label = country_de, color = region_code), size = 3.6,
               hjust = -.08, vjust = -.5, fill = "white", linewidth = 0, show.legend = FALSE) +
    fills() + colors() + population_sizes() + bubble_guides() +
    scale_x_log10(breaks = c(300, 1000, 3000, 10000, 30000, 100000), labels = function(z) fmt(z, 0),
                  expand = expansion(mult = c(.04, .08))) +
    scale_y_continuous(limits = c(0, 100), labels = percent_labels) +
    labs(subtitle = paste0(period, " · ", nrow(x), " Länder · Punktfläche entspricht der Bevölkerung"),
         x = "BIP pro Kopf und Jahr (US-Dollar von 2015; logarithmische Skala)", y = "Bevölkerung unter 3 int. Dollar pro Tag",
         caption = caption(source_pip, "Jedes Land ist einmal vertreten. Beschriftet sind die drei bisherigen Fallbeispiele. Gleiche Abstände auf der BIP-Achse bedeuten gleiche Faktoren; BIP ist nicht kaufkraftbereinigt.")) + owid_theme()
  write_table(x[, .(country_code, country_de, year, region_code, reporting_pop, reporting_gdp, pct_below_3)], "gdp_bubbles_plot_data")
  export(p, "08_bip_und_armut", "Wie hängt wirtschaftliche Leistung mit extremer Armut zusammen?", takeaway,
    "Die Punktfläche zeigt die Bevölkerung, die Farbe die Weltbankregion. Höheres BIP geht meist mit weniger extremer Armut einher. Die Zusammenfassung gewichtet Länder weiterhin gleich. BIP, Verteilung und individuelle Lebensqualität sind unterschiedliche Größen; ein kausaler Effekt wird nicht geschätzt.",
    ref_economy, "Regionale Farben, Punktflächen nach Bevölkerung und eine logarithmische BIP-Achse. Andere y-Variable und feste Kursdaten.", section = "Wirtschaftliche Lebensbedingungen")

  # 9. Keep income and consumption apart, with regional context and less empty space.
  x <- copy(selected[is.finite(gini_points)])
  groups <- x[, .(n = .N, rho = rank_association(gini_points, pct_below_3)), by = welfare_type]
  groups[, panel := paste0(ifelse(welfare_type == "income", "Einkommen", "Konsum"), " · ", n, " Länder")]
  x <- merge(x, groups[, .(welfare_type, panel)], by = "welfare_type")
  takeaway <- if (all(groups$rho > .3)) "Mehr Ungleichheit geht meist mit mehr Armut einher" else
    "Ungleichheit und Armut hängen je nach Erhebungsart unterschiedlich zusammen"
  p <- ggplot(x, aes(gini_points, pct_below_3)) +
    geom_point(aes(fill = region_code), shape = 21, size = 3, color = "white", stroke = .25, alpha = .8) +
    geom_label(data = case_points(x), aes(label = country_de, color = region_code), hjust = -.05, vjust = -.6,
               size = 3.2, fill = "white", linewidth = 0, show.legend = FALSE) +
    facet_wrap(~panel, nrow = 1) + fills() + colors() +
    scale_x_continuous(limits = c(20, 75), breaks = seq(20, 70, 10)) +
    scale_y_continuous(limits = c(0, ceiling(max(x$pct_below_3) / 10) * 10),
                       breaks = seq(0, 100, 30), labels = percent_labels) +
    labs(subtitle = paste0(period, " · Einkommen und Konsum getrennt · Gini und Armutsquote aus derselben Erhebung"),
         x = "Gini-Index (0–100): weiter rechts bedeutet mehr Ungleichheit", y = "Bevölkerung unter 3 int. Dollar pro Tag",
         caption = caption(source_pip, "Gleiche Achsen für Einkommen und Konsum. Andere Länderunterschiede wie das BIP sind nicht konstant gehalten. Deutsche Regionszuordnung: Weltbank, nicht OWID-Kontinente.")) +
    owid_theme() + theme(legend.position = "bottom") + guides(fill = guide_legend(nrow = 2, byrow = TRUE))
  export(p, "09_ungleichheit_und_armut", "Wie hängen Ungleichheit und extreme Armut zusammen?", takeaway,
    "Die beiden Felder trennen Einkommen und Konsum und verwenden gemeinsame Achsen. Die Farben zeigen regionale Unterschiede innerhalb dieser Gruppen. Höhere Ungleichheit geht in beiden Gruppen meist mit mehr Armut einher; Wohlstandsniveau und weitere Einflüsse sind nicht konstant gehalten.",
    ref_economy, "Regionale Länderfarben und klar beschriftete Indikatorachsen; eigene Gegenüberstellung der Erhebungsarten.", section = "Wirtschaftliche Lebensbedingungen")

  # 10. Direct adaptation of OWID's poverty-child-mortality scatter.
  x <- copy(a$mortality_snapshot[order(-reporting_pop)])
  takeaway <- if (rank_association(x$pct_below_3, x$child_mortality) > .3)
    "Mehr extreme Armut geht meist mit höherer Kindersterblichkeit einher" else
    "Armut und Kindersterblichkeit zeigen keinen einheitlichen Zusammenhang"
  p <- ggplot(x, aes(pct_below_3, child_mortality)) +
    geom_point(aes(fill = region_code, size = reporting_pop), shape = 21, color = "white", stroke = .3, alpha = .8) +
    geom_label(data = case_points(x), aes(label = country_de, color = region_code), hjust = -.08, vjust = -.45,
               size = 3.6, fill = "white", linewidth = 0, show.legend = FALSE) +
    fills() + colors() + population_sizes() + bubble_guides() +
    scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = percent_labels) +
    scale_y_continuous(limits = c(0, NA), labels = number_labels, expand = expansion(mult = c(.02, .1))) +
    labs(subtitle = paste0(period, " · ", nrow(x), " Länder · Armut und Kindersterblichkeit aus demselben Berichtsjahr"),
         x = "Bevölkerung unter 3 int. Dollar pro Tag", y = "Kindersterblichkeit (je 100 Lebendgeburten)",
         caption = caption(source_health, "Kindersterblichkeit: Todesfälle vor dem fünften Geburtstag. Ein Punkt pro Land, Fläche nach Bevölkerung. Die Darstellung vergleicht Länder und belegt keine individuelle Wirkung.")) + owid_theme()
  write_table(x[, .(country_code, country_de, year, region_code, reporting_pop, pct_below_3, child_mortality)], "mortality_bubbles_plot_data")
  export(p, "10_kindersterblichkeit_und_armut", "Wie hängen extreme Armut und das Überleben von Kindern zusammen?", takeaway,
    "Die Darstellung greift die OWID-Grafik zu extremer Armut und Kindersterblichkeit auf: ein Kreis je Land, Fläche nach Bevölkerung, Farbe nach Region. Unsere Farben entsprechen den sieben Weltbankregionen. Die verwendeten Jahre und Werte stammen vollständig aus dem Kursdatensatz. Der Zusammenhang erklärt nicht die Ursachen einzelner Sterbefälle.",
    ref_scatter, "Direkte Orientierung an OWIDs Kindersterblichkeit-Armut-Vergleich, mit Weltbankregionen und der Kurs-Datenversion.")

  # 11. Two fixed country groups replace three repetitive scatter panels.
  x <- copy(a$mortality_groups)
  first_year <- min(x$target_year); last_year <- max(x$target_year); span <- last_year - first_year
  group_colors <- c(high = "#873C5B", lower = "#2C846E")
  group_names <- c(high = "Anfangs ab 30 % in extremer Armut", lower = "Anfangs unter 30 % in extremer Armut")
  first <- x[target_year == first_year]; last <- x[target_year == last_year]
  last[, label := paste0(group_names[poverty_group], "\n", fmt(mortality_median), " je 100 · n = ", n)]
  takeaway <- if (all(last$mortality_median[match(first$poverty_group, last$poverty_group)] < first$mortality_median))
    "Die Kindersterblichkeit sank in beiden Armutsgruppen deutlich" else
    "Die Armutsgruppen unterscheiden sich in der Entwicklung der Kindersterblichkeit"
  p <- ggplot(x, aes(target_year, mortality_median, color = poverty_group)) +
    geom_line(linewidth = 1.3) + geom_point(size = 3) +
    geom_text(data = first, aes(label = fmt(mortality_median)), vjust = -1, hjust = 0, size = 4.4) +
    geom_segment(data = last, aes(xend = last_year + span * .035, yend = mortality_median), linewidth = .7) +
    geom_text(data = last, aes(x = last_year + span * .05, label = label), hjust = 0, lineheight = 1.2, size = 4.3) +
    scale_color_manual(values = group_colors, guide = "none") +
    scale_x_continuous(limits = c(first_year, last_year + span * .56), breaks = sort(unique(x$target_year))) +
    scale_y_continuous(limits = c(0, NA), labels = number_labels, expand = expansion(mult = c(.02, .15))) +
    labs(subtitle = paste0("Dieselben ", uniqueN(a$mortality_panel$country_code), " Länder in allen Fenstern · Gruppen nach der Armutsquote um ", first_year, " fixiert"),
         x = paste0("Zieljahr (Erhebungen jeweils innerhalb ±", config$indicator_tolerance, " Jahren)"), y = "Kindersterblichkeit: Median der Länder (je 100 Lebendgeburten)",
         caption = caption(source_health, "Ungewichtete Ländermediane, keine bevölkerungsgewichteten Gruppenquoten. Nur die drei gezeigten Zeitfenster sind berechnet; Linien verbinden diese Punkte. Länder wechseln die Gruppe nicht.")) + owid_theme()
  export(p, "11_kindersterblichkeit_zeitvergleich", "Wie entwickelte sich Kindersterblichkeit in anfangsärmeren Ländern?", takeaway,
    paste0("Nach dem Vorbild direkt beschrifteter OWID-Gruppenverläufe werden dieselben ", uniqueN(a$mortality_panel$country_code),
      " Länder anhand ihrer Armutsquote im ersten Fenster in zwei feste Gruppen eingeteilt. Die Linien zeigen deren ungewichtete Ländermediane. Beide Gruppen verbessern sich; die Gruppe mit anfangs höherer Armut hat weiterhin die höhere Kindersterblichkeit. Die ursprünglichen Länderquerschnitte und Rangkorrelationen bleiben in den Tabellen erhalten."),
    ref_groups, "Direkt beschriftete Gruppenverläufe. Eigene feste Armutsgruppen und Ländermediane statt OWID-Einkommensklassen und Gruppenaggregaten.")

  # 12. One counterexample, two separately labelled, zero-based scales; no dual axis.
  x <- copy(a$mortality_focus)
  code <- unique(x$country_code); label <- country_labels(unique(x$country_name))
  x[, panel := factor(indicator, levels = c("poverty_pct", "child_mortality"),
                       labels = c("Extreme Armut · Anteil unter 3 Dollar (%)", "Kindersterblichkeit · Todesfälle je 100 Lebendgeburten"))]
  endpoints <- x[year %in% range(year)]
  anchors <- x[, .(year = min(year), value = 0), by = panel]
  labels <- endpoints[, .(panel, indicator, year, value, label = paste0(fmt(value), ifelse(indicator == "poverty_pct", " %", " je 100")))]
  movement <- x[order(year), .(change = tail(value, 1) - value[1]), by = indicator]
  counter <- movement[indicator == "poverty_pct", change] > 0 && movement[indicator == "child_mortality", change] < 0
  takeaway <- if (counter) paste0("In ", label, " stieg die Armut, während die Kindersterblichkeit sank") else
    paste0("Armut und Kindersterblichkeit entwickelten sich in ", label, " unterschiedlich")
  p <- ggplot(x, aes(year, value, color = indicator)) +
    geom_blank(data = anchors, inherit.aes = FALSE, aes(year, value)) +
    geom_line(linewidth = 1.2) + geom_point(size = 3.5) +
    geom_text(data = labels, aes(label = label, hjust = ifelse(year == min(x$year), 0, 1)),
              vjust = -1, size = 4.3, fontface = "bold") + facet_wrap(~panel, ncol = 1, scales = "free_y") +
    scale_color_manual(values = c(poverty_pct = accent, child_mortality = ink), guide = "none") +
    scale_x_continuous(breaks = sort(unique(x$year)), expand = expansion(mult = c(.05, .05))) +
    scale_y_continuous(labels = number_labels, expand = expansion(mult = c(.02, .22))) +
    labs(subtitle = paste0(label, " · ", min(x$year), "–", max(x$year), " · zwei Indikatoren, dieselben Berichtsjahre"),
         x = NULL, y = NULL,
         caption = caption(source_health, "Die Felder haben unterschiedliche y-Skalen und beginnen bei null. Punkte markieren die nationalen Erhebungsjahre. Die zeitliche Gegenüberstellung bestimmt keine Ursache.")) + owid_theme()
  export(p, "12_kindersterblichkeit_fallbeispiele", "Müssen Armut und Kindersterblichkeit denselben Verlauf nehmen?", takeaway,
    paste0("Die Grafik konzentriert sich auf ", label, " als Gegenbeispiel aus den bereits ausgewählten Fällen. Beide Verläufe verwenden genau dieselben Berichtsjahre innerhalb des vergleichbaren Armutsintervalls. Die Felder beginnen bei null, haben aber unterschiedliche Skalen: Richtungen sind vergleichbar, Steigungen nicht. Die Daten zu allen drei ursprünglichen Fällen bleiben exportiert."),
    ref_line, "Direkte Endpunktbeschriftung und ruhige Zeitverläufe. Zwei getrennte Skalen für das ausgewählte Gegenbeispiel statt einer Doppelachse.", height = 8.8)

  # 13. Keep the same richer-country sample, adding regional context and labels.
  x <- copy(a$higher_gdp_thresholds)
  x[, country_de := country_labels(country_de)]
  x[, panel := factor(threshold, levels = c("pct_below_3", "pct_below_40"),
                       labels = c("Unter 3 int. Dollar pro Tag", "Unter 40 int. Dollar pro Tag"))]
  highlight <- x[order(-reporting_pop), head(.SD, 3L), by = threshold]
  strong <- any(abs(a$higher_gdp_associations$rho) >= .3, na.rm = TRUE)
  takeaway <- if (!strong) "Auch bei 40 Dollar bleibt der Zusammenhang zur Kindersterblichkeit schwach" else
    "Die Armutsgrenze verändert den Zusammenhang in der Gruppe mit höherem BIP"
  p <- ggplot(x, aes(poverty_pct, child_mortality)) +
    geom_point(aes(fill = region_code), shape = 21, size = 4, color = "white", stroke = .3, alpha = .85) +
    geom_label(data = highlight, aes(label = country_de, color = region_code, hjust = ifelse(poverty_pct == max(poverty_pct), 1, .5)),
               vjust = -1, size = 3.3, fill = "white", linewidth = 0, show.legend = FALSE) +
    facet_wrap(~panel, nrow = 1, scales = "free_x") + fills() + colors() +
    scale_x_continuous(limits = c(0, NA), labels = function(z) paste0(fmt(z, 1), " %"), expand = expansion(mult = c(.02, .12))) +
    scale_y_continuous(limits = c(0, NA), labels = number_labels, expand = expansion(mult = c(.02, .2))) +
    labs(subtitle = paste0("Dieselben ", uniqueN(x$country_code), " Länder · BIP ab ", fmt(config$higher_gdp_cutoff, 0), " US-Dollar pro Kopf · ", period),
         x = "Bevölkerungsanteil unter der jeweiligen Grenze (verschiedene x-Skalen)", y = "Kindersterblichkeit (je 100 Lebendgeburten)",
         caption = caption(source_health, "BIP in Preisen von 2015; eigene Gruppe, keine Weltbank-Einkommensklasse. Beschriftet: die drei bevölkerungsreichsten Länder dieser Gruppe. Andere BIP-Abgrenzungen zeigen zum Teil stärkere Zusammenhänge.")) +
    owid_theme() + theme(legend.position = "bottom") + guides(fill = guide_legend(nrow = 1))
  explanation <- if (!strong) paste0("In der Gruppe ab ", fmt(config$higher_gdp_cutoff, 0),
    " US-Dollar BIP bleibt der Zusammenhang zur Kindersterblichkeit bei beiden Grenzen schwach.") else
    "Stärke und Richtung des Zusammenhangs hängen von der Grenze und der gewählten BIP-Gruppe ab."
  export(p, "13_hoehere_grenze_kindersterblichkeit", "Hilft eine höhere Armutsgrenze beim Vergleich von Ländern mit höherem BIP?", takeaway,
    paste("Die beiden Felder zeigen dieselben Länder und Jahre mit regionalen Farben. Beschriftet sind die drei bevölkerungsreichsten Länder dieser Auswahl.",
      explanation, "Der Bericht zeigt zusätzlich andere BIP-Abgrenzungen. Die 40-Dollar-Grenze bezeichnet hier keine extreme Armut."),
    ref_scatter, "Regionale Länderfarben und direkte Ländernamen. Eigener Vergleich zweier Grenzen mit identischer Stichprobe und gemeinsamer Sterblichkeitsskala.", height = 8.5)
  figures
}
