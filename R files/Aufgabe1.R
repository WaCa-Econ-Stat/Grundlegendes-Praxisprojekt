# Frage 1: drei Präsentationsgrafiken im Format 16:9
# Zeitverlauf, regionale Weltkarte und Länder/Regionalvergleich
# Einmalig bei Bedarf: install.packages(c("tidyverse", "ggrepel", "svglite"))
library(tidyverse)
if (!requireNamespace("ggrepel", quietly = TRUE)) {
  stop('Bitte einmal install.packages("ggrepel") ausführen.')
}

# Einstellungen ------------------------------------------------------------
data_dir <- paste0(
  "/Users/julian/Documents/BSc Statistik und Data Science/Semester5/",
  "Anfängerpraktikum/Projekt/Grundlegendes-Praxisprojekt/data"
)
output_dir <- "outputs"  # relativ zum aktuellen R-Arbeitsverzeichnis
start_year <- 1990L
end_year <- 2024L        # regionale Prognosen für 2025/2026 ausschließen

# Daten einlesen -----------------------------------------------------------
# Die OWID-Quoten liegen bereits in Prozent (0 bis 100) vor.
armut <- read_csv(
  file.path(data_dir, "owid_poverty_lines.csv"),
  col_types = cols(
    .default = col_skip(),
    Country = col_character(), Year = col_integer(),
    `Share below $3 a day` = col_double()
  )
) |>
  rename(land = Country, jahr = Year, armutsquote = `Share below $3 a day`) |>
  filter(between(jahr, start_year, end_year))

codes <- read_csv(
  file.path(data_dir, "owid_country_codes.csv"),
  col_types = cols(entity = col_character(), code = col_character())
) |>
  transmute(
    land = entity,
    # Kosovo hat in OWID und PIP unterschiedliche Kennungen.
    code = if_else(code == "OWID_KOS", "XKX", code)
  )

# PIP dient hier nur als Zuordnung von Ländern zu Weltbankregionen.
# Die teils mehrfachen PIP-Erhebungen je Land/Jahr werden nicht gemittelt.
laender_regionen <- read_csv(
  file.path(data_dir, "worldbank_pip.csv"),
  col_types = cols(
    .default = col_skip(),
    country_code = col_character(), region_code = col_character()
  )
) |>
  distinct(code = country_code, region_code)

# Regionsnamen der Aggregatzeilen in OWID müssen zu den PIP-Regionen passen.
# Zusätzliche Teilregionen Afrikas werden nicht als eigene Facetten verwendet.
regionen <- tribble(
  ~region_code, ~owid_region, ~region,
  "SSF", "Sub-Saharan Africa (WB)",
  "Afrika südlich der Sahara",
  "SAS", "South Asia (WB)",
  "Südasien",
  "EAS", "East Asia and Pacific (WB)",
  "Ostasien und Pazifik",
  "MEA", "Middle East, North Africa, Afghanistan and Pakistan (WB)",
  "Nahost, Nordafrika,\nAfghanistan und Pakistan",
  "LCN", "Latin America and Caribbean (WB)",
  "Lateinamerika und Karibik",
  "ECS", "Europe and Central Asia (WB)",
  "Europa und Zentralasien",
  "NAC", "North America (WB)",
  "Nordamerika"
)

# Eindeutige Schlüssel verhindern eine unbemerkte Vervielfachung beim Join.
stopifnot(
  start_year < end_year,
  !anyDuplicated(armut[c("land", "jahr")]),
  !anyDuplicated(codes$land),
  !anyDuplicated(laender_regionen$code)
)

# Nationale Länderreihen: Welt-/Regionszeilen und explizite Stadt-/Landreihen
# haben keine passende Länderkennung und fallen bei diesen Joins heraus.
laender <- armut |>
  inner_join(codes, by = "land") |>
  inner_join(laender_regionen, by = "code", na_matches = "never") |>
  inner_join(regionen, by = "region_code") |>
  mutate(region = factor(region, levels = regionen$region)) |>
  arrange(region, land, jahr)

# Dunkle Linie: die bereits modellierte, bevölkerungsgewichtete Regionalquote.
# Kein einfacher Mittelwert der in einem Jahr beobachteten Länderquoten.
regionaltrend <- armut |>
  inner_join(regionen, by = c("land" = "owid_region")) |>
  mutate(region = factor(region, levels = regionen$region)) |>
  arrange(region, jahr)

