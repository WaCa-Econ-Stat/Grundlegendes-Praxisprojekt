# Preserve the supplied world map, using published regional rates from the shared panel.
make_world_poverty_map <- function(analysis, version, config) {
  check_files(config$map_file)
  world <- jsonlite::fromJSON(config$map_file, simplifyVector = FALSE)$features
  world <- Filter(function(feature) feature$properties$REGION_WB != "Antarctica", world)
  regions <- data.frame(
    region_code = c("NAC", "LCN", "ECS", "MEA", "SSF", "SAS", "EAS"),
    entity = c("North America (WB)", "Latin America and Caribbean (WB)",
               "Europe and Central Asia (WB)",
               "Middle East, North Africa, Afghanistan and Pakistan (WB)",
               "Sub-Saharan Africa (WB)", "South Asia (WB)", "East Asia and Pacific (WB)"),
    label = c("Nordamerika", "Lateinamerika\nund Karibik", "Europa und\nZentralasien",
              "Nahost, Nordafrika,\nAfghanistan und Pakistan", "Afrika südlich der Sahara",
              "Südasien", "Ostasien und\nPazifik"),
    label_x = c(-2.45, -2.35, .35, -.65, .15, 1.35, 2.55),
    label_y = c(1.22, -.75, 1.55, .80, -1.00, -.65, .45),
    anchor_lon = c(-110, -65, 60, 42, 22, 80, 115),
    anchor_lat = c(43, -10, 53, 27, -5, 23, 23),
    line_x = c(-2.12, -1.87, .35, .08, .15, 1.35, 2.14),
    line_y = c(.99, -.78, 1.18, .48, -.87, -.50, .27)
  )
  current <- analysis$regions[year == config$snapshot_year]
  regions$poverty_pct <- current$share_below_3_pct[match(regions$entity, current$owid_country_name)]
  stopifnot(all(is.finite(regions$poverty_pct)), all(regions$poverty_pct >= 0 & regions$poverty_pct <= 50))
  country_regions <- unique(analysis$surveys[, .(country_code, region_code)])
  check_unique(country_regions, "country_code", "Map region assignments")
  fallback <- c("North America" = "NAC", "Latin America & Caribbean" = "LCN",
                "Europe & Central Asia" = "ECS", "Middle East & North Africa" = "MEA",
                "Sub-Saharan Africa" = "SSF", "South Asia" = "SAS", "East Asia & Pacific" = "EAS")

  # Natural Earth supplies a fallback where no national PIP survey is available.
  map_regions <- vapply(world, function(feature) {
    properties <- feature$properties
    code <- if (properties$WB_A3 != "-99") properties$WB_A3 else properties$ADM0_A3
    if (code == "KOS") code <- "XKX"
    region <- country_regions$region_code[match(code, country_regions$country_code)]
    if (is.na(region)) region <- unname(fallback[properties$REGION_WB])
    if (code %in% c("AFG", "PAK")) region <- "MEA"
    region
  }, character(1))
  stopifnot(!anyNA(map_regions), all(map_regions %in% regions$region_code))

  # Mollweide is an equal-area projection. The original map uses this implementation.
  project <- function(lon, lat) {
    lambda <- lon * pi / 180
    phi <- pmax(-89.999, pmin(89.999, lat)) * pi / 180
    theta <- phi
    for (j in 1:15) {
      theta <- theta - (2 * theta + sin(2 * theta) - pi * sin(phi)) / (2 + 2 * cos(2 * theta))
    }
    cbind(x = 2 * sqrt(2) / pi * lambda * cos(theta), y = sqrt(2) * sin(theta))
  }
  map_shapes <- lapply(world, function(feature) {
    geometry <- feature$geometry
    rings <- if (geometry$type == "Polygon") geometry$coordinates else do.call(c, geometry$coordinates)
    xy <- do.call(rbind, lapply(rings, function(ring) {
      xy <- matrix(unlist(ring), ncol = 2, byrow = TRUE)
      rbind(project(xy[, 1], xy[, 2]), c(NA_real_, NA_real_))
    }))
    xy[-nrow(xy), , drop = FALSE]
  })
  palette <- colorRampPalette(c("#F7EDF0", "#D59AAA", "#8B1E3F"), space = "Lab")(501)
  color_at <- function(x) palette[round(pmin(50, pmax(0, x)) * 10) + 1L]
  values <- regions$poverty_pct[match(map_regions, regions$region_code)]
  paper <- version == "paper"
  if (paper) {
    regions$label <- c("North America", "Latin America\n& Caribbean", "Europe &\nCentral Asia",
                       "Middle East, North Africa,\nAfghanistan & Pakistan", "Sub-Saharan Africa",
                       "South Asia", "East Asia &\nPacific")
  }
  draw <- function() {
    par(family = "Arial", mar = if (paper) c(1.7, .3, .3, .3) else c(.4, .3, .3, .3),
        fg = "#252A30", xaxs = "i", yaxs = "i")
    plot(NA, xlim = c(-3.35, 3.35), ylim = c(-1.78, 1.80),
         asp = 1, axes = FALSE, xlab = "", ylab = "")
    for (j in seq_along(map_shapes)) {
      xy <- map_shapes[[j]]
      polypath(xy[, 1], xy[, 2], col = color_at(values[j]), border = "white", lwd = .35, rule = "evenodd")
    }
    anchors <- project(regions$anchor_lon, regions$anchor_lat)
    segments(anchors[, 1], anchors[, 2], regions$line_x, regions$line_y, col = "#979196", lwd = .7)
    points(anchors[, 1], anchors[, 2], pch = 16, cex = .35, col = "#979196")
    for (j in seq_len(nrow(regions))) {
      label_lines <- strsplit(regions$label[j], "\n")[[1]]
      label_y <- regions$label_y[j] - (seq_along(label_lines) - 1) * .105
      text(regions$label_x[j], label_y, label_lines, cex = if (paper) 8 / 12 else 16 / 12)
      text(regions$label_x[j], tail(label_y, 1) - .16,
           paste0(formatC(regions$poverty_pct[j], format = "f", digits = 1,
                          decimal.mark = if (paper) "." else ","), " %"),
           cex = if (paper) 13 / 12 else 24 / 12, font = 2,
           col = if (regions$region_code[j] == "SSF") "#8B1E3F" else "#252A30")
    }
    x <- seq(-.95, .95, length.out = 502)
    rect(head(x, -1), -1.59, tail(x, -1), -1.51, col = palette, border = NA)
    text(0, -1.39, if (paper) "Regional poverty rate (%)" else
           paste0("Regionale Armutsquote ", config$snapshot_year, " (%)"),
         cex = if (paper) 8 / 12 else 14 / 12)
    text(seq(-.95, .95, length.out = 6), -1.69, seq(0, 50, 10), cex = if (paper) 8 / 12 else 1)
    if (paper) {
      mtext(config$source_note, side = 1, line = .5, adj = 0, cex = 7 / 12, col = "#60666D")
    }
  }
  name <- "slide_01_world_poverty_map"
  write_plot_data(regions, name)
  export_figure(draw, name, 1L, version, config, width = if (paper) 8.5 else 16,
                height = if (paper) 5.8 else 9, dpi = if (paper) 300 else 600,
                note = "Published regional estimates for 2024; below 3 international dollars a day (2021 PPP). Country shading represents its region.")
}
