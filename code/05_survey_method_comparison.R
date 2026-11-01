# Compare income and consumption within the same country and reporting year.
make_survey_method_comparison <- function(analysis, version, config) {
  pairs <- as.data.frame(analysis$method_pairs)
  countries <- as.data.frame(analysis$method_countries)
  selected_codes <- c("POL", "ROU", "PHL", "NIC")
  selected_labels <- c("Polen", "Rumänien", "Philippinen", "Nicaragua")
  income_col <- "#1F4E79"
  consumption_col <- "#8B1E3F"
  ink <- "#252A30"
  grid_color <- "#E5E7EA"

  draw_countries <- function() {
    par(family = "Arial", fg = ink, mar = c(0, 0, 0, 0), cex = 1, xaxs = "i", yaxs = "i")
    yy <- seq(.890, .190, length.out = nrow(countries))
    xx <- function(x) .275 + (x + 12) / 39 * .520
    plot.new()
    plot.window(xlim = c(0, 1), ylim = c(0, 1))
    ticks <- c(-10, 0, 10, 20)
    segments(xx(ticks), .160, xx(ticks), .920, col = grid_color, lwd = .65)
    segments(xx(0), .160, xx(0), .920, col = "#70757C", lty = 2, lwd = 1)
    segments(xx(-12), .160, xx(27), .160, col = "#A0A5AB", lwd = .7)
    segments(xx(ticks), .160, xx(ticks), .152, col = "#A0A5AB", lwd = .7)
    text(xx(ticks), .129, c("−10", "0", "+10", "+20"), cex = 1)
    for (j in seq_len(nrow(countries))) {
      z <- pairs[pairs$country_code == countries$country_code[j], ]
      segments(xx(countries$min_pp[j]), yy[j], xx(countries$max_pp[j]), yy[j], col = "#AAB0B7", lwd = 1.5)
      points(xx(z$difference_pp), rep(yy[j], nrow(z)), pch = 1, cex = .85, col = "#9DA4AB", lwd = .8)
      color <- if (countries$median_pp[j] < 0) consumption_col else income_col
      points(xx(countries$median_pp[j]), yy[j], pch = 18, cex = 1.5, col = color)
      text(.245, yy[j], countries$country[j], adj = 1, cex = 15 / 12)
      text(.830, yy[j], countries$n_pairs[j], cex = 13 / 12)
      text(.870, yy[j], countries$period[j], adj = 0, cex = 13 / 12, col = "#70757C")
    }
    text(.245, .965, "Land", adj = 1, font = 2, cex = 15 / 12)
    text(.830, .965, "n", font = 2, cex = 14 / 12)
    text(.870, .965, "Zeitraum", adj = 0, font = 2, cex = 14 / 12)
    text(xx(-6), .965, "Konsumquote\nhöher", col = consumption_col, cex = 14 / 12)
    text(xx(14), .965, "Einkommensquote\nhöher", col = income_col, cex = 14 / 12)
    bounds <- c(left = grconvertX(xx(-12), "user", "inches"),
                right = grconvertX(xx(27), "user", "inches"),
                bottom = grconvertY(.160, "user", "inches"), top = grconvertY(.920, "user", "inches"))
    axis_text(bounds, x = "Einkommen − Konsum (Prozentpunkte)")
    position <- method_legend_position(bounds)
    labels <- c("Median", "Einzelnes Jahr", "Minimum–Maximum")
    legend(position[["x"]], position[["y"]], legend = labels,
           col = c(ink, "#9DA4AB", "#AAB0B7"), pch = c(18, 1, NA), pt.cex = c(1.5, .85, 1),
           lty = c(0, 0, 1), lwd = c(1, .8, 1.5), seg.len = c(0, 0, 1.5), merge = FALSE,
           cex = 15 / 12, text.width = strwidth(labels, cex = 15 / 12) + c(.012, .012, 0),
           x.intersp = c(1.05, .92, .75), xjust = .5, yjust = .5, horiz = TRUE, bty = "n", xpd = NA)
  }
  draw_trends <- function() {
    start_method_panels()
    ymax <- c(3.2, 12, 32, 52)
    yticks <- list(0:3, seq(0, 12, 4), seq(0, 30, 10), seq(0, 50, 10))
    frames <- list()
    for (j in seq_along(selected_codes)) {
      z <- pairs[pairs$country_code == selected_codes[j], ]
      z <- z[order(z$year), ]
      stopifnot(nrow(z) > 0, max(z$survey_poverty_pct_income, z$survey_poverty_pct_consumption) <= ymax[j])
      plot(NA, xlim = c(1990, 2025), ylim = c(0, ymax[j]), axes = FALSE, xlab = "", ylab = "")
      abline(h = yticks[[j]], col = grid_color, lwd = .6)
      axis(1, at = c(1995, 2005, 2015, 2025), cex.axis = 1, col = "#A0A5AB", col.ticks = "#A0A5AB")
      axis(2, at = yticks[[j]], las = 1, cex.axis = 1, col = "#A0A5AB", col.ticks = "#A0A5AB")
      for (method in c("income", "consumption")) {
        color <- if (method == "income") income_col else consumption_col
        shape <- if (method == "income") 16 else 15
        value <- z[[paste0("survey_poverty_pct_", method)]]
        lines(z$year, value, col = color, lwd = 2, lty = 1)
        points(z$year, value, col = color, pch = shape, cex = .85, xpd = NA)
      }
      mtext(selected_labels[j], side = 3, line = .65, adj = 0, font = 2, cex = 16 / 12)
      frames[[j]] <- panel_bounds()
    }
    position <- method_legend_position(finish_method_panels(frames))
    legend(position[["x"]], position[["y"]], legend = c("Einkommen", "Konsum"),
           col = c(income_col, consumption_col), pch = c(16, 15), lty = 1, lwd = 2,
           pt.cex = .85, cex = 15 / 12,
           text.width = strwidth(c("Einkommen", "Konsum"), cex = 15 / 12) + c(.014, 0),
           x.intersp = .7, xjust = .5, yjust = .5, horiz = TRUE, bty = "n", xpd = NA)
  }
  country_plot <- draw_countries
  trend_plot <- draw_trends
  if (version == "paper") {
    countries$country_en <- factor(countries$country_en, levels = countries$country_en)
    pairs$country_en <- factor(pairs$country_name_income, levels = levels(countries$country_en))
    country_plot <- ggplot(countries, aes(median_pp, country_en)) +
      geom_vline(xintercept = 0, color = "#60666D", linetype = "dashed", linewidth = .35) +
      geom_segment(aes(x = min_pp, xend = max_pp, yend = country_en), color = "#AAB0B7", linewidth = .6) +
      geom_point(data = pairs, aes(difference_pp, country_en), shape = 1, size = 1.4, color = "#9DA4AB") +
      geom_point(aes(color = ifelse(median_pp < 0, "consumption", "income")), shape = 18, size = 2.8) +
      scale_color_manual(values = config$paper_method_colors, guide = "none") +
      labs(title = "Income and consumption can give different poverty rates",
           subtitle = "Country-year pairs, 1990–2024; poverty below 3 international dollars a day",
           x = "Income minus consumption (percentage points)", y = NULL,
           caption = source_caption(config)) + paper_theme()
    trends <- melt(as.data.table(pairs)[country_code %in% selected_codes],
                    id.vars = c("country_code", "year", "country_name_income"),
                    measure.vars = c("survey_poverty_pct_income", "survey_poverty_pct_consumption"),
                    variable.name = "method", value.name = "poverty_pct")
    trends[, method := sub("survey_poverty_pct_", "", method)]
    trends[, country := factor(country_name_income, levels = c("Poland", "Romania", "Philippines", "Nicaragua"))]
    trend_plot <- ggplot(trends, aes(year, poverty_pct, color = method, shape = method)) +
      geom_line(linewidth = .55) + geom_point(size = 1.6) +
      facet_wrap(~ country, ncol = 2, scales = "free_y") +
      scale_color_manual(values = config$paper_method_colors, labels = c(consumption = "Consumption", income = "Income")) +
      scale_shape_manual(values = c(consumption = 15, income = 16), labels = c(consumption = "Consumption", income = "Income")) +
      labs(title = "The size of the survey difference varies over time", x = NULL, y = "Population (%)",
           caption = source_caption(config)) + paper_theme()
  }
  paper <- version == "paper"
  note <- "Income and consumption paired within country-year, 1990–2024. Samples may differ; this is not a causal method comparison."
  write_plot_data(pairs[pairs$country_code %in% selected_codes, ], "slide_08_survey_method_examples")
  rbind(
    export_figure(country_plot, "slide_07_survey_method_comparison", 7L, version, config,
                   width = if (paper) 8.5 else 16, height = if (paper) 6.5 else 9,
                   dpi = if (paper) 300 else 600, note = note),
    export_figure(trend_plot, "slide_08_survey_method_examples", 8L, version, config,
                   width = if (paper) 8.5 else 16, height = if (paper) 5.8 else 9,
                   dpi = if (paper) 300 else 600, note = paste(note, "Lines connect pair-years across survey breaks."))
  )
}