stopifnot(
  nrow(laender) > 0L,
  n_distinct(regionaltrend$region) == nrow(regionen),
  all(between(laender$armutsquote, 0, 100), na.rm = TRUE),
  all(between(regionaltrend$armutsquote, 0, 100), na.rm = TRUE)
)

# Linien benötigen mindestens zwei Werte. Länder mit nur einem gültigen Wert
# bleiben als einzelner transparenter Punkt sichtbar.
laender <- laender |>
  group_by(code) |>
  mutate(n_werte = sum(!is.na(armutsquote))) |>
  ungroup()

# Präsentationslayout -----------------------------------------------------
# Vier Spalten und zwei Reihen für die sieben Regionen.
# Gemeinsame Skalen erhalten die Vergleichbarkeit zwischen den Regionen.
facet_labels <- setNames(
  c(
    "Afrika südlich der Sahara", "Südasien", "Ostasien und Pazifik",
    "Nahost, Nordafrika,\nAfghanistan und Pakistan",
    "Lateinamerika und Karibik", "Europa und Zentralasien", "Nordamerika"
  ),
  regionen$region
)

letzte_regionalwerte <- regionaltrend |>
  filter(jahr == end_year) |>
  mutate(label = scales::label_number(
    accuracy = 0.1, decimal.mark = ",", suffix = " %"
  )(armutsquote))

stopifnot(nrow(letzte_regionalwerte) == 7L)

# Genügend Abstand zwischen dem letzten regulären Achsenjahr und dem Endjahr.
jahresmarken <- seq(start_year, end_year, by = 10)
jahresmarken <- sort(unique(c(
  jahresmarken[jahresmarken <= end_year - 7], end_year
)))

p <- ggplot() +
  geom_line(
    data = filter(laender, n_werte >= 2L),
    aes(jahr, armutsquote, group = code),
    colour = "grey35", linewidth = 0.45, alpha = 0.30, na.rm = TRUE
  ) +
  geom_point(
    data = filter(laender, n_werte == 1L),
    aes(jahr, armutsquote),
    colour = "grey35", alpha = 0.30, size = 1.3, na.rm = TRUE
  ) +
  geom_line(
    data = regionaltrend,
    aes(jahr, armutsquote, group = region),
    colour = "grey12", linewidth = 1.15, lineend = "round", na.rm = TRUE
  ) +
  geom_point(
    data = letzte_regionalwerte,
    aes(jahr, armutsquote), colour = "grey12", size = 2.1
  ) +
  geom_text(
    data = letzte_regionalwerte,
    aes(x = jahr + 0.9, y = armutsquote, label = label),
    hjust = 0, vjust = 0.35, size = 3.8, fontface = "bold", colour = "grey12"
  ) +
  facet_wrap(
    vars(region), ncol = 4, scales = "fixed",
    labeller = as_labeller(facet_labels), axes = "all", axis.labels = "all"
  ) +
  scale_x_continuous(
    breaks = jahresmarken,
    # Rechts bleibt Platz für die direkt beschrifteten Regionalwerte.
    limits = c(start_year, end_year + 8),
    expand = expansion(mult = c(0.015, 0))
  ) +
  scale_y_continuous(
    breaks = seq(0, 100, 25),
    # scale = 1, da die CSV Prozentwerte und keine Anteile von 0 bis 1 enthält.
    labels = scales::label_percent(scale = 1, accuracy = 1),
    limits = c(0, 100),
    expand = expansion(mult = c(0.045, 0.025))
  ) +
  labs(
    title = "Extreme Armut seit 1990",
    subtitle = sprintf(
      "Anteil der Bevölkerung unter 3 int. Dollar pro Tag (Preise von 2021), %s–%s",
      start_year, end_year
    ),
    x = NULL, y = NULL
  ) +
  theme_minimal(base_size = 13, base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 30, colour = "grey10",
                              margin = margin(b = 7)),
    plot.subtitle = element_text(size = 15.5, colour = "grey35",
                                 margin = margin(b = 24)),
    plot.title.position = "plot",
    strip.text = element_text(face = "bold", size = 14, hjust = 0, vjust = 0,
                              colour = "grey20", lineheight = 1.1,
                              margin = margin(t = 0, b = 12)),
    strip.background = element_blank(),
    strip.placement = "outside",
    axis.text = element_text(colour = "grey40", size = 11.5),
    axis.text.x = element_text(margin = margin(t = 7)),
    axis.text.y = element_text(margin = margin(r = 5)),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = "grey92", linewidth = 0.35),
    panel.spacing.x = grid::unit(17, "pt"),
    panel.spacing.y = grid::unit(24, "pt"),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(24, 26, 18, 22)
  )

