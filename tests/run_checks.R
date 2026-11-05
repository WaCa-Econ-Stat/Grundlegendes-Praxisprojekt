if (.Platform$OS.type == "windows" && !l10n_info()[["UTF-8"]]) {
  Sys.setlocale("LC_CTYPE", "English_United States.utf8")
}
for (script in c("00_setup", "00_helpers", "01_prepare_data", "02_build_analysis_data")) {
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

if (!file.exists("data_clean/analysis_data.rds")) stop("First run source('run_all.R').")
a <- readRDS("data_clean/analysis_data.rds")
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
check(nrow(manifest) %in% c(6L, 7L) && all(file.exists(manifest$png)) && all(file.exists(manifest$svg)),
      "The current manifest contains all six core exports and the optional seventh")
check(all(file.size(c(manifest$png, manifest$svg)) > 1000), "Exports contain image data")
html <- paste(readLines("output/bericht.html", encoding = "UTF-8", warn = FALSE), collapse = "\n")
check(length(gregexpr("data:image/png;base64,", html, fixed = TRUE)[[1]]) == nrow(manifest), "The report embeds every current figure for offline use")
cat("Passed ", checks, " checks.\n", sep = "")
