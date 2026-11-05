setup_project <- function(config = list()) {
  version <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  paths <- file.path(".Rlibrary", paste0("R-", version))
  if (.Platform$OS.type == "windows") {
    paths <- c(paths, file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library", version),
               file.path(Sys.getenv("USERPROFILE"), "AppData", "Local", "R", "win-library", version))
  }
  .libPaths(c(paths[dir.exists(paths)], .libPaths()))
  needed <- c("data.table", "ggplot2", "scales", "jsonlite")
  missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Fehlende Pakete: ", paste(missing, collapse = ", "),
                            ". Bitte zuerst source('restore_packages.R') ausführen.")
  suppressPackageStartupMessages({ library(data.table); library(ggplot2) })
  options(stringsAsFactors = FALSE, scipen = 999)
  defaults <- list(
    start_year = 1990L, end_year = 2024L,
    country_start = 2010L, country_end = 2020L, tolerance = 2L,
    min_span = 8L, min_surveys = 3L, coverage_start = 2015L,
    include_thresholds = TRUE, dpi = 180L,
    source = "Quelle: Weltbank PIP (2026), aufbereitet durch Our World in Data. Kursdatensatz."
  )
  unknown <- setdiff(names(config), names(defaults))
  if (length(unknown)) stop("Unbekannte Einstellungen: ", paste(unknown, collapse = ", "))
  config <- utils::modifyList(defaults, config)
  stopifnot(config$start_year < config$end_year, config$country_start < config$country_end,
            config$tolerance >= 0, config$min_span > 0, config$min_surveys >= 2,
            config$coverage_start >= config$start_year, config$coverage_start <= config$end_year)
  if (config$country_start - config$tolerance < config$start_year ||
      config$country_end + config$tolerance > config$end_year) {
    stop("Die Länderfenster müssen vollständig im Analysezeitraum liegen.")
  }
  for (folder in c("data_clean", "output/figures", "output/tables", "output/results")) {
    dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  }
  config
}

region_dictionary <- function() {
  data.table::data.table(
    region_code = c("EAS", "SAS", "SSF", "MEA", "LCN", "ECS", "NAC"),
    region_name = c("East Asia & Pacific", "South Asia", "Sub-Saharan Africa",
                    "Middle East, North Africa, Afghanistan & Pakistan",
                    "Latin America & Caribbean", "Europe & Central Asia", "North America"),
    owid_name = c("East Asia and Pacific (WB)", "South Asia (WB)", "Sub-Saharan Africa (WB)",
                  "Middle East, North Africa, Afghanistan and Pakistan (WB)",
                  "Latin America and Caribbean (WB)", "Europe and Central Asia (WB)", "North America (WB)"),
    region_de = c("Ostasien und Pazifik", "Südasien", "Afrika südlich der Sahara",
                  "Nahost, Nordafrika,\nAfghanistan und Pakistan", "Lateinamerika und Karibik",
                  "Europa und Zentralasien", "Nordamerika"),
    color = c("#39729E", "#B47728", "#8C4354", "#507D69", "#8667A2", "#588C99", "#927C5E")
  )
}
