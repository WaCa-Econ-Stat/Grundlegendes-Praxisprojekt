# One OWID-selected national survey per country, chosen before dropping missing
# indicators. Mortality and economic indicators refer to that actual reporting year.
indicator_snapshot <- function(surveys, target_year, tolerance) {
  x <- data.table::copy(surveys[owid_selected == TRUE & abs(year - target_year) <= tolerance])
  x[, distance := abs(year - target_year)]
  data.table::setorder(x, country_code, distance, year)
  x <- x[, .SD[1L], by = country_code]
  x[, `:=`(target_year = target_year, country_de = country_labels(country_name), gini_points = 100 * gini)]
  assert_unique(x, "country_code", "Indikator-Querschnitt")
  x
}

rank_association <- function(x, y) {
  valid <- is.finite(x) & is.finite(y)
  if (sum(valid) < 3L || data.table::uniqueN(x[valid]) < 2L || data.table::uniqueN(y[valid]) < 2L) return(NA_real_)
  unname(stats::cor(x[valid], y[valid], method = "spearman"))
}

build_living_conditions <- function(a, config) {
  stopifnot(all(a$surveys$gini >= 0 & a$surveys$gini <= 1, na.rm = TRUE))
  snapshot <- indicator_snapshot(a$surveys, config$indicator_year, config$indicator_tolerance)
  audit <- merge(a$catalog[, .(country_code, country_name)],
                 snapshot[, .(country_code, year, welfare_type, reporting_gdp, gini_points, child_mortality)],
                 by = "country_code", all.x = TRUE)
  audit[, `:=`(has_survey = !is.na(year),
               has_gdp = is.finite(reporting_gdp) & reporting_gdp > 0,
               has_gini = is.finite(gini_points), has_mortality = is.finite(child_mortality))]

  years <- sort(config$mortality_years)
  periods <- data.table::rbindlist(lapply(years, function(y) {
    indicator_snapshot(a$surveys, y, config$indicator_tolerance)
  }))
  available <- periods[is.finite(child_mortality), .N, by = country_code]
  common <- available[N == length(years), country_code]
  mortality_panel <- periods[country_code %in% common]
  # These are repeated cross-sections of the same countries; not a claim that
  # their survey methods and comparability spells stayed unchanged for 20 years.
  panel_audit <- periods[, .(periods_available = .N, mortality_periods = sum(is.finite(child_mortality)),
                             welfare_types = data.table::uniqueN(welfare_type),
                             in_balanced_panel = country_code[1] %in% common), by = country_code]
  if (!length(common)) stop("Keine gemeinsamen Länder für die Kindersterblichkeits-Zeitfenster.")
  # Fixed groups: a country never changes group as its poverty rate changes.
  baseline_year <- min(years)
  membership <- mortality_panel[target_year == baseline_year,
    .(country_code, baseline_year = target_year, baseline_actual_year = year,
      baseline_poverty_pct = pct_below_3,
      poverty_group = ifelse(pct_below_3 >= 30, "high", "lower"))]
  grouped <- merge(mortality_panel, membership[, .(country_code, poverty_group)], by = "country_code")
  mortality_groups <- grouped[, .(n = .N, mortality_median = median(child_mortality),
                                   first_actual_year = min(year), last_actual_year = max(year)),
                              by = .(poverty_group, target_year)]

  mortality <- snapshot[is.finite(child_mortality)]
  higher_gdp <- mortality[is.finite(reporting_gdp) & reporting_gdp >= config$higher_gdp_cutoff]
  if (nrow(higher_gdp) < 3L) stop("Zu wenige Länder oberhalb der eingestellten BIP-Grenze.")
  richer_thresholds <- data.table::melt(higher_gdp, id.vars = c("country_code", "country_de", "year", "child_mortality", "reporting_gdp", "region_code", "reporting_pop"),
                                       measure.vars = c("pct_below_3", "pct_below_40"),
                                       variable.name = "threshold", value.name = "poverty_pct")

  case_mortality <- merge(a$cases[, .(country_code, welfare_type, country_de, start_year, end_year,
                                    start_pct, end_pct, change_pp)],
                         a$surveys[, .(country_code, welfare_type, year, child_mortality)],
                         by = c("country_code", "welfare_type"), allow.cartesian = TRUE)
  case_mortality <- case_mortality[year == start_year | year == end_year]
  case_mortality[, endpoint := ifelse(year == start_year, "start", "end")]
  case_mortality <- data.table::dcast(case_mortality,
    country_code + welfare_type + country_de + start_year + end_year + start_pct + end_pct + change_pp ~ endpoint,
    value.var = "child_mortality")
  data.table::setnames(case_mortality, c("start", "end"), c("mortality_start", "mortality_end"))
  case_mortality[, mortality_change_pp := mortality_end - mortality_start]
  if (anyNA(case_mortality$mortality_start) || anyNA(case_mortality$mortality_end)) {
    stop("Kindersterblichkeit fehlt an einem ausgewählten Fall-Endpunkt.")
  }
  focus <- case_mortality[change_pp > 0 & mortality_change_pp < 0][order(-change_pp)]
  if (!nrow(focus)) focus <- case_mortality[order(-abs(change_pp))]
  focus <- focus[1L]
  focus_series <- a$surveys[country_code == focus$country_code & welfare_type == focus$welfare_type &
                             year >= focus$start_year & year <= focus$end_year]
  mortality_focus <- data.table::melt(focus_series,
    id.vars = c("country_code", "country_name", "year", "welfare_type", "survey_comparability"),
    measure.vars = c("poverty_pct", "child_mortality"), variable.name = "indicator", value.name = "value")

  association <- function(x, variable, sample, period = config$indicator_year) {
    valid <- is.finite(x[[variable]]) & is.finite(x$pct_below_3)
    if (variable == "reporting_gdp") valid <- valid & x[[variable]] > 0
    data.table::data.table(sample = sample, target_year = period, indicator = variable,
      n = sum(valid), rho = rank_association(x[[variable]][valid], x$pct_below_3[valid]),
      first_actual_year = min(x$year[valid]), last_actual_year = max(x$year[valid]))
  }
  stats <- data.table::rbindlist(list(
    association(snapshot, "reporting_gdp", "Alle verfügbaren Länder"),
    association(snapshot[welfare_type == "consumption"], "gini_points", "Konsum"),
    association(snapshot[welfare_type == "income"], "gini_points", "Einkommen"),
    association(mortality, "child_mortality", "Alle verfügbaren Länder"),
    data.table::rbindlist(lapply(years, function(y) association(mortality_panel[target_year == y], "child_mortality", "Gemeinsame Länder", y)))
  ))
  higher_gdp_stats <- richer_thresholds[, .(n = .N, rho = rank_association(poverty_pct, child_mortality)), by = threshold]
  # Expose the group-definition sensitivity rather than selecting a cutoff by rho.
  sensitivity <- data.table::rbindlist(lapply(sort(unique(c(10000, config$higher_gdp_cutoff, 30000))), function(cutoff) {
    z <- mortality[is.finite(reporting_gdp) & reporting_gdp >= cutoff]
    data.table::rbindlist(lapply(c("pct_below_3", "pct_below_8_30", "pct_below_40"), function(column) {
      data.table::data.table(gdp_cutoff = cutoff, threshold = column, n = nrow(z),
                            rho = rank_association(z[[column]], z$child_mortality))
    }))
  }))

  extra <- list(indicator_snapshot = snapshot, indicator_audit = audit, indicator_associations = stats,
                mortality_snapshot = mortality, mortality_panel = mortality_panel, mortality_panel_audit = panel_audit,
                mortality_group_membership = membership, mortality_groups = mortality_groups, mortality_focus = mortality_focus,
                case_mortality = case_mortality, higher_gdp_thresholds = richer_thresholds,
                higher_gdp_associations = higher_gdp_stats, higher_gdp_sensitivity = sensitivity)
  for (name in names(extra)) write_table(extra[[name]], name)
  a <- c(a, extra)
  saveRDS(a, "data_clean/analysis_data.rds")
  a
}
