# One row per country/method, including every exclusion reason.
endpoint_candidates <- function(surveys, config, tolerance = config$tolerance) {
  select_one <- function(z) {
    z <- z[order(year)]
    answer <- list(country_name = z$country_name[1], region_code = z$region_code[1],
                   start_year = NA_integer_, end_year = NA_integer_, start_pct = NA_real_,
                   end_pct = NA_real_, span = NA_integer_, n_surveys = 0L,
                   comparability = NA_real_, eligible = FALSE, reason = "")
    a <- z[abs(year - config$country_start) <= tolerance]
    b <- z[abs(year - config$country_end) <= tolerance]
    if (!nrow(a) || !nrow(b)) {
      answer$reason <- "Erhebung in mindestens einem Zeitfenster fehlt"
      return(answer)
    }
    a <- a[order(abs(year - config$country_start), year)][1]
    b <- b[order(abs(year - config$country_end), year)][1]
    middle <- z[year >= a$year & year <= b$year]
    answer$start_year <- a$year
    answer$end_year <- b$year
    answer$start_pct <- a$poverty_pct
    answer$end_pct <- b$poverty_pct
    answer$span <- as.integer(b$year - a$year)
    answer$n_surveys <- nrow(middle)
    answer$comparability <- as.numeric(a$survey_comparability)
    if (answer$span < config$min_span) answer$reason <- "Zeitspanne zu kurz"
    else if (nrow(middle) < config$min_surveys) answer$reason <- "Zu wenige Erhebungen im Intervall"
    else if (anyNA(middle$survey_comparability)) answer$reason <- "Vergleichbarkeitskennung fehlt"
    else if (data.table::uniqueN(middle$survey_comparability) != 1L) answer$reason <- "Vergleichbarkeitsbruch im Intervall"
    else if (!is.finite(a$poverty_pct) || !is.finite(b$poverty_pct)) answer$reason <- "Armutsquote fehlt"
    else { answer$eligible <- TRUE; answer$reason <- "Eingeschlossen" }
    answer
  }
  surveys[, select_one(.SD), by = .(country_code, welfare_type)]
}

choose_country_series <- function(candidates, selected, regional) {
  x <- data.table::copy(candidates[eligible == TRUE])
  if (!nrow(x)) stop("Keine vergleichbaren Länderreihen für die gewählten Fenster.")
  selected_key <- paste(selected$country_code, selected$year, selected$welfare_type)
  x[, owid_endpoints := as.integer(paste(country_code, start_year, welfare_type) %in% selected_key) +
                         as.integer(paste(country_code, end_year, welfare_type) %in% selected_key)]
  x[, available_methods := .N, by = country_code]
  # Prefer OWID at both endpoints, then the longest series and most observations.
  data.table::setorderv(x, c("country_code", "owid_endpoints", "span", "n_surveys", "welfare_type"), c(1, -1, -1, -1, 1))
  x <- x[, .SD[1], by = country_code]
  x[, selection_reason := data.table::fcase(
    available_methods == 1, "Einzige geeignete Reihe",
    owid_endpoints == 2, "OWID-Auswahl an beiden Endpunkten",
    default = "Längste geeignete Reihe, dann Anzahl Erhebungen, dann Methodenname")]
  regional_key <- paste(regional$region_code, regional$year)
  x[, regional_start_pct := regional$below_3[match(paste(region_code, start_year), regional_key)]]
  x[, regional_end_pct := regional$below_3[match(paste(region_code, end_year), regional_key)]]
  stopifnot(!anyNA(x$regional_start_pct), !anyNA(x$regional_end_pct))
  x[, change_pp := end_pct - start_pct]
  x[, annual_change_pp := change_pp / span]
  x[, regional_annual_change_pp := (regional_end_pct - regional_start_pct) / span]
  x[, deviation_pp_year := annual_change_pp - regional_annual_change_pp]
  x[, opposite_trend := annual_change_pp * regional_annual_change_pp < 0]
  x[, country_de := country_labels(country_name)]
  assert_unique(x, "country_code", "Ländervergleich")
  x
}

build_method_pairs <- function(surveys) {
  columns <- c("country_code", "year", "country_name", "region_code", "poverty_pct",
               "survey_acronym", "survey_year", "survey_coverage", "survey_comparability")
  pairs <- merge(surveys[welfare_type == "income", ..columns],
                 surveys[welfare_type == "consumption", ..columns],
                 by = c("country_code", "year"), suffixes = c("_income", "_consumption"))
  assert_unique(pairs, c("country_code", "year"), "Methodenpaare")
  stopifnot(all(pairs$country_name_income == pairs$country_name_consumption))
  pairs[, difference_pp := poverty_pct_income - poverty_pct_consumption]
  for (field in c("survey_acronym", "survey_year", "survey_coverage", "survey_comparability")) {
    a <- pairs[[paste0(field, "_income")]]
    b <- pairs[[paste0(field, "_consumption")]]
    pairs[, (paste0("same_", field)) := !is.na(a) & !is.na(b) & a == b]
  }
  pairs[, country_de := country_labels(country_name_income)]
  pairs
}

