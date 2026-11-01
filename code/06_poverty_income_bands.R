# Non-overlapping income bands from the supplied stacked-bar script.
make_poverty_income_bands <- function(analysis, version, config) {
  region_labels <- c("Sub-Saharan Africa" = "Subsahara-Afrika",
                     "Middle East, North Africa, Afghanistan & Pakistan" = "Naher Osten, Nordafrika, AFG & PAK",
                     "Latin America & Caribbean" = "Lateinamerika & Karibik", "South Asia" = "Südasien",
                     "East Asia & Pacific" = "Ostasien & Pazifik", World = "Welt",
                     "Europe & Central Asia" = "Europa & Zentralasien", "North America" = "Nordamerika")
  band_levels <- c("< $3", "$3-10", "$10-30", "> $30")
  bands <- analysis$panel[(is_region == TRUE | country_name == "World") & year %in% config$band_years,
                          .(region = fifelse(country_name == "World", "World", region_name), year,
                            `< $3` = share_below_3_pct,
                            `$3-10` = share_below_10_pct - share_below_3_pct,
                            `$10-30` = share_below_30_pct - share_below_10_pct,
                            `> $30` = 100 - share_below_30_pct)]
  check_unique(bands, c("region", "year"), "Regional income bands")
  stopifnot(nrow(bands) == length(config$band_years) * length(region_labels),
            all(abs(rowSums(bands[, ..band_levels]) - 100) < 1e-8),
            all(as.matrix(bands[, ..band_levels]) >= 0))
  bands <- melt(bands, id.vars = c("region", "year"), variable.name = "band")
  bands[, band := factor(band, levels = rev(band_levels))]
  bands[, region_en := region]
  bands[, region := factor(region_labels[region], levels = region_labels)]
  p <- ggplot(bands, aes(factor(year), value, fill = band)) +
    geom_col(width = .9) + facet_grid(~ region, switch = "x", labeller = label_wrap_gen(width = 15)) +
    scale_fill_manual(values = c(`< $3` = "#E04B4B", `$3-10` = "#FBBE82", `$10-30` = "#BCE1EA", `> $30` = "#5A97C9"),
                       breaks = band_levels) + scale_y_continuous(expand = c(0, 0)) +
    labs(x = NULL, y = "% der Bevölkerung", fill = NULL) + theme_minimal() +
    theme(strip.placement = "outside", panel.spacing.x = grid::unit(1, "lines"),
          panel.grid.major.x = element_blank(), legend.position = "top")
  if (version == "paper") {
    bands[, region_en := factor(region_en, levels = names(region_labels))]
    p <- ggplot(bands, aes(factor(year), value, fill = band)) +
      geom_col(width = .65, color = "white", linewidth = .15) +
      facet_wrap(~ region_en, ncol = 4, labeller = label_wrap_gen(width = 21)) +
      scale_fill_manual(values = c(`< $3` = "#8B1E3F", `$3-10` = "#D59AAA", `$10-30` = "#AEC6DA", `> $30` = "#1F4E79"),
                         breaks = band_levels) +
      scale_y_continuous(limits = c(0, 100), breaks = c(0, 50, 100), expand = expansion(mult = c(0, .015))) +
      labs(title = "Poverty reduction across the income distribution",
           subtitle = "Population shares in 2002 and 2020; international dollars per day, at 2021 prices",
           x = NULL, y = "Population (%)", caption = source_caption(config)) +
      paper_theme()
  }
  name <- "slide_09_poverty_income_bands"
  write_plot_data(bands, name)
  export_figure(p, name, 9L, version, config, width = if (version == "paper") 8.5 else 16,
                height = if (version == "paper") 6 else 9,
                note = "2002 versus 2020. Non-overlapping bands below 3, 3–10, 10–30, and above 30 international dollars a day (2021 prices).")
}