praesentationsplot <- ggplotGrob(p)

grid::grid.newpage()
grid::grid.draw(praesentationsplot)

# Grafik speichern ---------------------------------------------------------
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
ggsave(
  filename = file.path(output_dir, "armutsquote_nach_region.png"),
  plot = praesentationsplot, width = 16, height = 9, units = "in",
  dpi = 240, bg = "white"  # 3840 × 2160 Pixel
)

# Optionaler Vektorexport zum verlustfreien Skalieren in Präsentationen.
# Bei Bedarf einmalig: install.packages("svglite")
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(
    filename = file.path(output_dir, "armutsquote_nach_region.svg"),
    plot = praesentationsplot, device = svglite::svglite,
    width = 16, height = 9, units = "in", bg = "white"
  )
}


# ========================================================================
# Grafik 2: Regionale Veränderungen als Weltkarte
# Grafik 3: Länderänderungen im Vergleich zu den jeweiligen Regionalquoten
# ========================================================================

speichern_16_9 <- function(plot, name) {
  ggsave(
    file.path(output_dir, paste0(name, ".png")), plot = plot,
    width = 16, height = 9, units = "in", dpi = 240, bg = "white"
  )
  if (requireNamespace("svglite", quietly = TRUE)) {
    ggsave(
      file.path(output_dir, paste0(name, ".svg")), plot = plot,
      device = svglite::svglite, width = 16, height = 9, units = "in", bg = "white"
    )
  }
}

praesentations_theme <- function() {
  theme_minimal(base_size = 13, base_family = "sans") +
    theme(
      plot.title = element_text(size = 30, face = "bold", colour = "grey10",
                                margin = margin(b = 7)),
      plot.subtitle = element_text(size = 15.5, colour = "grey35",
                                   margin = margin(b = 22)),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.caption = element_text(size = 10.5, colour = "grey45", hjust = 0,
                                  margin = margin(t = 16), lineheight = 1.15),
      axis.text = element_text(size = 11.5, colour = "grey40"),
      axis.title = element_text(size = 13, colour = "grey30"),
      axis.title.x = element_text(margin = margin(t = 10)),
      axis.title.y = element_text(margin = margin(r = 10)),
      panel.grid.minor = element_blank(),
      strip.text = element_text(size = 14, face = "bold", hjust = 0,
                                colour = "grey20", margin = margin(b = 10)),
      strip.placement = "outside",
      panel.spacing.x = grid::unit(19, "pt"),
      panel.spacing.y = grid::unit(24, "pt"),
      plot.background = element_rect(fill = "white", colour = NA),
      plot.margin = margin(24, 26, 18, 22)
    )
}

# Grafik 2: nur echte Regionalaggregate, gemeinsame Endpunktjahre -----------
regionen_anfang_ende <- regionaltrend |>
  filter(jahr %in% c(start_year, end_year)) |>
  select(region_code, region, jahr, armutsquote) |>
  pivot_wider(names_from = jahr, values_from = armutsquote, names_prefix = "jahr_") |>
  transmute(
    region_code, region = str_replace_all(as.character(region), "\n", " "),
    startjahr = start_year, endjahr = end_year,
    quote_start = .data[[paste0("jahr_", start_year)]],
    quote_ende = .data[[paste0("jahr_", end_year)]]
  ) |>
  mutate(
    veraenderung_pp = quote_ende - quote_start,
    veraenderung_prozent = 100 * veraenderung_pp / na_if(quote_start, 0)
  ) |>
  arrange(veraenderung_pp) |>
  mutate(
    zeile = rev(seq_len(n())),
    region_label = if_else(
      region_code == "MEA", "Nahost, Nordafrika,\nAfghanistan und Pakistan", region
    ),
    start_label = scales::label_number(accuracy = 0.1, decimal.mark = ",", suffix = " %")(quote_start),
    ende_label = scales::label_number(accuracy = 0.1, decimal.mark = ",", suffix = " %")(quote_ende),
    delta_label = str_replace(sprintf("%+.1f PP", veraenderung_pp), fixed("."), ",")
  )

stopifnot(nrow(regionen_anfang_ende) == 7L, !anyNA(regionen_anfang_ende$quote_ende))

