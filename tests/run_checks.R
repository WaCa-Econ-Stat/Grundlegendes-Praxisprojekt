if (.Platform$OS.type == "windows" && !l10n_info()[["UTF-8"]]) {
  Sys.setlocale("LC_CTYPE", "English_United States.utf8")
}
for (script in c("00_setup", "00_helpers", "01_prepare_data", "02_build_analysis_data", "02_living_conditions")) {
  source(file.path("code", paste0(script, ".R")), encoding = "UTF-8")
}
config <- setup_project()
checks <- 0L
check <- function(ok, label) {
  if (!isTRUE(ok)) stop("FAILED: ", label)
  checks <<- checks + 1L
  cat("OK ", label, "\n", sep = "")
}

fixture <- data.table(country_code = "AAA", country_name = "A", region_code = "EAS",
                      welfare_type = "consumption", year = c(2008L, 2012L, 2015L, 2020L),
                      poverty_pct = c(0, 10, 5, 0), survey_comparability = 0L)
x <- endpoint_candidates(fixture, config)
check(x$eligible && x$start_year == 2008L && x$end_year == 2020L, "Equal-distance endpoints choose the earlier survey")
check(x$start_pct == 0 && x$end_pct == 0, "Zero poverty remains zero")
broken <- copy(fixture)
broken[year == 2015, survey_comparability := 1L]
check(!endpoint_candidates(broken, config)$eligible, "A break between identical endpoint codes excludes the series")
missing <- copy(fixture)
missing[year == 2015, survey_comparability := NA_integer_]
check(!endpoint_candidates(missing, config)$eligible, "Missing comparability metadata excludes the series")
check(!endpoint_candidates(fixture[year != 2015], modifyList(config, list(min_span = 13L)))$eligible,
      "An insufficient comparison interval is excluded")

candidate <- data.table(country_code = c("AAA", "AAA"), welfare_type = c("consumption", "income"),
                        country_name = "A", region_code = "EAS", start_year = 2010L, end_year = 2020L,
                        start_pct = c(10, 20), end_pct = c(5, 8), span = 10L,
                        n_surveys = c(9L, 4L), eligible = TRUE)
selected <- data.table(country_code = "AAA", year = c(2010L, 2020L), welfare_type = "income")
regional <- data.table(region_code = "EAS", year = c(2010L, 2020L), below_3 = c(30, 10))
chosen <- choose_country_series(candidate, selected, regional)
check(nrow(chosen) == 1 && chosen$welfare_type == "income", "OWID's endpoint choice prevents averaging two methods")
check(abs(chosen$regional_annual_change_pp + 2) < 1e-12, "Regional comparison uses the same country endpoint years")

pair_fixture <- data.table(country_code = c("AAA", "AAA", "AAA", "BBB"),
                           year = c(2010L, 2010L, 2011L, 2010L), country_name = c("A", "A", "A", "B"),
                           region_code = "EAS", welfare_type = c("income", "consumption", "income", "consumption"),
                           poverty_pct = c(10, 15, 12, 20), survey_acronym = c("I", "C", "I", "C"),
                           survey_year = c(2010, 2010, 2011, 2010), survey_coverage = "national", survey_comparability = 0L)
pairs <- build_method_pairs(pair_fixture)
check(nrow(pairs) == 1 && pairs$difference_pp == -5, "Pairs require identical country and year, with correct percentage-point units")
check(!pairs$same_survey_acronym && pairs$same_survey_year, "Different surveys remain explicitly flagged")

indicator_fixture <- data.table(country_code = c("AAA", "AAA", "AAA", "BBB", "BBB"), country_name = c("A", "A", "A", "B", "B"),
  year = c(2019L, 2021L, 2020L, 2020L, 2021L), owid_selected = c(TRUE, TRUE, FALSE, TRUE, TRUE),
  gini = .3, child_mortality = c(0, 1, 2, NA, 3))
snapshot_fixture <- indicator_snapshot(indicator_fixture, 2020L, 2L)
check(snapshot_fixture[country_code == "AAA", year] == 2019L,
      "Indicator snapshots prefer the earlier tied OWID survey and ignore unselected methods")
check(snapshot_fixture[country_code == "AAA", child_mortality] == 0 &&
        snapshot_fixture[country_code == "BBB", year] == 2020L && is.na(snapshot_fixture[country_code == "BBB", child_mortality]),
      "Indicator selection retains zero and does not switch survey years to fill mortality")
