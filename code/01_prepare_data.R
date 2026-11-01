# Adapted from To be merged/data_prep.R. Keep its OWID/PIP matching logic.
prepare_data <- function(config) {
  inputs <- file.path("data", c("owid_poverty_lines.csv", "worldbank_pip.csv", "owid_country_codes.csv"))
  check_files(inputs)
  owid <- fread(inputs[1], encoding = "UTF-8")
  pip <- fread(inputs[2], encoding = "UTF-8")
  codes <- fread(inputs[3], encoding = "UTF-8")
  setnames(owid, make.names(names(owid)))
  stopifnot(all(pip$poverty_line == 3), all(pip$headcount >= 0 & pip$headcount <= 1))
  check_unique(codes, "entity", "OWID country codes")

  owid[codes, on = .(Country = entity), code := i.code]
  owid[Country == "Kosovo", code := "XKX"]
  owid[code == "", code := NA_character_]

  # Split off China's subnational series before retaining national observations.
  china_owid <- owid[Country %in% c("China (urban)", "China (rural)")]
  china_owid[, `:=`(code = "CHN", reporting_level = sub("^China \\((.+)\\)$", "\\1", Country))]
  china <- merge(china_owid, pip[country_code == "CHN" & reporting_level != "national"],
                 by.x = c("code", "Year", "reporting_level"),
                 by.y = c("country_code", "reporting_year", "reporting_level"), all = TRUE)
  setnames(china, "welfare_type", "welfareType")
  stopifnot(!anyNA(china$Country), !anyNA(china$country_name),
            all(abs(china$Share.below..3.a.day - 100 * china$headcount) < 1e-4))

  owid <- owid[!grepl("\\((urban|rural)\\)$", Country)]
  pip <- pip[reporting_level == "national"]
  check_unique(owid, c("Country", "Year"), "OWID national observations")
  check_unique(pip, c("country_code", "reporting_year", "welfare_type"), "PIP national surveys")

  # OWID selects one survey per country-year. Match it by the three-dollar rate.
  matches <- merge(owid[, .(code, Year, share3 = Share.below..3.a.day)],
                   pip[, .(code = country_code, Year = reporting_year, welfare_type, headcount)],
                   by = c("code", "Year"))[abs(share3 - 100 * headcount) < 1e-4]
  check_unique(matches, c("code", "Year"), "OWID/PIP survey matches")
  owid[matches, on = .(code, Year), welfareType := i.welfare_type]
  full <- merge(owid, pip, by.x = c("code", "Year", "welfareType"),
                by.y = c("country_code", "reporting_year", "welfare_type"), all = TRUE)
  full[, source := fcase(!is.na(Country) & !is.na(country_name), "both",
                         !is.na(Country), "owid", default = "pip")]
  stopifnot(full[source == "owid" & grepl("^[A-Z]{3}$", code), .N] == 0)
  full[!is.na(code), countryName := fcoalesce(Country[!is.na(Country)][1],
                                              country_name[!is.na(country_name)][1]), by = code]
  full[is.na(code), countryName := Country]
  stopifnot(!anyNA(full$countryName), full[, uniqueN(code), by = countryName][, all(V1 == 1)])

  # Regional rates are published aggregates, never averages of country rates.
  full[grepl(" \\(WB\\)$", Country),
       region_name := gsub(" and ", " & ", sub(" \\(WB\\)$", "", Country))]
  full[!region_name %in% pip$region_name, region_name := NA_character_]
  full[, isRegion := source == "owid" & !is.na(region_name)]
  stopifnot(setequal(full[isRegion == TRUE, unique(region_name)], pip$region_name))
  china[, `:=`(countryName = "China", source = "both", isRegion = FALSE)]

  # Use one column vocabulary in every downstream script. Keep PIP metadata.
  normalize_names <- function(data) {
    old <- c("country_name", "Country", "countryName", "code", "Year", "welfareType", "source", "isRegion",
             "Share.below..1.a.day", "Share.below..3.a.day", "Share.below..4.20.a.day",
             "Share.below..8.30.a.day", "Share.below..10.a.day", "Share.below..20.a.day",
             "Share.below..30.a.day", "Share.below..40.a.day")
    new <- c("pip_country_name", "owid_country_name", "country_name", "country_code", "year", "welfare_type",
             "data_source", "is_region", "share_below_1_pct", "share_below_3_pct", "share_below_4_20_pct",
             "share_below_8_30_pct", "share_below_10_pct", "share_below_20_pct",
             "share_below_30_pct", "share_below_40_pct")
    setnames(data, old, new, skip_absent = TRUE)
    data[, survey_poverty_pct := 100 * headcount]
    setcolorder(data, c("country_name", "country_code", "year", "welfare_type", "data_source", "is_region"))
    setorder(data, country_name, year, welfare_type)
    data
  }
  full <- normalize_names(full)
  china <- normalize_names(china)
  saveRDS(full, "data_clean/poverty_panel.rds")
  saveRDS(china, "data_clean/china_subnational.rds")
  write_result(full[, .N, by = data_source], "data_source_counts")
  invisible(list(panel = full, china = china))
}