# Weltkarte als zweite Präsentationsgrafik. Die lokalen Objekte verändern
# die Regionsfaktoren und Beschriftungen der anderen Grafiken nicht.
p_regionen <- local({
  karten_dir <- if (dir.exists("kartendaten")) "kartendaten" else "outputs/kartendaten"
  regionen <- tribble(
    ~region_code, ~owid_region, ~region,
    "SSF", "Sub-Saharan Africa (WB)", "Afrika südlich der Sahara",
    "SAS", "South Asia (WB)", "Südasien",
    "EAS", "East Asia and Pacific (WB)", "Ostasien und Pazifik",
    "MEA", "Middle East, North Africa, Afghanistan and Pakistan (WB)",
    "Nahost, Nordafrika, Afghanistan und Pakistan",
    "LCN", "Latin America and Caribbean (WB)", "Lateinamerika und Karibik",
    "ECS", "Europe and Central Asia (WB)", "Europa und Zentralasien",
    "NAC", "North America (WB)", "Nordamerika"
  )
  
  # Dieselben Endpunktänderungen in Prozentpunkten wie im bisherigen Plot 2.
  regionalwerte <- read_csv(
    file.path(data_dir, "owid_poverty_lines.csv"),
    col_types = cols(
      .default = col_skip(), Country = col_character(), Year = col_integer(),
      `Share below $3 a day` = col_double()
    )
  ) |>
    inner_join(regionen, by = c("Country" = "owid_region")) |>
    filter(Year %in% c(start_year, end_year)) |>
    select(region_code, region, Year, quote = `Share below $3 a day`) |>
    pivot_wider(names_from = Year, values_from = quote, names_prefix = "jahr_") |>
    transmute(
      region_code, region, startjahr = start_year, endjahr = end_year,
      quote_start = .data[[paste0("jahr_", start_year)]],
      quote_ende = .data[[paste0("jahr_", end_year)]],
      veraenderung_pp = quote_ende - quote_start
    )
  
  stopifnot(nrow(regionalwerte) == 7L, !anyNA(regionalwerte$veraenderung_pp))
  
  zuordnung <- read_csv(
    file.path(karten_dir, "worldbank_regionen.csv"), show_col_types = FALSE
  )
  polygone <- read_csv(
    file.path(karten_dir, "welt_polygone.csv"), show_col_types = FALSE
  )
  stopifnot(!anyDuplicated(zuordnung$code))
  
  # Equal-Earth-Projektion, sphärische Vorwärtsgleichungen mit R = 1.
  # Quelle: PROJ / eqearth.cpp (Koeffizienten nach Savric et al., 2018).
  # Dadurch ist für diesen vorbereiteten Kartendatensatz kein sf-Paket nötig.
  equal_earth <- function(longitude, latitude) {
    lambda <- longitude * pi / 180
    phi <- latitude * pi / 180
    a1 <- 1.340264
    a2 <- -0.081106
    a3 <- 0.000893
    a4 <- 0.003796
    m <- sqrt(3) / 2
    theta <- asin(m * sin(phi))
    theta2 <- theta^2
    theta6 <- theta^6
    tibble(
      x = lambda * cos(theta) /
        (m * (a1 + 3 * a2 * theta2 + theta6 * (7 * a3 + 9 * a4 * theta2))),
      y = theta * (a1 + a2 * theta2 + theta6 * (a3 + a4 * theta2))
    )
  }
  
  karte <- polygone |>
    left_join(select(zuordnung, code, region_code), by = "code", relationship = "many-to-one") |>
    left_join(select(regionalwerte, region_code, veraenderung_pp), by = "region_code",
              relationship = "many-to-one") |>
    bind_cols(equal_earth(polygone$longitude, polygone$latitude))
  
  # Diagonale Linien innerhalb der Polygone mit positiver Änderung.
  # Schnittpunkte werden für jede Linie mit allen Polygonringen berechnet.
  # Die Halb-offen-Regel zählt gemeinsame Eckpunkte nur einmal; Löcher bleiben frei.
  schraffiere_polygon <- function(polygon, abstand = 0.07) {
    kanten <- polygon |>
      group_by(ring_id) |>
      arrange(vertex, .by_group = TRUE) |>
      mutate(x_ende = lead(x, default = first(x)), y_ende = lead(y, default = first(y))) |>
      ungroup() |>
      mutate(u_start = x - y, u_ende = x_ende - y_ende)
    linien <- seq(
      floor(min(kanten$u_start) / abstand) * abstand,
      ceiling(max(kanten$u_start) / abstand) * abstand,
      by = abstand
    )
    map_dfr(linien, function(u) {
      schnitte <- kanten |>
        filter((u_start <= u & u_ende > u) | (u_ende <= u & u_start > u)) |>
        transmute(y = y + (u - u_start) / (u_ende - u_start) * (y_ende - y)) |>
        arrange(y) |>
        pull(y)
      if (length(schnitte) < 2L) return(tibble())
      stopifnot(length(schnitte) %% 2L == 0L)
      unten <- schnitte[seq(1, length(schnitte), by = 2)]
      oben <- schnitte[seq(2, length(schnitte), by = 2)]
      tibble(x = u + unten, y = unten, xend = u + oben, yend = oben)
    })
  }
  
  schraffur <- karte |>
    filter(!is.na(veraenderung_pp), veraenderung_pp > 0) |>
    group_split(polygon_id) |>
    map_dfr(schraffiere_polygon)
  
  # Beschriftungen liegen in den jeweiligen Regionen; es sind Regionalwerte.
  beschriftungen <- tribble(
    ~region_code, ~longitude, ~latitude, ~anzeigename,
    "NAC", -108, 45, "Nordamerika",
    "LCN", -64, -14, "Lateinamerika\nund Karibik",
    "SSF", 23, -8, "Afrika südlich\nder Sahara",
    "MEA", 29, 28, "Nahost / Nordafrika\ninkl. Afghanistan und Pakistan",
    "ECS", 66, 56, "Europa und\nZentralasien",
    "SAS", 81, 27.5, "Südasien",
    "EAS", 111, 38, "Ostasien und\nPazifik"
  ) |>
    left_join(select(regionalwerte, region_code, veraenderung_pp), by = "region_code") |>
    mutate(
      aenderung = str_replace(sprintf("%+.1f PP", veraenderung_pp), fixed("."), ","),
      label = paste(anzeigename, aenderung, sep = "\n"),
      textfarbe = if_else(veraenderung_pp < -30, "white", "grey12")
    )
  beschriftungen <- beschriftungen |>
    bind_cols(equal_earth(beschriftungen$longitude, beschriftungen$latitude))
  
  p_karte <- ggplot(karte, aes(x, y, group = polygon_id, subgroup = ring_id)) +
    geom_polygon(
      aes(fill = veraenderung_pp), colour = "grey62", linewidth = 0.16,
      rule = "evenodd"
    ) +
    geom_segment(
      data = schraffur, aes(x, y, xend = xend, yend = yend),
      inherit.aes = FALSE, colour = "grey55", linewidth = 0.24
    ) +
    geom_text(
      data = filter(beschriftungen, region_code != "NAC"),
      aes(x, y, label = label, colour = textfarbe), inherit.aes = FALSE,
      size = 4.05, fontface = "bold", lineheight = 1.05
    ) +
    # Eine weiße Unterlegung hält die Schrift über der Schraffur lesbar.
    geom_label(
      data = filter(beschriftungen, region_code == "NAC"),
      aes(x, y, label = label), inherit.aes = FALSE,
      size = 4.05, fontface = "bold", lineheight = 1.05,
      fill = "white", colour = "grey12", linewidth = 0,
      label.padding = grid::unit(0.16, "lines")
    ) +
    # Reiner Legendenschlüssel für nicht zugeordnete Gebiete.
    geom_point(
      data = tibble(x = Inf, y = Inf, kategorie = "Ohne Regionszuordnung"),
      aes(x, y, shape = kategorie), inherit.aes = FALSE,
      alpha = 0, fill = "white", colour = "grey60", size = 3.5, show.legend = TRUE
    ) +
    scale_fill_gradient(
      low = "grey12", high = "grey94", na.value = "white",
      limits = range(regionalwerte$veraenderung_pp),
      breaks = c(-60, -40, -20, 0),
      labels = scales::label_number(accuracy = 1, decimal.mark = ","),
      name = "Änderung in Prozentpunkten (Schraffur = Zuwachs)",
      guide = guide_colourbar(
        order = 1, direction = "horizontal", title.position = "top", title.hjust = 0.5,
        barwidth = grid::unit(12, "cm"), barheight = grid::unit(0.35, "cm")
      )
    ) +
    scale_colour_identity() +
    scale_shape_manual(
      name = NULL, values = c("Ohne Regionszuordnung" = 22),
      guide = guide_legend(order = 2, override.aes = list(alpha = 1, size = 4))
    ) +
    coord_equal(xlim = c(-2.78, 2.78), ylim = c(-1.12, 1.36), expand = FALSE, clip = "off") +
    labs(
      title = "Wie hat sich die regionale Armut verändert?",
      subtitle = sprintf(
        "Armutsquote unter 3 int. Dollar pro Tag: %s–%s. Jede Fläche zeigt die Änderung ihrer Weltbankregion.",
        start_year, end_year
      )
    ) +
    theme_void(base_size = 13, base_family = "sans") +
    theme(
      plot.title = element_text(size = 30, face = "bold", colour = "grey10", margin = margin(b = 7)),
      plot.subtitle = element_text(size = 14.5, colour = "grey35", margin = margin(b = 12)),
      plot.title.position = "plot",
      legend.position = "bottom", legend.box = "horizontal",
      legend.box.just = "center", legend.spacing.x = grid::unit(0.7, "cm"),
      legend.title = element_text(size = 12.5, colour = "grey30"),
      legend.text = element_text(size = 11.5, colour = "grey35"),
      legend.margin = margin(t = 8),
      plot.background = element_rect(fill = "white", colour = NA),
      plot.margin = margin(24, 26, 16, 22)
    )
  
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  ggsave(
    file.path(output_dir, "regionen_weltkarte.png"), p_karte,
    width = 16, height = 9, units = "in", dpi = 240, bg = "white"
  )
  if (requireNamespace("svglite", quietly = TRUE)) {
    ggsave(
      file.path(output_dir, "regionen_weltkarte.svg"), p_karte,
      device = svglite::svglite, width = 16, height = 9, units = "in", bg = "white"
    )
  }
  
  # Nachvollziehbarer Datenexport: eine Zeile je gezeichneter Länder-/Gebietsfläche.
  write_excel_csv2(
    karte |>
      distinct(feature_id, code, country_name, region_code, veraenderung_pp) |>
      left_join(select(regionen, region_code, region), by = "region_code") |>
      arrange(region_code, country_name),
    file.path(output_dir, "weltkarte_regionszuordnung.csv"), na = ""
  )
  
  p_karte
})