check(identical(snapshot_fixture$gini_points, c(30, 30)) && !"gini_points" %in% names(indicator_fixture),
      "Gini scaling does not modify the shared source table")
check(rank_association(c(1,2,3), c(3,2,1)) == -1 && is.na(rank_association(c(0,0,0), c(1,2,3))),
      "Rank associations handle direction and undefined constant inputs")

if (!file.exists("data_clean/analysis_data.rds")) stop("First run source('run_all.R').")
a <- readRDS("data_clean/analysis_data.rds")
surveys <- readRDS("data_clean/surveys.rds")
aggregates <- readRDS("data_clean/aggregates.rds")
china <- readRDS("data_clean/china.rds")
survey_key <- c("country_code", "year", "welfare_type")
check(!anyDuplicated(surveys, by = survey_key) && !anyDuplicated(aggregates, by = c("region_name", "year")),
      "Shared survey and aggregate keys are unique")
raw_pip <- fread("data/worldbank_pip.csv")
setnames(raw_pip, "reporting_year", "year")
check(fsetequal(surveys[, ..survey_key], raw_pip[reporting_level == "national", ..survey_key]),
      "Every national PIP survey is retained, including those not selected by OWID")
check(isTRUE(all.equal(a$surveys_all, surveys)) && isTRUE(all.equal(a$aggregates, aggregates)) &&
        isTRUE(all.equal(a$china, china)), "The analysis retains all three unchanged shared datasets")
canonical_period <- copy(surveys[year >= config$start_year & year <= config$end_year])
setorder(canonical_period, country_code, welfare_type, year)
canonical_columns <- names(surveys)
check(isTRUE(all.equal(as.data.frame(a$surveys[, ..canonical_columns]), as.data.frame(canonical_period))) &&
        identical(a$surveys$poverty_pct, canonical_period$pct_below_3),
      "The adapter only filters national data and aliases the canonical poverty percentage")
check(fsetequal(a$selected[, ..survey_key], canonical_period[owid_selected == TRUE, ..survey_key]),
      "The analysis uses the shared OWID selection directly")
other_thresholds <- setdiff(grep("^pct_below_", names(surveys), value = TRUE), "pct_below_3")
check(any(!surveys$owid_selected) &&
        all(abs(surveys$pct_below_3 - 100 * surveys$headcount) < 1e-4) &&
        all(is.na(as.matrix(surveys[owid_selected == FALSE, ..other_thresholds]))) &&
        !anyNA(surveys[owid_selected == TRUE, ..other_thresholds]),
      "Percentage units and the availability of additional poverty thresholds remain intact")
check(identical(aggregates$is_projection, aggregates$year > 2024L) &&
        all(c("world", "region", "other") %in% aggregates$type) &&
        !any(a$world$is_projection) && !any(a$regional$is_projection),
      "Full aggregates retain projection flags while the default analysis ends in 2024")
for (table in list(a$world, a$regional)) {
  check(identical(table$below_3, table$pct_below_3), "Aggregate plotting aliases preserve canonical values")
}
china_key <- c("country_code", "reporting_level", "year", "welfare_type")
check(!anyDuplicated(china, by = china_key) &&
        fsetequal(china[, ..china_key], raw_pip[country_code == "CHN" & reporting_level != "national", ..china_key]) &&
        setequal(china$reporting_level, c("urban", "rural")) && any(surveys$country_code == "CHN"),
      "Chinese urban and rural surveys are separate from the retained national series")
raw_cm <- fread("data/owid_child_mortality.csv")
raw_cm <- raw_cm[code != ""]
raw_cm[code == "OWID_KOS", code := "XKX"]
expected_cm <- raw_cm[surveys, on = .(code = country_code, year), child_mortality_rate]
check(isTRUE(all.equal(surveys$child_mortality, expected_cm)),
      "National child mortality matches the source by country and year without rescaling")
world_cm <- raw_cm[entity == "World"][aggregates[type == "world"], on = "year", child_mortality_rate]
check(isTRUE(all.equal(aggregates[type == "world", child_mortality], world_cm)) &&
        all(is.na(aggregates[type != "world", child_mortality])),
      "World mortality matches the source and incompatible regional definitions remain unjoined")
check(setequal(a$checksums$file, file.path("data", c("owid_poverty_lines.csv", "worldbank_pip.csv",
                                                    "owid_country_codes.csv", "owid_child_mortality.csv"))),
      "Checksums cover all four shared inputs")
