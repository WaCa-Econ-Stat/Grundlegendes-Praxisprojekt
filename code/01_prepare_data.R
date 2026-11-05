prepare_data <- function(config) {
  files <- file.path("data", c("owid_poverty_lines.csv", "worldbank_pip.csv", "owid_country_codes.csv"))
  if (!all(file.exists(files))) stop("Eingabedatei fehlt: ", paste(files[!file.exists(files)], collapse = ", "))
  checksums <- data.table::data.table(file = files, md5 = unname(tools::md5sum(files)))
  data.table::fwrite(checksums, "output/results/input_checksums.csv")
  owid <- data.table::fread(files[1], encoding = "UTF-8")
  pip <- data.table::fread(files[2], encoding = "UTF-8")
  codes <- data.table::fread(files[3], encoding = "UTF-8")
  regions <- region_dictionary()
  stopifnot(all(pip$poverty_line == 3), all(pip$headcount >= 0 & pip$headcount <= 1))
  assert_unique(codes, "entity", "Länderzuordnung")
  national <- pip[reporting_level == "national"]
  catalog <- unique(national[, .(country_code, country_name, region_code)])
  assert_unique(catalog, "country_code", "Nationale Länder")
  surveys <- data.table::copy(national[reporting_year >= config$start_year & reporting_year <= config$end_year])
  data.table::setnames(surveys, "reporting_year", "year")
  surveys[, poverty_pct := 100 * headcount]
  assert_unique(surveys, c("country_code", "year", "welfare_type"), "Nationale Erhebungen")
  data.table::setorder(surveys, country_code, welfare_type, year)

  data.table::setnames(owid, c("Country", "Year"), c("entity", "year"))
  poverty_columns <- c("Share below $1 a day", "Share below $3 a day", "Share below $4.20 a day",
                       "Share below $8.30 a day", "Share below $10 a day", "Share below $20 a day",
                       "Share below $30 a day", "Share below $40 a day")
  data.table::setnames(owid, poverty_columns, c("below_1", "below_3", "below_4_20", "below_8_30",
                                             "below_10", "below_20", "below_30", "below_40"))
  owid <- owid[year >= config$start_year & year <= config$end_year]
  assert_unique(owid, c("entity", "year"), "OWID-Reihen")
  world <- owid[entity == "World"]
  regional <- merge(owid, regions, by.x = "entity", by.y = "owid_name")
  assert_unique(regional, c("region_code", "year"), "Regionalaggregate")
  expected_years <- seq.int(config$start_year, config$end_year)
  stopifnot(setequal(world$year, expected_years),
            nrow(regional) == 7L * length(expected_years),
            setequal(regional$region_code, regions$region_code))
  for (column in c("below_1", "below_3", "below_4_20", "below_8_30", "below_10", "below_20", "below_30", "below_40")) {
    stopifnot(all(is.finite(owid[[column]])), all(owid[[column]] >= 0 & owid[[column]] <= 100))
  }
  bands <- as.matrix(owid[, .(below_1, below_3, below_4_20, below_8_30, below_10, below_20, below_30, below_40)])
  stopifnot(all(bands[, -1, drop = FALSE] - bands[, -ncol(bands), drop = FALSE] >= -1e-6))

  # Identify the actual OWID survey choice rather than averaging two methods.
  codes[code == "OWID_KOS", code := "XKX"]
  national_owid <- merge(owid[!grepl("\\((urban|rural)\\)$", entity)], codes, by = "entity")
  national_owid <- national_owid[code %in% catalog$country_code]
  matches <- merge(national_owid[, .(country_code = code, year, below_3)],
                   surveys[, .(country_code, year, welfare_type, poverty_pct)], by = c("country_code", "year"))
  matches <- matches[abs(below_3 - poverty_pct) < 1e-4]
  assert_unique(matches, c("country_code", "year"), "OWID-Erhebungsauswahl")
  unmatched <- national_owid[!matches, on = .(code = country_code, year)]
  if (nrow(unmatched)) stop("Nationale OWID-Werte ohne eindeutige PIP-Zuordnung: ", nrow(unmatched))
  selected <- merge(surveys, matches[, .(country_code, year, welfare_type)],
                    by = c("country_code", "year", "welfare_type"))
  assert_unique(selected, c("country_code", "year"), "Ausgewählte Länderreihe")
  data <- list(world = world, regional = regional, surveys = surveys, catalog = catalog,
               selected = selected, regions = regions, checksums = checksums)
  saveRDS(data, "data_clean/prepared_data.rds")
  data
}