# Grafik 3: je Land exakt gleiche Anfangs- und Endjahre für die Region -------
vergleich_alle <- laender |>
  filter(!is.na(armutsquote)) |>
  arrange(code, jahr) |>
  group_by(code, land, region_code, region) |>
  summarise(
    n_erhebungsjahre = n(), startjahr = first(jahr), endjahr = last(jahr),
    quote_land_start = first(armutsquote), quote_land_ende = last(armutsquote),
    .groups = "drop"
  ) |>
  mutate(zeitspanne_jahre = endjahr - startjahr) |>
  left_join(
    regionaltrend |>
      transmute(region_code, startjahr = jahr, quote_region_start = armutsquote),
    by = c("region_code", "startjahr"), relationship = "many-to-one"
  ) |>
  left_join(
    regionaltrend |>
      transmute(region_code, endjahr = jahr, quote_region_ende = armutsquote),
    by = c("region_code", "endjahr"), relationship = "many-to-one"
  ) |>
  mutate(
    land_pp_pro_jahr = (quote_land_ende - quote_land_start) / na_if(zeitspanne_jahre, 0),
    region_pp_pro_jahr = (quote_region_ende - quote_region_start) / na_if(zeitspanne_jahre, 0),
    abweichung_pp_pro_jahr = land_pp_pro_jahr - region_pp_pro_jahr,
    # Null ist weder Anstieg noch Rückgang. Auch sehr kleine Änderungen zählen.
    gegenlaeufig = land_pp_pro_jahr * region_pp_pro_jahr < 0,
    status = case_when(
      zeitspanne_jahre == 0 ~ "Nur ein Erhebungsjahr; nicht im Streudiagramm",
      is.na(region_pp_pro_jahr) ~ "Regionalwert fehlt; nicht im Streudiagramm",
      .default = "Im Streudiagramm"
    )
  )