snapshot <- a$indicator_snapshot
check(!anyDuplicated(snapshot$country_code) && all(snapshot$owid_selected) &&
        all(abs(snapshot$year - config$indicator_year) <= config$indicator_tolerance),
      "Indicator snapshots count countries once and respect OWID and the time window")
expected_snapshot <- a$surveys[owid_selected == TRUE & abs(year - config$indicator_year) <= config$indicator_tolerance]
expected_snapshot <- expected_snapshot[order(country_code, abs(year - config$indicator_year), year), .SD[1], by = country_code]
check(fsetequal(snapshot[, ..survey_key], expected_snapshot[, ..survey_key]),
      "Snapshot keys follow the closest actual survey year for every available country")
check(nrow(a$indicator_audit) == nrow(a$catalog) && !anyDuplicated(a$indicator_audit$country_code) &&
        sum(a$indicator_audit$has_survey) == nrow(snapshot), "The indicator audit retains countries with missing surveys")
check(identical(snapshot$gini_points, 100 * snapshot$gini) &&
        all(a$indicator_associations$n > 0) && all(abs(a$indicator_associations$rho) <= 1),
      "Indicator summaries preserve units and valid correlation bounds")
check(!anyNA(a$mortality_snapshot$child_mortality) &&
        isTRUE(all.equal(a$mortality_snapshot$child_mortality,
                         raw_cm[a$mortality_snapshot, on = .(code = country_code, year), child_mortality_rate])),
      "Mortality plots use the exact poverty reporting year, without filling missing values")
panel <- a$mortality_panel
check(!anyDuplicated(panel, by = c("country_code", "target_year")) &&
        all(panel[, .N, by = country_code]$N == length(config$mortality_years)) &&
        all(panel[, .N, by = target_year]$N == uniqueN(panel$country_code)) && !anyNA(panel$child_mortality),
      "Every mortality time panel contains the same countries with complete matched data")
membership <- a$mortality_group_membership
check(!anyDuplicated(membership$country_code) && setequal(membership$country_code, panel$country_code) &&
        all(membership$poverty_group == ifelse(membership$baseline_poverty_pct >= 30, "high", "lower")),
      "Mortality groups classify every panel country once using its baseline poverty")
baseline <- panel[target_year == min(config$mortality_years), .(country_code, year, pct_below_3)]
joined <- merge(membership, baseline, by = "country_code")
check(all(joined$baseline_actual_year == joined$year) && all(joined$baseline_poverty_pct == joined$pct_below_3),
      "Group membership uses the original baseline reporting year and is not reassigned later")
grouped <- merge(panel, membership[, .(country_code, poverty_group)], by = "country_code")
expected_groups <- grouped[, .(n = .N, mortality_median = median(child_mortality)), by = .(poverty_group, target_year)]
actual_groups <- a$mortality_groups[, .(poverty_group, target_year, n, mortality_median)]
check(fsetequal(actual_groups, expected_groups) && all(actual_groups[, uniqueN(n), by = poverty_group]$V1 == 1L),
      "Group lines show unweighted country medians with constant country counts")
focus <- a$mortality_focus
check(uniqueN(focus$country_code) == 1L && all(focus$country_code %in% a$cases$country_code) &&
        fsetequal(focus[indicator == "poverty_pct", .(year)], focus[indicator == "child_mortality", .(year)]),
      "The focused counterexample uses one existing case and identical years for both indicators")
expected_focus <- a$surveys[focus, on = .(country_code, year, welfare_type)]
check(all(focus$value == ifelse(focus$indicator == "poverty_pct", expected_focus$poverty_pct, expected_focus$child_mortality)),
      "Counterexample lines preserve the exact survey and mortality observations")
case_cm <- a$case_mortality
check(setequal(case_cm$country_code, a$cases$country_code) &&
        all(case_cm$mortality_change_pp == case_cm$mortality_end - case_cm$mortality_start),
      "Mortality case studies reuse the poverty cases and actual endpoint differences")
