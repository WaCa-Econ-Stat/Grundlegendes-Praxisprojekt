make_living_conditions_figures <- function(a, config) {
  ink <- "#315F87"
  accent <- "#934354"
  figures <- list()
  source <- "Quellen: Weltbank PIP; Kindersterblichkeit: UN IGME/Gapminder via Our World in Data. Kursdatensatz."
  snapshot_note <- paste0("Ein Punkt je Land. Nationale OWID-Auswahl, nächstes Jahr zu ", config$indicator_year,
                          " innerhalb ±", config$indicator_tolerance, " Jahren; früheres Jahr bei Gleichstand.")
  mortality_axis <- "Todesfälle vor dem 5. Geburtstag je 100 Lebendgeburten"
  number_labels <- function(z) fmt(z, if (all(abs(z - round(z)) < 1e-8, na.rm = TRUE)) 0L else 1L)
  export <- function(plot, name, question, takeaway, explanation, height = 8, section = "Gesundheit und Kindersterblichkeit") {
    title <- paste(strwrap(takeaway, width = 76), collapse = "\n")
    out <- save_figure(plot + labs(title = title), name, config, height = height)
    out[, `:=`(question = question, takeaway = takeaway, explanation = explanation, section = section)]
    figures[[length(figures) + 1L]] <<- out
  }
  scatter_theme <- function() analysis_theme() + theme(
    panel.grid.major.x = element_line(color = "#DFE4E8", linewidth = .3))
  case_points <- function(x) x[country_code %in% a$cases$country_code]
  selected <- a$indicator_snapshot

  # 8. GDP provides economic context, without equating national output with welfare.
  x <- copy(selected[is.finite(reporting_gdp) & reporting_gdp > 0])
  highlight <- case_points(x)
  rho <- rank_association(x$reporting_gdp, x$pct_below_3)
  takeaway <- if (rho < -.3) "Länder mit höherem BIP pro Kopf haben meist weniger extreme Armut" else
    "BIP pro Kopf und Armutsquote zeigen keinen einheitlichen Zusammenhang"
  p <- ggplot(x, aes(reporting_gdp, pct_below_3)) +
    geom_point(color = ink, alpha = .55, size = 2.7) +
    geom_point(data = highlight, color = accent, size = 3.2) +
    geom_label(data = highlight, aes(label = country_de), hjust = -.08, vjust = -.4,
               size = 3.4, color = accent, fill = "white", linewidth = 0) +
    scale_x_log10(breaks = c(300, 1000, 3000, 10000, 30000, 100000), labels = function(z) fmt(z, 0),
                  expand = expansion(mult = c(.04, .12))) +
    scale_y_continuous(limits = c(0, 100), labels = percent_labels) +
    labs(subtitle = paste0(nrow(x), " Länder um ", config$indicator_year, ". Rot markiert sind die drei bisherigen Fallbeispiele."),
         x = "BIP pro Kopf und Jahr (konstante US-Dollar von 2015; logarithmische Skala)",
         y = "Anteil unter 3 int. Dollar pro Tag",
         caption = paste0("Quelle: Weltbank PIP, Kursdatensatz. ", snapshot_note,
           "\nGleiche Abstände auf der BIP-Achse entsprechen gleichen Faktoren. BIP ist kein direktes Maß individueller Lebensqualität.",
           "\nLänder werden gleich gewichtet. Einkommen und Konsum folgen der jeweiligen OWID-Auswahl. Zusammenhang, kein Wirkungsnachweis.")) + scatter_theme()
  export(p, "08_bip_und_armut", "Wie hängt wirtschaftliche Leistung mit extremer Armut zusammen?", takeaway,
    "Jeder Punkt steht für ein Land. Rechts liegen Länder mit höherem BIP pro Kopf, oben Länder mit mehr extremer Armut. Das BIP beschreibt die wirtschaftliche Leistung; die Verteilung dieser Mittel und ihre Wirkung auf einzelne Menschen bleiben offen.",
    section = "Wirtschaftliche Lebensbedingungen")

  # 9. Separate survey concepts make the inequality association easier to assess.
  x <- copy(selected[is.finite(gini_points)])
  groups <- x[, .(n = .N, rho = rank_association(gini_points, pct_below_3)), by = welfare_type]
  groups[, panel := paste0(ifelse(welfare_type == "income", "Einkommen", "Konsum"), " (n = ", n, ")")]
  x <- merge(x, groups[, .(welfare_type, panel)], by = "welfare_type")
  takeaway <- if (all(groups$rho > .3)) "Mehr Ungleichheit geht bei beiden Erhebungsarten mit mehr Armut einher" else
    "Der Zusammenhang zwischen Ungleichheit und Armut unterscheidet sich nach Erhebungsart"
  p <- ggplot(x, aes(gini_points, pct_below_3)) +
    geom_point(color = ink, alpha = .65, size = 2.7) + facet_wrap(~panel, nrow = 1) +
    scale_x_continuous(limits = c(20, 75), breaks = seq(20, 70, 10)) +
    scale_y_continuous(limits = c(0, 100), labels = percent_labels) +
    labs(subtitle = paste0("Ländervergleich um ", config$indicator_year, ", Einkommen und Konsum getrennt"),
         x = "Gini-Index: weiter rechts bedeutet mehr Ungleichheit (0–100)", y = "Anteil unter 3 int. Dollar pro Tag",
         caption = paste0("Quelle: Weltbank PIP, Kursdatensatz. ", snapshot_note,
           "\nGleiche Achsen in beiden Feldern. Gini aus derselben Erhebung wie die Armutsquote; Originalwerte 0–1 wurden mit 100 skaliert.",
           "\nKein Vergleich bei gleichem BIP oder gleicher mittlerer Kaufkraft. Die Punkte zeigen keinen isolierten Effekt der Ungleichheit.")) + scatter_theme()
  export(p, "09_ungleichheit_und_armut", "Wie hängen Ungleichheit und extreme Armut zusammen?", takeaway,
    "Weiter rechts liegen ungleichere Einkommens- oder Konsumverteilungen. In beiden Feldern geht eine höhere Ungleichheit meist mit einer höheren Armutsquote einher. Andere Unterschiede zwischen den Ländern, etwa das durchschnittliche Wohlstandsniveau, sind dabei nicht konstant gehalten.",
    section = "Wirtschaftliche Lebensbedingungen")

  # 10. A single cross-section connects monetary poverty to child survival.
  x <- copy(a$mortality_snapshot)
  highlight <- case_points(x)
  rho <- rank_association(x$pct_below_3, x$child_mortality)
  takeaway <- if (rho > .3) "Mehr extreme Armut geht meist mit höherer Kindersterblichkeit einher" else
    "Armut und Kindersterblichkeit zeigen keinen einheitlichen Zusammenhang"
  p <- ggplot(x, aes(pct_below_3, child_mortality)) +
    geom_point(color = ink, alpha = .55, size = 2.8) +
    geom_point(data = highlight, color = accent, size = 3.3) +
    geom_label(data = highlight, aes(label = country_de), hjust = -.08, vjust = -.35,
               size = 3.4, color = accent, fill = "white", linewidth = 0) +
    scale_x_continuous(limits = c(0, 100), labels = percent_labels) +
    scale_y_continuous(limits = c(0, NA), labels = number_labels, expand = expansion(mult = c(.02, .12))) +
    labs(subtitle = paste0(nrow(x), " Länder um ", config$indicator_year, ". Kindersterblichkeit jeweils aus demselben Berichtsjahr wie die Armut."),
         x = "Anteil unter 3 int. Dollar pro Tag", y = mortality_axis,
         caption = paste0(source, "\n", snapshot_note,
           "\nRot: die bisherigen Fallbeispiele. Jedes Land zählt einmal. Fehlende Sterblichkeitswerte werden nicht ersetzt.",
           "\nDie Punkte vergleichen Länder; sie verknüpfen keine einzelnen Haushalte oder Kinder und belegen keine Ursache.")) + scatter_theme()
  export(p, "10_kindersterblichkeit_und_armut", "Wie hängen extreme Armut und das Überleben von Kindern zusammen?", takeaway,
    "Rechts liegt mehr extreme Armut, oben eine höhere Kindersterblichkeit. Die Häufung von Punkten von links unten nach rechts oben macht den Zusammenhang sichtbar. Gesundheitssystem, Ernährung, Wasser und weitere mögliche Einflüsse sind in diesem Vergleich nicht getrennt gemessen.")

  # 11. Use the same countries to avoid attributing sample composition to time.
  x <- copy(a$mortality_panel)
  periods <- x[, .(n = .N, first = min(year), last = max(year), rho = rank_association(pct_below_3, child_mortality)), by = target_year]
  periods[, panel := paste0("Um ", target_year, "\nErhebungen ", first, "–", last)]
  x <- merge(x, periods[, .(target_year, panel)], by = "target_year")
  takeaway <- if (all(periods$rho > .3)) "Der Zusammenhang mit Kindersterblichkeit ist in allen Zeitfenstern sichtbar" else
    "Der Zusammenhang mit Kindersterblichkeit verändert sich zwischen den Zeitfenstern"
  p <- ggplot(x, aes(pct_below_3, child_mortality)) +
    geom_point(color = ink, alpha = .65, size = 2.4) + facet_wrap(~panel, nrow = 1) +
    scale_x_continuous(limits = c(0, 100), breaks = c(0, 50, 100), labels = percent_labels) +
    scale_y_continuous(limits = c(0, NA), labels = number_labels, expand = expansion(mult = c(.02, .08))) +
    labs(subtitle = paste0("In jedem Feld dieselben ", periods$n[1], " Länder; gleiche Achsen erleichtern den Vergleich."),
         x = "Anteil unter 3 int. Dollar pro Tag", y = mortality_axis,
         caption = paste0(source, "\nJe Land und Zeitfenster die nächste OWID-Erhebung innerhalb ±", config$indicator_tolerance,
           " Jahren; Sterblichkeit aus genau demselben Jahr.",
           "\nGemeinsame Länder mit vollständigen Werten in allen Fenstern. Erhebungsmethode und Vergleichbarkeit können sich über die Zeit ändern.",
           "\nWiederholte Länderquerschnitte, keine geschätzte individuelle Wirkung und kein Beleg für eine konstante Stärke des Zusammenhangs.")) + scatter_theme()
  export(p, "11_kindersterblichkeit_zeitvergleich", "Bleibt der Zusammenhang zwischen Armut und Kindersterblichkeit über die Zeit sichtbar?", takeaway,
    paste0("In jedem Feld stehen dieselben ", periods$n[1], " Länder. Der positive Zusammenhang bleibt über die betrachteten Zeitfenster sichtbar. Das bedeutet weder eine unveränderte Stärke noch dieselbe Entwicklung jedes einzelnen Landes. Die vollständige Länderauswahl und tatsächlichen Jahre sind exportiert."), 8.5)

  # 12. Revisit the previously selected cases; do not select new mortality extremes.
  x <- copy(a$case_mortality)
  setorder(x, mortality_start)
  x[, country := factor(country_code, levels = country_code)]
  x[, color := ifelse(change_pp > 0, accent, ink)]
  x[, row_label := paste0(country_de, "\n", start_year, "–", end_year, " · Armut ",
                          ifelse(change_pp > 0, "+", "−"), fmt(abs(change_pp)), " PP")]
  counter <- x[change_pp > 0 & mortality_change_pp < 0]
  takeaway <- if (nrow(counter)) paste0("In ", counter$country_de[1], " sank die Kindersterblichkeit trotz steigender Armut") else
    "Die drei Fallbeispiele zeigen unterschiedliche Entwicklungen der Kindersterblichkeit"
  p <- ggplot(x, aes(y = country)) +
    geom_segment(aes(x = mortality_start, xend = mortality_end, yend = country), color = "#CDD3D9", linewidth = 1.6) +
    geom_point(aes(mortality_start, shape = "Anfang"), size = 4, color = "#78838D", stroke = 1.2) +
    geom_point(aes(mortality_end, color = color, shape = "Ende"), size = 4) + scale_color_identity() +
    geom_text(aes(mortality_start, label = fmt(mortality_start)), vjust = -1.2, size = 4.6, color = "#78838D") +
    geom_text(aes(mortality_end, label = fmt(mortality_end), color = color), vjust = 2.1, size = 4.6, fontface = "bold") +
    scale_shape_manual(values = c(Anfang = 1, Ende = 16), breaks = c("Anfang", "Ende")) +
    scale_y_discrete(labels = setNames(x$row_label, x$country_code), expand = expansion(add = .7)) +
    scale_x_continuous(limits = c(0, ceiling(max(x$mortality_start, x$mortality_end)) + 1), labels = number_labels) +
    labs(subtitle = "Kindersterblichkeit an den tatsächlichen Endpunkten der drei zuvor ausgewählten Länderreihen",
         x = mortality_axis, y = NULL,
         caption = paste0(source,
           "\nOffener Kreis: Anfang. Gefüllter Kreis: Ende. Die Angaben links nennen zusätzlich die Änderung der Armutsquote in Prozentpunkten.",
           "\nFallauswahl und Vergleichsintervalle stammen aus der Armutsanalyse. Unterschiede in den Zeitspannen erlauben keine einfache Rangfolge.",
           "\nGegenläufigkeit zeigt: Die monetäre Armutsquote allein beschreibt nicht alle Veränderungen der Lebensbedingungen.")) + analysis_theme() +
    theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(color = "#DFE4E8", linewidth = .3),
          legend.position = "top", axis.text.y = element_text(size = 12))
  export(p, "12_kindersterblichkeit_fallbeispiele", "Verbessern sich die Überlebenschancen von Kindern nur bei sinkender Armut?", takeaway,
    "Der Vergleich greift dieselben drei Fälle und tatsächlichen Jahre wie die bisherige Armutsanalyse auf. Eine sinkende Kindersterblichkeit kann auch mit steigender monetärer Armut zusammenfallen. Aus der zeitlichen Gegenüberstellung lässt sich die Ursache dieser Entwicklungen nicht bestimmen.")

  # 13. Keep a weak result visible: a higher poverty line is not guaranteed to help.
  x <- copy(a$higher_gdp_thresholds)
  x[, panel := factor(threshold, levels = c("pct_below_3", "pct_below_40"),
                       labels = c("Unter 3 int. Dollar pro Tag", "Unter 40 int. Dollar pro Tag"))]
  strong <- any(abs(a$higher_gdp_associations$rho) >= .3, na.rm = TRUE)
  takeaway <- if (!strong) "Auch bei 40 Dollar bleibt der Zusammenhang zur Kindersterblichkeit schwach" else
    "Die gewählte Armutsgrenze verändert den Zusammenhang in der Gruppe mit höherem BIP"
  p <- ggplot(x, aes(poverty_pct, child_mortality)) +
    geom_point(color = ink, alpha = .75, size = 3) + facet_wrap(~panel, nrow = 1, scales = "free_x") +
    scale_x_continuous(limits = c(0, NA), labels = function(z) paste0(fmt(z, 1), " %"), expand = expansion(mult = c(.02, .08))) +
    scale_y_continuous(limits = c(0, NA), labels = number_labels, expand = expansion(mult = c(.02, .1))) +
    labs(subtitle = paste0("Dieselben ", uniqueN(x$country_code), " Länder um ", config$indicator_year,
                          " mit BIP ab ", fmt(config$higher_gdp_cutoff, 0), " US-Dollar pro Kopf (Preise von 2015)"),
         x = "Bevölkerungsanteil unter der jeweiligen Grenze (unterschiedliche x-Skalen)", y = mortality_axis,
         caption = paste0(source,
           "\nEigene Gruppe nach BIP, keine Weltbank-Einkommensklasse. Gleiche Länder und Jahre in beiden Feldern; die y-Skala ist identisch.",
           "\n40 int. Dollar sind eine ergänzende Vergleichsgrenze aus dem Datensatz, keine zusätzliche internationale Grenze für extreme Armut.",
           "\nDie höhere Grenze zeigt mehr monetäre Unterschiede, aber keinen automatisch stärkeren Zusammenhang. Andere BIP-Grenzen stehen in higher_gdp_sensitivity.csv.")) + scatter_theme()
  explanation <- if (!strong) {
    "Die 3-Dollar-Quoten liegen hier nahe null. Bei 40 Dollar werden größere monetäre Unterschiede sichtbar; ein klarer positiver Zusammenhang zur Kindersterblichkeit entsteht in dieser Ländergruppe trotzdem nicht."
  } else "Die beiden Felder zeigen dieselben Länder unter zwei Grenzen. Die beobachtete Stärke und Richtung des Zusammenhangs hängen von der Grenze und der gewählten BIP-Gruppe ab."
  export(p, "13_hoehere_grenze_kindersterblichkeit", "Hilft eine höhere Armutsgrenze beim Vergleich von Ländern mit höherem BIP?", takeaway,
    paste(explanation, "Der Befund gilt für diese Auswahl und dieses Zeitfenster und ist keine Aussage über einzelne Haushalte."), 8.5)

  figures
}