vergleich_plot <- vergleich_alle |>
  filter(status == "Im Streudiagramm")

stopifnot(
  nrow(vergleich_alle) == n_distinct(laender$code),
  !anyDuplicated(vergleich_alle$code), nrow(vergleich_plot) > 0L,
  all(is.finite(vergleich_plot$land_pp_pro_jahr)),
  all(is.finite(vergleich_plot$region_pp_pro_jahr))
)

# Übersetzungen betreffen nur die Anzeige, nicht die Schlüssel und Daten.
laender_anzeigenamen <- c(
  "South Sudan" = "Südsudan", "Sri Lanka" = "Sri Lanka",
  "Micronesia (country)" = "Mikronesien", "Yemen" = "Jemen",
  "Tajikistan" = "Tadschikistan", "Bulgaria" = "Bulgarien",
  "Germany" = "Deutschland", "Canada" = "Kanada",
  "United States" = "USA"
)

# Je Region werden die kleinste und größte jährliche Länderänderung markiert.
# Nigeria und Deutschland ergänzen die bereits diskutierten Fallbeispiele.
beschriftungen <- bind_rows(
  vergleich_plot |>
    group_by(region_code) |>
    slice_min(land_pp_pro_jahr, n = 1, with_ties = FALSE),
  vergleich_plot |>
    group_by(region_code) |>
    slice_max(land_pp_pro_jahr, n = 1, with_ties = FALSE),
  vergleich_plot |> filter(code %in% c("NGA", "DEU"))
) |>
  ungroup() |>
  distinct(code, .keep_all = TRUE) |>
  mutate(
    anzeigename = coalesce(unname(laender_anzeigenamen[land]), land),
    label = paste0(anzeigename, "\n", startjahr, "–", endjahr)
  )