select_case_studies <- function(countries, sensitivity) {
  pool <- data.table::copy(countries)
  narrow <- sensitivity[tolerance == 1]
  # Keep the same welfare concept when testing sensitivity to endpoint windows.
  pool[, narrow_status := vapply(seq_len(.N), function(i) {
    z <- narrow[country_code == pool$country_code[i] & welfare_type == pool$welfare_type[i]]
    if (nrow(z) != 1L) "keine vergleichbare Reihe" else
      if (sign(z$annual_change_pp) == sign(pool$annual_change_pp[i])) "gleiche Richtung" else "andere Richtung"
  }, character(1))]
  pool[, stable_narrow := narrow_status == "gleiche Richtung"]
  choose <- function(candidates, order_column, decreasing = FALSE) {
    if (!nrow(candidates)) return(candidates)
    data.table::setorderv(candidates, c(order_column, "country_code"), c(if (decreasing) -1 else 1, 1))
    candidates[1]
  }
  decline <- choose(pool[annual_change_pp < 0], "annual_change_pp")
  decline[, case_role := "Starker Rückgang"]
  remaining <- pool[!country_code %in% decline$country_code]
  rise <- choose(remaining[annual_change_pp > 0], "annual_change_pp", TRUE)
  if (!nrow(rise)) {
    remaining[, distance_zero := abs(annual_change_pp)]
    rise <- choose(remaining, "distance_zero")
    rise[, case_role := "Stagnation"]
  } else rise[, case_role := "Anstieg"]
  remaining <- pool[!country_code %in% c(decline$country_code, rise$country_code)]
  # A rising case can already demonstrate an opposite regional trend. Then
  # use the third panel to show a different kind of regional deviation.
  contrast <- if (any(c(decline$opposite_trend, rise$opposite_trend))) remaining[0] else
    choose(remaining[opposite_trend == TRUE], "deviation_pp_year", TRUE)
  if (nrow(contrast)) contrast[, case_role := "Entgegen dem Regionaltrend"]
  else {
    remaining[, absolute_deviation := abs(deviation_pp_year)]
    contrast <- choose(remaining, "absolute_deviation", TRUE)
    contrast[, case_role := "Abweichung vom Regionaltrend"]
  }
  result <- data.table::rbindlist(list(decline, rise, contrast), fill = TRUE)
  stopifnot(nrow(result) == 3L, !anyDuplicated(result$country_code))
  result
}

build_analysis_data <- function(data, config) {
  candidates <- endpoint_candidates(data$surveys, config)
  countries <- choose_country_series(candidates, data$selected, data$regional)
  sensitivity <- data.table::rbindlist(lapply(sort(unique(c(0L, 1L, config$tolerance))), function(tol) {
    x <- endpoint_candidates(data$surveys, config, tol)
    if (!any(x$eligible)) return(NULL)
    x <- choose_country_series(x, data$selected, data$regional)
    x[, tolerance := tol]
    x
  }))
  cases <- select_case_studies(countries, sensitivity)
  coverage <- data.table::copy(data$catalog)
  latest <- data$surveys[year >= config$coverage_start, .(latest_year = max(year)), by = country_code]
  coverage <- merge(coverage, latest, by = "country_code", all.x = TRUE)
  coverage[, method := "Keine aktuelle Erhebung"]
  for (i in which(!is.na(coverage$latest_year))) {
    kinds <- data$surveys[country_code == coverage$country_code[i] & year == coverage$latest_year[i], welfare_type]
    coverage$method[i] <- if (all(c("income", "consumption") %in% kinds)) "Beide" else
      if (identical(kinds, "income")) "Einkommen" else if (identical(kinds, "consumption")) "Konsum" else
        stop("Unbekannte Erhebungsart.")
  }
  counts <- coverage[, .(n = .N), by = .(region_code, method)]
  counts[, region_n := sum(n), by = region_code]
  counts[, share_pct := 100 * n / region_n]
  pairs <- build_method_pairs(data$surveys)
  method_summary <- pairs[, .(country_de = country_de[1], n_pairs = .N,
                              start_year = min(year), end_year = max(year),
                              median_pp = median(difference_pp)), by = country_code]
  data.table::setorder(method_summary, median_pp, country_code)

  case_surveys <- merge(data$surveys, cases[, .(country_code, welfare_type, case_role)],
                        by = c("country_code", "welfare_type"))
  data.table::setorder(case_surveys, country_code, year)
  case_surveys[, spell := data.table::rleid(survey_comparability), by = country_code]
  case_surveys[is.na(survey_comparability), spell := -.I]
  case_surveys[, spell_n := .N, by = .(country_code, spell)]
  case_surveys[, country_de := country_labels(country_name)]
  case_regions <- merge(data$regional[, .(region_code, year, below_3)],
                        cases[, .(country_code, region_code, country_de, case_role)], by = "region_code", allow.cartesian = TRUE)
  output <- c(data, list(candidates = candidates, countries = countries, sensitivity = sensitivity,
                        cases = cases, coverage = coverage, coverage_counts = counts,
                        method_pairs = pairs, method_summary = method_summary,
                        case_surveys = case_surveys, case_regions = case_regions))
  tables <- c("candidates", "countries", "sensitivity", "cases", "coverage", "coverage_counts",
              "method_pairs", "method_summary", "case_surveys", "case_regions", "world", "regional")
  for (name in tables) write_table(output[[name]], name)
  audit <- data.table::data.table(
    check = c("national_countries", "survey_rows_in_period", "eligible_country_method_series", "selected_countries",
              "regions_in_country_comparison", "method_pairs", "method_pair_countries", "pairs_same_survey_acronym"),
    value = c(nrow(data$catalog), nrow(data$surveys), sum(candidates$eligible), nrow(countries),
              data.table::uniqueN(countries$region_code), nrow(pairs), nrow(method_summary), sum(pairs$same_survey_acronym)))
  data.table::fwrite(audit, "output/results/data_audit.csv")
  saveRDS(output, "data_clean/analysis_data.rds")
  output
}
