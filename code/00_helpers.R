assert_unique <- function(x, keys, label) {
  if (anyDuplicated(as.data.frame(x)[keys])) stop(label, ": doppelte Schlüssel (", paste(keys, collapse = ", "), ").")
  invisible(x)
}

write_table <- function(x, name) {
  data.table::fwrite(x, file.path("output/tables", paste0(name, ".csv")), na = "", bom = TRUE)
}

country_labels <- function(x) {
  de <- c(Albania = "Albanien", Bulgaria = "Bulgarien", Croatia = "Kroatien", Estonia = "Estland",
          Hungary = "Ungarn", Latvia = "Lettland", Lithuania = "Litauen", Montenegro = "Montenegro",
          Nicaragua = "Nicaragua", Philippines = "Philippinen", Poland = "Polen", Romania = "Rumänien",
          `Russian Federation` = "Russland", Russia = "Russland", Serbia = "Serbien",
          `Slovak Republic` = "Slowakei", Slovakia = "Slowakei",
          `St. Lucia` = "St. Lucia", `Saint Lucia` = "St. Lucia", `Türkiye` = "Türkei", Turkey = "Türkei", Kosovo = "Kosovo", Haiti = "Haiti",
          Georgia = "Georgien", `Kyrgyz Republic` = "Kirgisistan", Kyrgyzstan = "Kirgisistan", `Viet Nam` = "Vietnam",
          Peru = "Peru", Paraguay = "Paraguay", Ecuador = "Ecuador", Zambia = "Sambia",
          Mozambique = "Mosambik", Nigeria = "Nigeria", Kenya = "Kenia", Uganda = "Uganda",
          Tanzania = "Tansania", Rwanda = "Ruanda", Malawi = "Malawi", Ghana = "Ghana",
          Madagascar = "Madagaskar", China = "China", Indonesia = "Indonesien", India = "Indien",
          Bangladesh = "Bangladesch", `Sri Lanka` = "Sri Lanka", Thailand = "Thailand",
          Armenia = "Armenien", Belarus = "Belarus", Ukraine = "Ukraine", Yemen = "Jemen",
          Uzbekistan = "Usbekistan", Tajikistan = "Tadschikistan", Sudan = "Sudan", Zimbabwe = "Simbabwe",
          `South Sudan` = "Südsudan", Senegal = "Senegal", Pakistan = "Pakistan")
  out <- unname(de[x])
  out[is.na(out)] <- x[is.na(out)]
  out
}

fmt <- function(x, digits = 1) formatC(x, format = "f", digits = digits, decimal.mark = ",", big.mark = ".")
percent_labels <- function(x) paste0(fmt(x, 0), " %")
wrap_caption <- function(x) paste(strwrap(x, width = 150), collapse = "\n")

analysis_theme <- function() {
  ggplot2::theme_minimal(base_size = 14, base_family = "sans") +
    ggplot2::theme(
      text = ggplot2::element_text(color = "#283545"),
      plot.title = ggplot2::element_text(size = 23, face = "bold", margin = ggplot2::margin(b = 9)),
      plot.subtitle = ggplot2::element_text(size = 12.5, lineheight = 1.2, margin = ggplot2::margin(b = 18)),
      plot.caption = ggplot2::element_text(size = 9, hjust = 0, color = "#586674", lineheight = 1.15,
                                         margin = ggplot2::margin(t = 17)),
      plot.title.position = "plot", plot.caption.position = "plot",
      axis.title = ggplot2::element_text(size = 12), axis.text = ggplot2::element_text(size = 11),
      panel.grid.minor = ggplot2::element_blank(), panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "#DFE4E8", linewidth = .3),
      strip.text = ggplot2::element_text(size = 12, face = "bold", hjust = 0, lineheight = 1.15),
      panel.spacing = grid::unit(1.5, "lines"),
      legend.title = ggplot2::element_blank(), legend.position = "bottom",
      legend.text = ggplot2::element_text(size = 11),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.margin = ggplot2::margin(18, 24, 18, 18)
    )
}

save_figure <- function(plot, name, config, width = 14, height = 8) {
  folder <- "output/figures"
  targets <- file.path(folder, paste0(name, c(".png", ".svg")))
  # Render into the local temporary directory before copying into Proton Drive.
  for (i in seq_along(targets)) {
    temporary <- tempfile(fileext = if (i == 1) ".png" else ".svg")
    if (i == 1) {
      device <- function(filename, width, height, bg, ...) {
        grDevices::png(filename, width = width, height = height, units = "in", res = config$dpi,
                       type = if (isTRUE(capabilities("aqua"))) "quartz" else "cairo", bg = bg)
      }
    } else device <- grDevices::svg
    ggplot2::ggsave(temporary, plot, width = width, height = height, bg = "white", device = device)
    copied <- file.copy(temporary, targets[i], overwrite = TRUE)
    unlink(temporary)
    if (!copied || !file.exists(targets[i]) || file.size(targets[i]) <= 0) stop("Export fehlgeschlagen: ", targets[i])
  }
  data.table::data.table(figure = name, png = targets[1], svg = targets[2], width = width, height = height)
}