# Pro Region identische x-/y-Grenzen; zwischen Regionen verschiedene Skalen,
# damit auch kleine Veränderungen in Europa und Nordamerika sichtbar sind.
# Die Skala hängt von beiden Achsen ab und schließt Null immer ein.
achsenbereiche <- vergleich_plot |>
  group_by(region) |>
  summarise(
    minimum = min(0, land_pp_pro_jahr, region_pp_pro_jahr),
    maximum = max(0, land_pp_pro_jahr, region_pp_pro_jahr),
    .groups = "drop"
  ) |>
  mutate(
    puffer = pmax((maximum - minimum) * 0.18, 0.005),
    unten = minimum - puffer, oben = maximum + puffer
  ) |>
  select(region, unten, oben) |>
  pivot_longer(c(unten, oben), values_to = "grenze")

p_vergleich <- ggplot(vergleich_plot, aes(region_pp_pro_jahr, land_pp_pro_jahr)) +
  geom_blank(data = achsenbereiche, aes(grenze, grenze), inherit.aes = FALSE) +
  geom_hline(yintercept = 0, colour = "grey78", linewidth = 0.4) +
  geom_vline(xintercept = 0, colour = "grey78", linewidth = 0.4) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed",
              colour = "grey55", linewidth = 0.5) +
  geom_point(
    data = filter(vergleich_plot, !gegenlaeufig),
    shape = 21, fill = "grey72", colour = "grey45", alpha = 0.7,
    size = 2.6, stroke = 0.35
  ) +
  geom_point(
    data = filter(vergleich_plot, gegenlaeufig),
    shape = 17, colour = "grey12", size = 2.9
  ) +
  ggrepel::geom_text_repel(
    data = beschriftungen, aes(label = label),
    seed = 17, size = 3.2, lineheight = 1.0, colour = "grey20",
    box.padding = 0.45, point.padding = 0.35, force = 2,
    max.overlaps = Inf, max.iter = 15000, max.time = 1.5,
    min.segment.length = 0, segment.colour = "grey55", segment.size = 0.35
  ) +
  facet_wrap(
    vars(region), ncol = 4, scales = "free", labeller = as_labeller(facet_labels)
  ) +
  scale_x_continuous(
    breaks = scales::breaks_pretty(n = 3),
    labels = scales::label_number(decimal.mark = ",", accuracy = NULL),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    breaks = scales::breaks_pretty(n = 3),
    labels = scales::label_number(decimal.mark = ",", accuracy = NULL),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Welche Länder weichen vom Regionaltrend ab?",
    subtitle = "Mittlere Veränderung der Armutsquote in Prozentpunkten pro Jahr. Land und Region jeweils über dieselben Jahre.",
    x = "Veränderung der Region (PP/Jahr)",
    y = "Veränderung des Landes (PP/Jahr)",
    caption = paste(
      sprintf(
        "Quelle: Our World in Data / Weltbank PIP. %s Länder; %s Länder ohne berechenbare Veränderung ausgeschlossen.",
        nrow(vergleich_plot), nrow(vergleich_alle) - nrow(vergleich_plot)
      ),
      "Zeiträume unterscheiden sich zwischen Ländern. Endpunktvergleich; kein geschätzter linearer Trend. Skalen je Region angepasst.",
      sep = "\n"
    )
  ) +
  praesentations_theme() +
  theme(
    panel.grid.major = element_line(colour = "grey94", linewidth = 0.3),
    plot.subtitle = element_text(size = 14.5, margin = margin(b = 22)),
    axis.text = element_text(size = 10.5, colour = "grey40"),
    panel.spacing.x = grid::unit(24, "pt"),
    panel.spacing.y = grid::unit(22, "pt")
  )

