# Derive plot inputs once, then share them between the original and paper versions.
build_analysis_data <- function(config) {
  check_files(c("data_clean/poverty_panel.rds", "data_clean/china_subnational.rds"))
  panel <- readRDS("data_clean/poverty_panel.rds")
  subnational <- readRDS("data_clean/china_subnational.rds")
  selected <- panel[data_source == "both"]
  surveys <- panel[data_source != "owid"]
  regions <- panel[is_region == TRUE]
  world <- panel[owid_country_name == "World"]
  check_unique(selected, c("country_code", "year"), "OWID-selected surveys")
  check_unique(surveys, c("country_code", "year", "welfare_type"), "All national surveys")

  method_surveys <- surveys[year >= config$analysis_start & year <= config$observed_end &
                               welfare_type %in% c("income", "consumption")]
  pair_columns <- c("country_code", "year", "country_name", "survey_poverty_pct", "survey_acronym",
                    "survey_year", "survey_comparability")
  pairs <- merge(method_surveys[welfare_type == "income", ..pair_columns],
                 method_surveys[welfare_type == "consumption", ..pair_columns],
                 by = c("country_code", "year"), suffixes = c("_income", "_consumption"))
  pairs[, difference_pp := survey_poverty_pct_income - survey_poverty_pct_consumption]
  stopifnot(nrow(pairs) > 0, all(pairs$country_name_income == pairs$country_name_consumption))
  german_names <- c(ALB = "Albanien", BGR = "Bulgarien", EST = "Estland", HRV = "Kroatien",
                    HTI = "Haiti", HUN = "Ungarn", LCA = "St. Lucia", LTU = "Litauen",
                    LVA = "Lettland", MNE = "Montenegro", NIC = "Nicaragua", PHL = "Philippinen",
                    POL = "Polen", ROU = "Rumänien", RUS = "Russland", SRB = "Serbien",
                    SVK = "Slowakei", TUR = "Türkei", XKX = "Kosovo")
  pairs[, country_de := unname(german_names[country_code])]
  pairs[is.na(country_de), country_de := country_name_income]
  method_countries <- pairs[, .(
    country = country_de[1], country_en = country_name_income[1], n_pairs = .N,
    median_pp = median(difference_pp), min_pp = min(difference_pp), max_pp = max(difference_pp),
    period = paste(unique(range(year)), collapse = "–")
  ), by = country_code][order(median_pp, country_code)]

  # Keep Rubin's first/last consumption-survey comparison, including its varying periods.
  changes <- surveys[welfare_type == "consumption"][order(year), .(
    country_name = country_name[1], region_name = region_name[1],
    start_year = head(year, 1), end_year = tail(year, 1),
    start_share = head(headcount, 1), end_share = tail(headcount, 1),
    start_comparability = head(survey_comparability, 1), end_comparability = tail(survey_comparability, 1)
  ), by = country_code]
  changes[, years_elapsed := end_year - start_year]
  changes[, comparable_endpoints := !is.na(start_comparability) & !is.na(end_comparability) &
            start_comparability == end_comparability]
  changes[, annual_change_pp := fifelse(years_elapsed > 0, 100 * (end_share - start_share) / years_elapsed, NA_real_)]
  changes[, annual_change_share := annual_change_pp / 100]
  changes[, included := years_elapsed > 0 & is.finite(annual_change_pp)]

  china_columns <- c("country_code", "year", "reporting_level", "welfare_type", "survey_comparability",
                      "headcount", "gini", "mld", "reporting_pop", "reporting_gdp")
  china <- rbindlist(list(surveys[country_code == "CHN", ..china_columns], subnational[, ..china_columns]))
  setorder(china, reporting_level, year)
  check_unique(china, c("year", "reporting_level"), "China observations")
  china_wide <- dcast(china, year ~ reporting_level, value.var = c("reporting_pop", "mld"))
  stopifnot(all(abs(china_wide$reporting_pop_national - china_wide$reporting_pop_rural -
                      china_wide$reporting_pop_urban) < .01))
  china_wide[, rural_share := reporting_pop_rural / reporting_pop_national]
  china_wide[, urban_share := reporting_pop_urban / reporting_pop_national]
  china_wide[, mld_within := mld_rural * rural_share + mld_urban * urban_share]
  china_wide[, mld_between := mld_national - mld_within]
  china_wide[, share_between := mld_between / mld_national]
  china <- merge(china, china_wide[, .(year, rural_share, urban_share)], by = "year")
  china[, population_share := fifelse(reporting_level == "rural", rural_share,
                                     fifelse(reporting_level == "urban", urban_share, 1))]
  gdp_reference <- max(china[reporting_level == "national", reporting_gdp], na.rm = TRUE)
  china[, gdp_index := reporting_gdp / gdp_reference]

  write_result(pairs, "survey_method_pairs")
  write_result(method_countries, "survey_method_summary")
  write_result(changes, "country_poverty_changes")
  write_result(china, "china_indicators")
  write_result(china_wide, "china_inequality_decomposition")
  diagnostics <- data.frame(
    check = c("panel_rows", "china_subnational_rows", "owid_selected_rows", "national_survey_rows",
              "regional_series", "paired_survey_years", "paired_countries", "zero_span_countries",
              "changed_comparability_endpoints", "china_gdp_reference"),
    value = c(nrow(panel), nrow(subnational), nrow(selected), nrow(surveys),
              uniqueN(regions$region_name), nrow(pairs), nrow(method_countries),
              sum(!changes$included), sum(!changes$comparable_endpoints), gdp_reference)
  )
  write_result(diagnostics, "data_checks")
  analysis <- list(panel = panel, selected = selected, surveys = surveys, regions = regions,
                   world = world, method_pairs = pairs, method_countries = method_countries,
                   changes = changes, china = china, china_inequality = china_wide,
                   diagnostics = diagnostics)
  saveRDS(analysis, "data_clean/analysis_data.rds")
  analysis
}
