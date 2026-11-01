# Regional figures retain the two contributors' different views of the same data.
make_regional_poverty_trends <- function(analysis, version, config) {
  start_year <- config$analysis_start
  end_year <- config$observed_end
  paper <- version == "paper"
  regional <- copy(analysis$regions[year >= start_year & year <= end_year])
  countries <- copy(analysis$selected[year >= start_year & year <= end_year])
  regional[, region := factor(config$region_labels[region_name], levels = config$region_labels)]
  countries[, region := factor(config$region_labels[region_name], levels = config$region_labels)]
  countries[, n_values := sum(!is.na(share_below_3_pct)), by = country_code]
  endpoints <- regional[year == end_year]
  endpoints[, label := scales::label_number(accuracy = .1, decimal.mark = ",", suffix = " %")(share_below_3_pct)]
  ticks <- seq(start_year, end_year, by = 10)
  ticks <- sort(unique(c(ticks[ticks <= end_year - 7], end_year)))

  # This is the supplied 1.R figure; its original theme and annotations are retained.
  p <- ggplot() +
    geom_line(data = countries[n_values >= 2], aes(year, share_below_3_pct, group = country_code),
              colour = "grey35", linewidth = .45, alpha = .30, na.rm = TRUE) +
    geom_point(data = countries[n_values == 1], aes(year, share_below_3_pct),
               colour = "grey35", alpha = .30, size = 1.3, na.rm = TRUE) +
    geom_line(data = regional, aes(year, share_below_3_pct, group = region),
              colour = "grey12", linewidth = 1.15, lineend = "round", na.rm = TRUE) +
    geom_point(data = endpoints, aes(year, share_below_3_pct), colour = "grey12", size = 2.1) +
    geom_text(data = endpoints, aes(year + .9, share_below_3_pct, label = label),
              hjust = 0, vjust = .35, size = 3.8, fontface = "bold", colour = "grey12") +
    facet_wrap(vars(region), ncol = 4, scales = "fixed", axes = "all", axis.labels = "all") +
    scale_x_continuous(breaks = ticks, limits = c(start_year, end_year + 8), expand = expansion(mult = c(.015, 0))) +
    scale_y_continuous(breaks = seq(0, 100, 25), labels = scales::label_percent(scale = 1, accuracy = 1),
                       limits = c(0, 100), expand = expansion(mult = c(.045, .025))) +
    labs(title = "Extreme Armut seit 1990",
         subtitle = sprintf("Anteil der Bevölkerung unter 3 int. Dollar pro Tag (Preise von 2021), %s–%s", start_year, end_year),
         x = NULL, y = NULL) +
    theme_minimal(base_size = 13, base_family = "sans") +
    theme(plot.title = element_text(face = "bold", size = 30, colour = "grey10", margin = margin(b = 7)),
          plot.subtitle = element_text(size = 15.5, colour = "grey35", margin = margin(b = 24)),
          plot.title.position = "plot",
          strip.text = element_text(face = "bold", size = 14, hjust = 0, vjust = 0, colour = "grey20",
                                    lineheight = 1.1, margin = margin(t = 0, b = 12)),
          strip.background = element_blank(), strip.placement = "outside",
          axis.text = element_text(colour = "grey40", size = 11.5),
          axis.text.x = element_text(margin = margin(t = 7)), axis.text.y = element_text(margin = margin(r = 5)),
          panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(colour = "grey92", linewidth = .35),
          panel.spacing.x = grid::unit(17, "pt"), panel.spacing.y = grid::unit(24, "pt"),
          plot.background = element_rect(fill = "white", colour = NA), plot.margin = margin(24, 26, 18, 22))
  if (paper) {
    p <- ggplot(countries, aes(year, share_below_3_pct)) +
      geom_line(aes(group = country_code), color = "#AAB0B7", linewidth = .25, alpha = .4) +
      geom_line(data = regional, aes(color = region_name), linewidth = .75) +
      facet_wrap(~ region_name, ncol = 3, labeller = label_wrap_gen(width = 25)) +
      scale_color_manual(values = config$paper_region_colors, guide = "none") +
      scale_y_continuous(limits = c(0, 100), breaks = c(0, 50, 100)) +
      scale_x_continuous(breaks = c(1990, 2005, 2024)) +
      labs(title = "Regional paths out of extreme poverty", subtitle = "Below 3 international dollars a day, 1990–2024",
           x = NULL, y = "Population (%)", caption = source_caption(config)) +
      paper_theme()
  }
  name <- "slide_05_regional_poverty_trends"
  write_plot_data(regional, name)
  write_plot_data(countries, "regional_country_series")
  output <- list(export_figure(p, name, 5L, version, config,
                               width = if (paper) 8.5 else 16, height = if (paper) 7 else 9,
                               dpi = if (paper) 300 else 240))

  # The opener plots include projections through 2026, shown as dashed lines.
  region_data <- analysis$regions[, .(year, region_name, share = share_below_3_pct)]
  world_data <- analysis$world[, .(year, share = share_below_3_pct)]
  selected <- analysis$selected
  pip_data <- analysis$surveys[, .(country_code, year, region_name, welfare_type, survey_comparability,
                                   share = survey_poverty_pct)]
  overview <- ggplot(region_data[year <= end_year], aes(year, share, colour = region_name)) +
    geom_line() + geom_line(data = region_data[year >= end_year], linetype = "dashed") +
    geom_line(data = world_data[year <= end_year], colour = "black", linewidth = 1) +
    geom_line(data = world_data[year >= end_year], colour = "black", linewidth = 1, linetype = "dashed") +
    coord_cartesian(xlim = c(start_year, config$forecast_end))
  country_overview <- ggplot(selected, aes(year, share_below_3_pct)) +
    geom_line(aes(group = country_code), colour = "grey") + geom_point(colour = "grey", size = .5) +
    geom_line(data = region_data[year <= end_year], aes(y = share), linewidth = 1) +
    geom_line(data = region_data[year >= end_year], aes(y = share), linewidth = 1, linetype = "dashed") +
    facet_wrap(~ region_name, nrow = 2, labeller = label_wrap_gen(width = 20)) +
    coord_cartesian(xlim = c(start_year, config$forecast_end))
  methods <- ggplot(pip_data, aes(year, share, colour = welfare_type)) +
    geom_line(aes(group = interaction(country_code, welfare_type, survey_comparability)), alpha = .6) +
    geom_point(size = .5, alpha = .6) +
    geom_line(data = region_data[year <= end_year], colour = "black", linewidth = 1) +
    geom_line(data = region_data[year >= end_year], colour = "black", linewidth = 1, linetype = "dashed") +
    scale_colour_manual(values = if (paper) config$paper_method_colors else c(income = "#4C72B0", consumption = "#C44E52"),
                         labels = if (paper) c(income = "Income", consumption = "Consumption") else waiver()) +
    facet_wrap(~ region_name, nrow = 2, labeller = label_wrap_gen(width = 20)) +
    coord_cartesian(xlim = c(start_year, config$forecast_end)) + theme(legend.position = "bottom")
  isolated <- copy(pip_data)
  isolated[, spell := interaction(country_code, welfare_type, survey_comparability)]
  isolated[, n_spell := .N, by = spell]
  methods_isolated <- ggplot(isolated, aes(year, share, colour = welfare_type)) +
    geom_line(data = isolated[n_spell > 1], aes(group = spell), linewidth = .3, alpha = .7) +
    geom_point(data = isolated[n_spell == 1], size = .8, alpha = .7) +
    geom_line(data = region_data[year <= end_year], colour = "black", linewidth = 1) +
    geom_line(data = region_data[year >= end_year], colour = "black", linewidth = 1, linetype = "dashed") +
    scale_colour_manual(values = if (paper) config$paper_method_colors else c(income = "#4C72B0", consumption = "#C44E52"),
                         labels = if (paper) c(income = "Income", consumption = "Consumption") else c(income = "Einkommen", consumption = "Konsum")) +
    facet_wrap(~ region_name, nrow = 2, labeller = label_wrap_gen(width = 20)) +
    coord_cartesian(xlim = c(start_year, config$forecast_end)) +
    labs(x = NULL, y = "% < $3 pro Tag", colour = "Erhebungsart") + theme_minimal() + theme(legend.position = "bottom")
  if (paper) {
    overview <- overview + scale_colour_manual(values = config$paper_region_colors) +
      labs(title = "Extreme poverty across world regions", x = NULL, y = "Population (%)",
           caption = source_caption(config)) +
      guides(colour = guide_legend(ncol = 2)) + paper_theme()
    restyle <- function(plot, title) {
      plot + facet_wrap(~ region_name, ncol = 3, labeller = label_wrap_gen(width = 25)) +
        labs(title = title, x = NULL, y = "Population (%)", colour = NULL,
             caption = source_caption(config)) + paper_theme()
    }
    methods <- restyle(methods, "Survey methods behind regional poverty trends")
    methods_isolated <- restyle(methods_isolated, "Comparable survey series and isolated observations")
    country_overview <- country_overview +
      facet_wrap(~ region_name, ncol = 3, labeller = label_wrap_gen(width = 25)) +
      labs(title = "Country surveys and regional estimates", x = NULL, y = "Population (%)",
           caption = source_caption(config)) + paper_theme()
  }
  output[[2]] <- export_figure(methods, "slide_06_regional_survey_methods", 6L, version, config,
                                width = if (paper) 8.5 else 16, height = if (paper) 7 else 9,
                                note = "The third opener plot; all national surveys, split by method and comparability. Dashed regional projections after 2024.")
  extras <- list(regional_world_overview = overview, regional_country_overview = country_overview,
                 regional_isolated_surveys = methods_isolated)
  for (extra in names(extras)) {
    output[[length(output) + 1L]] <- export_figure(extras[[extra]], extra, NA_integer_, version, config,
                                                  width = if (paper) 8.5 else 16,
                                                  height = if (paper) 7 else 9, supplement = TRUE,
                                                  note = "Additional view supplied in Opener Plots.R; projections after 2024 are dashed.")
  }
  write_plot_data(pip_data, "slide_06_regional_survey_methods")
  write_plot_data(rbind(region_data[, series := region_name], world_data[, `:=`(region_name = "World", series = "World")], fill = TRUE),
                  "regional_world_overview")
  do.call(rbind, output)
}