# Lesehilfe in der freien achten Facettenzelle, passend zur Zeitverlaufsgrafik.
lesehilfe_vergleich <- grid::grobTree(
  grid::roundrectGrob(r = grid::unit(7, "pt"), gp = grid::gpar(fill = "grey97", col = NA)),
  grid::textGrob(
    "So liest du den Vergleich", x = 0.08, y = 0.90, just = "left",
    gp = grid::gpar(fontfamily = "sans", fontsize = 13, fontface = "bold", col = "grey20")
  ),
  grid::pointsGrob(x = 0.11, y = 0.73, pch = 17,
                   size = grid::unit(2.8, "mm"), gp = grid::gpar(col = "grey12")),
  grid::textGrob(
    "Gegenläufig", x = 0.22, y = 0.73, just = "left",
    gp = grid::gpar(fontfamily = "sans", fontsize = 12, fontface = "bold", col = "grey20")
  ),
  grid::textGrob(
    "Land und Region mit\nunterschiedlichen Vorzeichen.", x = 0.08, y = 0.59, just = "left",
    gp = grid::gpar(fontfamily = "sans", fontsize = 10.5, lineheight = 1.15, col = "grey35")
  ),
  grid::pointsGrob(x = 0.11, y = 0.39, pch = 21,
                   size = grid::unit(2.5, "mm"), gp = grid::gpar(col = "grey45", fill = "grey72")),
  grid::textGrob(
    "Übrige Länder", x = 0.22, y = 0.39, just = "left",
    gp = grid::gpar(fontfamily = "sans", fontsize = 12, col = "grey30")
  ),
  grid::segmentsGrob(
    x0 = 0.08, x1 = 0.27, y0 = 0.22, y1 = 0.22,
    gp = grid::gpar(col = "grey55", lty = "dashed", lwd = 1.3)
  ),
  grid::textGrob(
    "Land = Region", x = 0.32, y = 0.22, just = "left",
    gp = grid::gpar(fontfamily = "sans", fontsize = 11, col = "grey35")
  ),
  grid::textGrob(
    "Auch kleine Änderungen zählen.", x = 0.08, y = 0.07, just = "left",
    gp = grid::gpar(fontfamily = "sans", fontsize = 10, col = "grey40")
  )
)

vergleichsgrafik <- ggplotGrob(p_vergleich)
freie_zelle <- vergleichsgrafik$layout |> filter(name == "panel-4-2")
stopifnot(nrow(freie_zelle) == 1L)
vergleichsgrafik <- gtable::gtable_add_grob(
  vergleichsgrafik, lesehilfe_vergleich,
  t = freie_zelle$t, l = freie_zelle$l, b = freie_zelle$b, r = freie_zelle$r,
  clip = "off", name = "lesehilfe_vergleich"
)

speichern_16_9(vergleichsgrafik, "laender_gegen_regionaltrend")

# Datenexporte ------------------------------------------------------------
write_excel_csv2(
  regionen_anfang_ende |>
    select(region_code, region, startjahr, endjahr, quote_start, quote_ende,
           veraenderung_pp, veraenderung_prozent),
  file.path(output_dir, "frage1_grafikdaten_regionen.csv"), na = ""
)
write_excel_csv2(
  vergleich_alle |>
    mutate(region = str_replace_all(as.character(region), "\n", " ")),
  file.path(output_dir, "frage1_grafikdaten_laender.csv"), na = ""
)

print(p_regionen)
grid::grid.newpage()
grid::grid.draw(vergleichsgrafik)

# Alle drei Grafiken sind 16:9, PNG 3840 x 2160 Pixel; SVG optional.
# Objekte: praesentationsplot, p_regionen und vergleichsgrafik.
