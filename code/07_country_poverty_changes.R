# Rubin's first/last survey comparison, without random replacements for zero rates.
make_country_poverty_changes <- function(analysis, version, config) {
  changes <- copy(analysis$changes[included == TRUE])
  selected_codes <- c("SDN", "NPL", "PAK", "YEM", "PER", "TJK", "UZB", "FSM", "CHN", "IDN")
  labels <- changes[country_code %in% selected_codes]
  setorder(labels, annual_change_pp)
  labels[, label_offset := if (.N == 1L) 0 else seq(-.32, .32, length.out = .N), by = region_name]
  labels[, label_hjust := ifelse(annual_change_pp < 0, 1, 0)]
  paper <- version == "paper"
  if (!paper) {
    p <- ggplot(changes, aes(x = annual_change_share, color = region_name)) +
      geom_boxplot() + theme_minimal() +
      labs(title = "Regional outliers in poverty reduction",
           x = "Poverty change in percentage points per year", y = "Region") +
      geom_vline(xintercept = 0, linetype = "dashed", color = "purple") +
      scale_color_discrete(name = "Regions") +
      scale_x_continuous(labels = scales::label_number(scale = 100, accuracy = .1),
                         expand = expansion(mult = c(.23, .23)))

    # Use the box positions computed by ggplot, not hand-entered country coordinates.
    built <- ggplot_build(p)
    boxes <- built$data[[1]]
    scale <- built$plot$scales$get_scales("colour")
    labels[, y := boxes$y[match(scale$map(region_name), boxes$colour)]]
    labels[, label_x := annual_change_share + ifelse(annual_change_share < 0, -.008, .008)]
    labels[, label_y := y + label_offset / 8]
    p <- p + geom_point(data = labels, aes(annual_change_share, y), size = 1.7, show.legend = FALSE) +
      geom_segment(data = labels, aes(x = label_x, y = label_y, xend = annual_change_share, yend = y),
                    color = "grey30", linewidth = .3,
                    arrow = grid::arrow(length = grid::unit(.10, "cm"), type = "closed"), show.legend = FALSE) +
      geom_text(data = labels, aes(label_x, label_y, label = country_name, hjust = label_hjust),
                 color = "grey20", size = 3, show.legend = FALSE)
  } else {
    region_order <- rev(names(config$paper_region_colors))
    region_order <- region_order[region_order %in% changes$region_name]
    changes[, region := factor(region_name, levels = region_order)]
    labels[, region := factor(region_name, levels = levels(changes$region))]
    changes[, region_index := as.numeric(region)]
    labels[, region_index := as.numeric(region)]
    labels[, `:=`(label_y = region_index + ifelse(label_offset == 0, .35, label_offset),
                   label_x = annual_change_pp + ifelse(annual_change_pp < 0, -.45, .45))]
    p <- ggplot(changes, aes(annual_change_pp, region_index)) +
      geom_vline(xintercept = 0, color = "#60666D", linetype = "dashed", linewidth = .35) +
      geom_boxplot(aes(color = region_name, group = region_name), orientation = "y",
                     width = .5, outlier.shape = NA, linewidth = .5, show.legend = FALSE) +
      geom_point(aes(color = region_name), position = position_jitter(width = 0, height = .07, seed = 42),
                  size = 1.3, alpha = .6, show.legend = FALSE) +
      geom_segment(data = labels, aes(x = label_x, y = label_y, xend = annual_change_pp, yend = region_index),
                     color = "#9DA4AB", linewidth = .3, show.legend = FALSE) +
      geom_label(data = labels, aes(label_x, label_y, label = country_name, hjust = label_hjust),
                   color = "#252A30", fill = "white", linewidth = 0, label.padding = grid::unit(.08, "lines"),
                   size = 2.7, show.legend = FALSE) +
      scale_color_manual(values = config$paper_region_colors) +
      scale_y_continuous(breaks = seq_along(levels(changes$region)),
                           labels = vapply(levels(changes$region), function(z) paste(strwrap(z, width = 25), collapse = "\n"), character(1))) +
      scale_x_continuous(expand = expansion(mult = c(.23, .23))) +
      labs(title = "Country differences in the pace of poverty reduction",
           subtitle = "First to last available national consumption survey; below 3 international dollars a day",
           x = "Annual change (percentage points)", y = NULL,
           caption = source_caption(config)) + paper_theme()
  }
  name <- "slide_10_country_poverty_changes"
  write_plot_data(changes, name)
  export_figure(p, name, 10L, version, config, width = if (paper) 8.5 else 12,
                height = if (paper) 6.4 else 7,
                note = "First/last national consumption surveys; periods vary and may cross comparability breaks. Zero-span countries excluded; zero poverty rates retained. Labels use current data. Axis values are percentage points per year.")
}
