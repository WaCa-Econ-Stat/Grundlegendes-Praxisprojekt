# Small helpers shared by the data and figure scripts.
check_files <- function(files) {
  missing <- files[!file.exists(files)]
  if (length(missing)) stop("Missing input files: ", paste(missing, collapse = ", "))
}

check_unique <- function(data, keys, name) {
  if (anyDuplicated(as.data.frame(data)[keys])) {
    stop(name, " has duplicate keys: ", paste(keys, collapse = ", "))
  }
}

write_result <- function(data, name) {
  data.table::fwrite(data, file.path("output/results", paste0(name, ".csv")), na = "")
}

paper_theme <- function() {
  theme_classic(base_size = 11, base_family = "Arial") +
    theme(
      text = element_text(color = "#252A30"),
      plot.title = element_text(face = "bold", size = 14, margin = margin(b = 7)),
      plot.subtitle = element_text(size = 10, lineheight = 1.15, margin = margin(b = 12)),
      plot.caption = element_text(size = 8, hjust = 0, color = "#60666D",
                                  lineheight = 1.15, margin = margin(t = 12)),
      plot.title.position = "plot", plot.caption.position = "plot",
      panel.grid.major.y = element_line(color = "#E5E7EA", linewidth = .25),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "#A0A5AB", linewidth = .3),
      axis.ticks = element_line(color = "#A0A5AB", linewidth = .3),
      axis.text = element_text(size = 9, color = "#4C535B"),
      axis.title = element_text(size = 10),
      strip.background = element_blank(), strip.text = element_text(face = "bold", size = 10),
      panel.spacing = grid::unit(1.1, "lines"),
      legend.position = "top", legend.title = element_blank(),
      legend.text = element_text(size = 9),
      plot.margin = margin(12, 14, 12, 12)
    )
}

source_caption <- function(config) {
  config$source_note
}

export_figure <- function(plot, name, slide, version, config,
                          width = 16, height = 9, dpi = 300, note = "",
                          supplement = FALSE) {
  folder <- file.path("output", "figures", version)
  if (supplement) folder <- file.path(folder, "supplement")
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(folder)) stop("Could not create figure folder: ", folder, call. = FALSE)
  target <- file.path(normalizePath(folder, winslash = "/", mustWork = TRUE), paste0(name, ".png"))
  if (dir.exists(target)) stop("Expected a PNG file, but found a directory: ", target, call. = FALSE)

  # Render locally before replacing a file in the synchronized output folder.
  temporary_png <- tempfile("poverty-figure-", fileext = ".png")
  on.exit(unlink(temporary_png), add = TRUE)
  if (is.function(plot)) {
    grDevices::png(temporary_png, width = width, height = height,
                   units = "in", res = dpi, pointsize = 12, type = "cairo", bg = "white")
    device <- grDevices::dev.cur()
    tryCatch(plot(), finally = {
      if (device %in% grDevices::dev.list()) grDevices::dev.off(device)
    })
  } else {
    # Slide headings are supplied by the presentation, not by the figure.
    plot <- plot + ggplot2::labs(title = NULL, subtitle = NULL) +
      ggplot2::theme(plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank())
    ggplot2::ggsave(temporary_png, plot, width = width, height = height,
                    dpi = dpi, bg = "white")
  }

  # Cloud synchronization or an image viewer may briefly hold the destination open.
  copied <- FALSE
  for (attempt in seq_len(5L)) {
    copied <- suppressWarnings(file.copy(temporary_png, target, overwrite = TRUE))
    if (isTRUE(copied)) break
    if (attempt < 5L) Sys.sleep(.25 * attempt)
  }
  if (!isTRUE(copied)) {
    stop("Could not write PNG: ", target,
         ". Close any app holding this file and check that the output folder is writable.", call. = FALSE)
  }
  data.frame(slide = slide, figure = name, version = version,
             role = if (supplement) "supplement" else "main",
             png = file.path(folder, paste0(name, ".png")),
             note = note, stringsAsFactors = FALSE)
}

write_plot_data <- function(data, name) {
  write_result(data, paste0(name, "_data"))
}

# These helpers preserve the layout of the two supplied base-R method figures.
panel_bounds <- function() {
  u <- par("usr")
  c(left = grconvertX(u[1], "user", "inches"),
    right = grconvertX(u[2], "user", "inches"),
    bottom = grconvertY(u[3], "user", "inches"),
    top = grconvertY(u[4], "user", "inches"))
}

axis_text <- function(bounds, x = NULL, y = NULL) {
  if (!is.null(x)) {
    text(grconvertX(mean(bounds[c("left", "right")]), "inches", "user"),
         grconvertY(bounds[["bottom"]] - 40 / 72, "inches", "user"),
         x, cex = 16 / 12, xpd = NA)
  }
  if (!is.null(y)) {
    text(grconvertX(bounds[["left"]] - 40 / 72, "inches", "user"),
         grconvertY(mean(bounds[c("bottom", "top")]), "inches", "user"),
         y, srt = 90, cex = 16 / 12, xpd = NA)
  }
}

method_legend_position <- function(bounds) {
  c(x = grconvertX(mean(bounds[c("left", "right")]), "inches", "user"),
    y = grconvertY(bounds[["bottom"]] - 70 / 72, "inches", "user"))
}

start_method_panels <- function() {
  layout(rbind(matrix(1:4, nrow = 2, byrow = TRUE), c(5, 5)), heights = c(1, 1, .4))
  par(family = "Arial", fg = "#252A30", col.axis = "#252A30", col.lab = "#252A30",
      cex = 1, mex = 1, oma = c(0, 1, .2, .2), mar = c(2.4, 4.3, 2.6, .8),
      mgp = c(1.8, .45, 0), tcl = -.2, xaxs = "i", yaxs = "i")
}

finish_method_panels <- function(frames) {
  b <- do.call(rbind, frames)
  bounds <- c(left = min(b[, "left"]), right = max(b[, "right"]),
              bottom = min(b[, "bottom"]), top = max(b[, "top"]))
  par(mar = c(0, 0, 0, 0))
  plot.new()
  plot.window(xlim = c(0, 1), ylim = c(0, 1))
  axis_text(bounds, x = "Jahr", y = "Armutsquote (%)")
  bounds
}