for (endpoint in c("start", "end")) {
  keys <- case_cm[, .(country_code, welfare_type, year = get(paste0(endpoint, "_year")))]
  expected <- a$surveys[keys, on = .(country_code, welfare_type, year), child_mortality]
  check(identical(case_cm[[paste0("mortality_", endpoint)]], expected), paste("Mortality case endpoint year", endpoint))
}
wealth <- a$higher_gdp_thresholds
check(all(wealth$reporting_gdp >= config$higher_gdp_cutoff) &&
        !anyDuplicated(wealth, by = c("country_code", "threshold")) &&
        all(wealth[, .N, by = country_code]$N == 2L),
      "Higher-threshold panels use identical countries and their declared GDP cutoff")
check(all(c(10000, config$higher_gdp_cutoff, 30000) %in% a$higher_gdp_sensitivity$gdp_cutoff),
      "GDP-group sensitivity is retained rather than selecting only a favorable cutoff")
check(!anyDuplicated(a$countries$country_code), "One point per country")
check(all(a$countries$span >= config$min_span & a$countries$n_surveys >= config$min_surveys), "All included series meet the interval and coverage rules")
check(nrow(a$coverage) == nrow(a$catalog) && !anyDuplicated(a$coverage$country_code), "Each catalog country counts once in method coverage")
check(all(abs(a$coverage_counts[, sum(share_pct), by = region_code]$V1 - 100) < 1e-8), "Method shares sum to 100 percent within each region")
check(all(a$candidates[eligible == TRUE, country_code] %in% a$countries$country_code), "Every eligible country appears after method selection")
check(nrow(a$cases) == 3 && !anyDuplicated(a$cases$country_code), "Three distinct cases follow the selection rules")
for (i in seq_len(nrow(a$cases))) {
  z <- a$cases[i]
  expected <- a$regional[region_code == z$region_code & year %in% c(z$start_year, z$end_year)][order(year)]
  check(nrow(expected) == 2 && abs(z$regional_annual_change_pp - diff(expected$below_3) / z$span) < 1e-10,
        paste("Case endpoint alignment", z$country_code))
}
current <- unname(tools::md5sum(a$checksums$file))
check(identical(current, a$checksums$md5), "The input files remain unchanged")
manifest <- fread("output/results/figure_manifest.csv")
new_manifest <- manifest[grepl("^(08|09|10|11|12|13)_", figure)]
check(nrow(new_manifest) == 6L && all(grepl("^https://ourworldindata.org/grapher/", new_manifest$owid_reference)) &&
        all(nzchar(new_manifest$design_note)), "All six revised figures document a concrete OWID inspiration")
for (file in c("gdp_bubbles_plot_data", "mortality_bubbles_plot_data")) {
  bubbles <- fread(file.path("output/tables", paste0(file, ".csv")))
  expected <- a$indicator_snapshot[bubbles, on = .(country_code, year)]
  check(!anyDuplicated(bubbles$country_code) && all(bubbles$reporting_pop > 0) &&
          all(abs(bubbles$reporting_pop - expected$reporting_pop) <= 1e-12 * expected$reporting_pop) &&
          all(bubbles$region_code == expected$region_code),
        paste("Population circles retain the source population and World Bank region", file))
}
check(nrow(manifest) %in% c(12L, 13L) && all(file.exists(manifest$png)) && all(file.exists(manifest$svg)) &&
        all(paste0(sprintf("%02d", 8:13), c("_bip_und_armut", "_ungleichheit_und_armut", "_kindersterblichkeit_und_armut",
          "_kindersterblichkeit_zeitvergleich", "_kindersterblichkeit_fallbeispiele", "_hoehere_grenze_kindersterblichkeit")) %in% manifest$figure),
      "The manifest contains twelve core figures and the optional threshold trend")
check(all(file.size(c(manifest$png, manifest$svg)) > 1000), "Exports contain image data")
html <- paste(readLines("output/bericht.html", encoding = "UTF-8", warn = FALSE), collapse = "\n")
check(length(gregexpr("data:image/png;base64,", html, fixed = TRUE)[[1]]) == nrow(manifest), "The report embeds every current figure for offline use")
check(grepl("Wirtschaftliche Lebensbedingungen", html, fixed = TRUE) && grepl("Gesundheit und Kindersterblichkeit", html, fixed = TRUE) &&
        grepl("Zusammenhänge und ihre Grenzen", html, fixed = TRUE), "The report includes the living-conditions chapters and interpretation limits")
check(length(gregexpr("OWID-Vorlage ansehen", html, fixed = TRUE)[[1]]) == 6L,
      "The report links all six concrete OWID references")
cat("Passed ", checks, " checks.\n", sep = "")
