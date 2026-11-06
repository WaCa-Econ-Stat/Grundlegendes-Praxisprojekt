prepare_data <- function(config) {
  files <- file.path("data", c("owid_poverty_lines.csv", "worldbank_pip.csv",
                               "owid_country_codes.csv", "owid_child_mortality.csv"))
  if (!all(file.exists(files))) stop("Eingabedatei fehlt: ", paste(files[!file.exists(files)], collapse = ", "))
  checksums <- data.table::data.table(file = files, md5 = unname(tools::md5sum(files)))
  data.table::fwrite(checksums, "output/results/input_checksums.csv")

  # Shared preparation from roterFaden; keep its three saved datasets unchanged.
  source("R/01_data_prep.R", local = new.env(parent = environment()), encoding = "UTF-8")
  surveys_all <- readRDS("data_clean/surveys.rds")
  aggregates <- readRDS("data_clean/aggregates.rds")
  china <- readRDS("data_clean/china.rds")
  assert_unique(surveys_all, c("country_code", "year", "welfare_type"), "Nationale Erhebungen")
  assert_unique(aggregates, c("region_name", "year"), "Aggregate")

  # Analysis interface: period, display metadata and aliases only. The OWID choice
  # and percentage values come directly from the shared preparation.
  regions <- region_dictionary()
  catalog <- unique(surveys_all[, .(country_code, country_name, region_code)])
  assert_unique(catalog, "country_code", "Nationale Länder")
  surveys <- data.table::copy(surveys_all[year >= config$start_year & year <= config$end_year])
  surveys[, poverty_pct := pct_below_3]
  data.table::setorder(surveys, country_code, welfare_type, year)
  selected <- data.table::copy(surveys[owid_selected == TRUE])
  assert_unique(selected, c("country_code", "year"), "Ausgewählte Länderreihe")

  world <- data.table::copy(aggregates[type == "world" & year >= config$start_year & year <= config$end_year])
  regional <- merge(aggregates[type == "region" & year >= config$start_year & year <= config$end_year],
                    regions[, .(region_code, region_de, color)], by = "region_code", all.x = TRUE)
  # Keep the established plotting names alongside the canonical pct_below_* names.
  pct_columns <- grep("^pct_below_", names(aggregates), value = TRUE)
  for (table in list(world, regional)) {
    for (column in pct_columns) table[, (sub("^pct_", "", column)) := get(column)]
  }
  assert_unique(regional, c("region_code", "year"), "Regionalaggregate")
  expected_years <- seq.int(config$start_year, config$end_year)
  stopifnot(setequal(world$year, expected_years),
            nrow(regional) == nrow(regions) * length(expected_years),
            setequal(regional$region_code, regions$region_code),
            !anyNA(regional$region_de), !anyNA(surveys$poverty_pct),
            all(surveys$poverty_pct >= 0 & surveys$poverty_pct <= 100))
  for (table in list(world, regional)) {
    bands <- as.matrix(table[, ..pct_columns])
    stopifnot(all(is.finite(bands)), all(bands >= 0 & bands <= 100),
              all(bands[, -1, drop = FALSE] - bands[, -ncol(bands), drop = FALSE] >= -1e-6))
  }

  data <- list(world = world, regional = regional, surveys = surveys, catalog = catalog,
               selected = selected, regions = regions, checksums = checksums,
               surveys_all = surveys_all, aggregates = aggregates, china = china)
  saveRDS(data, "data_clean/prepared_data.rds")
  data
}
