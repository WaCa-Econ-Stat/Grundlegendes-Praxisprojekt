# Project settings live here so both figure versions use the same data.
setup_project <- function() {
  required_packages <- c(
    "data.table", "ggplot2", "scales", "jsonlite"
  )
  missing <- required_packages[
    !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
  ]
  if (length(missing)) {
    stop("Missing packages: ", paste(missing, collapse = ", "),
         ". Restore the project library with renv::restore() before running the pipeline.")
  }
  suppressPackageStartupMessages({
    library(data.table)
    library(ggplot2)
  })
  options(stringsAsFactors = FALSE, scipen = 999)

  folders <- c("data_clean", "output/figures/original", "output/figures/paper",
               "output/figures/original/supplement", "output/figures/paper/supplement",
               "output/results")
  invisible(lapply(folders, dir.create, recursive = TRUE, showWarnings = FALSE))

  list(
    analysis_start = 1990L,
    observed_end = 2024L,
    forecast_end = 2026L,
    snapshot_year = 2024L,
    band_years = c(2002L, 2020L),
    map_file = "data/maps/ne_50m_admin_0_countries.geojson",
    region_labels = c(
      "Sub-Saharan Africa" = "Afrika südlich der Sahara",
      "South Asia" = "Südasien",
      "East Asia & Pacific" = "Ostasien und Pazifik",
      "Middle East, North Africa, Afghanistan & Pakistan" =
        "Nahost, Nordafrika,\nAfghanistan und Pakistan",
      "Latin America & Caribbean" = "Lateinamerika und Karibik",
      "Europe & Central Asia" = "Europa und Zentralasien",
      "North America" = "Nordamerika"
    ),
    paper_region_colors = c(
      "East Asia & Pacific" = "#1F4E79", "Europe & Central Asia" = "#8064A2",
      "Latin America & Caribbean" = "#D55E00",
      "Middle East, North Africa, Afghanistan & Pakistan" = "#A38700",
      "North America" = "#56B4E9", "South Asia" = "#009E73",
      "Sub-Saharan Africa" = "#8B1E3F"
    ),
    paper_method_colors = c(income = "#1F4E79", consumption = "#8B1E3F"),
    source_note = "Source: World Bank PIP (2026), processed by Our World in Data; project data extract."
  )
}
