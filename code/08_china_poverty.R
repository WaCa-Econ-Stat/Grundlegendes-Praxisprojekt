# Keep all four supplied China figures and export the additional MLD components plot.
make_china_poverty <- function(analysis, version, config) {
  china <- copy(analysis$china)
  national <- china[reporting_level == "national"]
  rural <- china[reporting_level == "rural"]
  inequality <- copy(analysis$china_inequality)
  paper <- version == "paper"
  macro <- melt(national, id.vars = c("year", "welfare_type", "survey_comparability"),
                measure.vars = c("headcount", "gini", "gdp_index"),
                variable.name = "variable", value.name = "value")
  macro[, variable := factor(variable, levels = c("gini", "headcount", "gdp_index"))]
  macro_plot <- ggplot(macro, aes(year, value, color = variable)) +
    geom_point() + geom_line() + theme_minimal() +
    labs(title = "Poverty in China", x = "Year", y = "value") +
    scale_color_discrete(name = NULL, labels = c(headcount = "Share below 3 int. dollars",
                                                gini = "Gini Index", gdp_index = "GDP"))
  crossing <- china[headcount < .01, .(first_year = min(year)), by = reporting_level]
  urban_crossing <- crossing[reporting_level == "urban", first_year]
  rural_crossing <- crossing[reporting_level == "rural", first_year]
  rural_urban_plot <- ggplot(china, aes(year, headcount, color = reporting_level)) +
    geom_point() + geom_line() + theme_minimal() +
    labs(title = "Poverty in China", x = "Year", y = "Value",
         subtitle = paste0("Urban crossed the 1% poverty threshold in ", urban_crossing,
                           ",\nrural in ", rural_crossing, "\n1% share in purple")) +
    geom_hline(yintercept = .01, linetype = "dashed", color = "purple") +
    scale_color_discrete(name = NULL, labels = c(national = "National", rural = "Rural", urban = "Urban"))
  urbanization <- melt(rural, id.vars = c("year", "welfare_type", "survey_comparability"),
                        measure.vars = c("headcount", "population_share"),
                        variable.name = "variable", value.name = "value")
  urbanization_plot <- ggplot(urbanization, aes(year, value, color = variable)) +
    geom_point() + geom_line() + theme_minimal() +
    labs(title = "Poverty reduction and urbanization in China", x = "Year", y = "Value") +
    scale_color_discrete(name = NULL, labels = c(headcount = "Share below 3 int. dollars",
                                                population_share = "Share living in rural areas"))
  between_plot <- ggplot(inequality, aes(year, share_between)) + geom_line() + geom_point() +
    theme_minimal() + labs(title = "Share of between-group MLD in China", x = "Year", y = "Share")
  components <- melt(inequality, id.vars = "year", measure.vars = c("mld_national", "mld_within", "mld_between"),
                     variable.name = "component", value.name = "value")
  components[, component := factor(component, levels = c("mld_between", "mld_national", "mld_within"))]
  components_plot <- ggplot(components, aes(year, value, color = component)) +
    geom_point() + geom_line() + theme_minimal() + labs(title = "MLD", x = "Year", y = "MLD")
  plot_data <- list(copy(macro), copy(china), copy(urbanization), copy(inequality), copy(components))

  if (paper) {
    # Separate the scales so GDP normalization cannot be mistaken for a poverty rate.
    macro[, indicator := factor(variable, levels = c("headcount", "gini", "gdp_index"),
                                 labels = c("Poverty rate (%)", "Gini index (0–100)", "GDP per capita\n(index, 2022 = 100)"))]
    macro[, value := value * 100]
    macro_plot <- ggplot(macro, aes(year, value)) +
      geom_vline(xintercept = 1988.5, linetype = "dotted", color = "#AAB0B7", linewidth = .35) +
      geom_line(aes(group = welfare_type), color = "#1F4E79", linewidth = .6) +
      geom_point(color = "#1F4E79", size = 1.4) +
      facet_wrap(~ indicator, nrow = 1, scales = "free_y") +
      scale_x_continuous(breaks = c(1981, 2000, 2022)) +
      labs(title = "Poverty, inequality and growth in China", subtitle = "National survey observations, 1981–2022",
           x = NULL, y = NULL, caption = source_caption(config)) + paper_theme()
    rural_urban_plot <- ggplot(china, aes(year, 100 * headcount, color = reporting_level, shape = reporting_level)) +
      geom_hline(yintercept = 1, color = "#60666D", linetype = "dashed", linewidth = .35) +
      geom_line(aes(group = interaction(reporting_level, welfare_type)), linewidth = .6) +
      geom_point(size = 1.5) +
      scale_color_manual(values = c(national = "#252A30", rural = "#8B1E3F", urban = "#1F4E79"),
                           labels = c(national = "National", rural = "Rural", urban = "Urban")) +
      scale_shape_manual(values = c(national = 16, rural = 15, urban = 17),
                           labels = c(national = "National", rural = "Rural", urban = "Urban")) +
      scale_y_continuous(breaks = seq(0, 100, 25)) +
      labs(title = "Urban and rural poverty fell at different times",
           subtitle = paste0("First observed below 1%: urban ", urban_crossing, "; rural ", rural_crossing),
           x = NULL, y = "Poverty rate (%)",
           caption = source_caption(config)) + paper_theme()
    urbanization_plot <- ggplot(urbanization, aes(year, value * 100, color = variable)) +
      geom_line(aes(group = interaction(variable, welfare_type)), linewidth = .6) + geom_point(size = 1.5) +
      scale_color_manual(values = c(headcount = "#8B1E3F", population_share = "#1F4E79"),
                           labels = c(headcount = "Rural poverty rate", population_share = "Rural population share")) +
      labs(title = "Rural poverty and urbanization in China", x = NULL, y = "Population (%)",
           caption = source_caption(config)) + paper_theme()
    between_plot <- ggplot(inequality, aes(year, 100 * share_between)) +
      geom_line(color = "#8B1E3F", linewidth = .6) + geom_point(color = "#8B1E3F", size = 1.5) +
      labs(title = "The urban–rural divide in China's inequality", x = NULL, y = "Share of total MLD (%)",
           caption = source_caption(config)) + paper_theme()
    components_plot <- ggplot(components, aes(year, value, color = component)) +
      geom_line(linewidth = .6) + geom_point(size = 1.5) +
      scale_color_manual(values = c(mld_national = "#252A30", mld_within = "#1F4E79", mld_between = "#8B1E3F"),
                           labels = c(mld_national = "Total", mld_within = "Within groups", mld_between = "Between groups")) +
      labs(title = "Within- and between-group inequality in China", x = NULL, y = "Mean log deviation (MLD)",
           caption = source_caption(config)) + paper_theme()
  }
  plots <- list(slide_11_china_poverty_inequality_growth = macro_plot,
                slide_12_china_urban_rural_poverty = rural_urban_plot,
                slide_13_china_poverty_urbanization = urbanization_plot,
                slide_14_china_between_group_inequality = between_plot,
                china_inequality_components = components_plot)
  output <- list()
  for (j in seq_along(plots)) {
    name <- names(plots)[j]
    write_plot_data(plot_data[[j]], name)
    output[[j]] <- export_figure(plots[[j]], name, if (j <= 4) 10L + j else NA_integer_, version, config,
                                  width = if (paper) 8.5 else 7,
                                  height = if (paper) { if (j == 1) 4.5 else 4.8 } else 7,
                                  supplement = j == 5,
                                  note = paste("China observations, 1981–2022. Income through 1987, consumption from 1990.",
                                               if (j == 1) "GDP divided by the national 2022 maximum, 11830.6." else ""))
  }
  write_result(crossing, "china_first_observed_below_one_percent")
  do.call(rbind, output)
}
