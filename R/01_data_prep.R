# ---- Data preparation ----
# Builds the data sets used by all exploration and figure scripts.
# Run from the project root. Creates data.tables in data_clean/:
#   surveys.rds    : one row per country x survey year x welfare type (OWID x PIP, national level)
#   aggregates.rds : one row per aggregate x year (World Bank regions, World, ...; modelled values)
#   china.rds      : China urban/rural (OWID x PIP)
# Shared columns have the same names in all tables (region_name, year, pct_below_*, ...),
# so joins, rbind(fill = TRUE) and facets work without renaming.
#
# Units: pct_below_* and child_mortality in % (per 100); PIP measures
# (headcount, poverty_gap, poverty_severity, ...) stay as proportions 0-1.
library(data.table)

lastObservedYear <- 2024L   # aggregate values after this year are projections

owid  <- fread("data/owid_poverty_lines.csv", encoding = "UTF-8")
pip   <- fread("data/worldbank_pip.csv", encoding = "UTF-8")
codes <- fread("data/owid_country_codes.csv", encoding = "UTF-8")
cm    <- fread("data/owid_child_mortality.csv", encoding = "UTF-8")
# pipDic <- fread("data/worldbank_pip_dictionary.csv")   # variable descriptions

# ---- Harmonise names ----
# "Share below $4.20 a day" -> pct_below_4_20
setnames(owid, c("Country", "Year"), c("entity", "year"))
shareCols <- grep("^Share below", names(owid), value = TRUE)
setnames(owid, shareCols,
         gsub(".", "_", sub("^Share below \\$(.+) a day$", "pct_below_\\1", shareCols), fixed = TRUE))
setnames(pip, "reporting_year", "year")

# drop constant PIP columns (checked first)
dropCols <- c("poverty_line", "is_interpolated", "estimation_type", "estimate_type")
stopifnot(all(pip$poverty_line == 3),
          all(pip[, sapply(.SD, uniqueN), .SDcols = dropCols] == 1),
          all(pip$headcount >= 0 & pip$headcount <= 1))
pip[, (dropCols) := NULL]

# ---- ISO3 codes for OWID ----
stopifnot(!anyDuplicated(codes$entity))
owid[codes, on = "entity", country_code := i.code]
owid[entity == "Kosovo", country_code := "XKX"]       # OWID_KOS -> PIP code
owid[country_code == "", country_code := NA]          # urban/rural rows, SSA subregions, World excl. ...
# unique(owid[!grepl("^[A-Z]{3}$", country_code), .(entity, country_code)])   # all non-countries

# ---- China urban/rural: split off before filtering ----
chinaOwid <- owid[entity %in% c("China (urban)", "China (rural)")]
chinaOwid[, `:=`(country_code = "CHN", reporting_level = sub("^China \\((.+)\\)$", "\\1", entity))]
china <- merge(chinaOwid, pip[country_code == "CHN" & reporting_level != "national"],
               by = c("country_code", "year", "reporting_level"), all = TRUE)
stopifnot(!anyNA(china$entity), !anyNA(china$country_name),   # matched 1:1 (2 x 23 years)
          china[, all(abs(pct_below_3 - 100 * headcount) < 1e-4)])
china[, entity := NULL]

# ---- National level only ----
# drops urban/rural-only surveys: Argentina entirely, Uruguay until 2005, a few early years
owid <- owid[!grepl("\\((urban|rural)\\)$", entity)]
pip  <- pip[reporting_level == "national"][, reporting_level := NULL]
stopifnot(!anyDuplicated(owid, by = c("entity", "year")),
          !anyDuplicated(pip, by = c("country_code", "year", "welfare_type")))
# pip[, .N, by = .(country_code, year)][N > 1, .N]   # 88 country-years with income AND consumption

# ---- Split OWID: countries vs aggregates ----
isCountry  <- grepl("^[A-Z]{3}$", owid$country_code)
aggregates <- owid[!isCountry]
owid       <- owid[isCountry]

# ==== surveys ====
# Which welfare_type did OWID choose per country-year? Match via the $3 value.
wt <- merge(owid[, .(country_code, year, pct3 = pct_below_3)],
            pip[, .(country_code, year, welfare_type, headcount)],
            by = c("country_code", "year"))[abs(pct3 - 100 * headcount) < 1e-4]
stopifnot(!anyDuplicated(wt, by = c("country_code", "year")))
owid[wt, on = .(country_code, year), welfare_type := i.welfare_type]
stopifnot(!anyNA(owid$welfare_type))   # every OWID country row has its PIP survey

# full outer join; PIP-only rows = surveys not selected by OWID (e.g. the other welfare type)
surveys <- merge(owid, pip, by = c("country_code", "year", "welfare_type"), all = TRUE)
surveys[, owid_selected := !is.na(entity)]

# one name per code: OWID name, else PIP name
surveys[, country_name := fcoalesce(entity[!is.na(entity)][1], country_name[1]), by = country_code]
surveys[, entity := NULL]
stopifnot(!anyNA(surveys$country_name), !anyNA(surveys$region_name),
          surveys[, uniqueN(country_code), by = country_name][, all(V1 == 1)])   # name <-> code

# One $3 column for all surveys: OWID value (identical to PIP) or PIP headcount.
# The other poverty lines (pct_below_1, _4_20, ...) exist only for OWID-selected rows.
stopifnot(surveys[owid_selected == TRUE, all(abs(pct_below_3 - 100 * headcount) < 1e-4)])
surveys[owid_selected == FALSE, pct_below_3 := 100 * headcount]

# ==== aggregates ====
# "East Asia and Pacific (WB)" -> "East Asia & Pacific" (PIP spelling, as region_name in surveys)
setnames(aggregates, "entity", "region_name")
aggregates[, region_name := gsub(" and ", " & ", sub(" \\(WB\\)$", "", region_name))]
aggregates[, type := fcase(region_name %in% pip$region_name, "region",
                           region_name == "World", "world",
                           default = "other")]   # World excl. China/India, SSA subregions
stopifnot(setequal(aggregates[type == "region", unique(region_name)], pip$region_name))
aggregates[, region_code := pip$region_code[match(region_name, pip$region_name)]]
aggregates[, is_projection := year > lastObservedYear]
aggregates[, country_code := NULL]

# ---- Child mortality (deaths before age 5 per 100 live births) ----
# Countries and World only: OWID has no WB-region aggregates for this variable
# (its "North America" etc. are continents, not WB regions).
cm <- cm[code != ""]
cm[code == "OWID_KOS", code := "XKX"]
stopifnot(!anyDuplicated(cm, by = c("code", "year")))
surveys[cm, on = .(country_code = code, year), child_mortality := i.child_mortality_rate]
aggregates[cm[entity == "World"], on = .(region_name = entity, year),
           child_mortality := i.child_mortality_rate]
# setdiff(surveys$country_code, cm$code)   # countries without data

# ---- Order, check keys, save ----
pctCols <- grep("^pct_below_", names(surveys), value = TRUE)
setcolorder(surveys, c("country_name", "country_code", "region_name", "region_code", "year",
                       "welfare_type", "owid_selected", pctCols, "child_mortality"))
setorder(surveys, country_name, year, welfare_type)
stopifnot(!anyDuplicated(surveys, by = c("country_code", "year", "welfare_type")))

setcolorder(aggregates, c("region_name", "region_code", "type", "year", "is_projection",
                          pctCols, "child_mortality"))
setorder(aggregates, type, region_name, year)
stopifnot(!anyDuplicated(aggregates, by = c("region_name", "year")))

setcolorder(china, c("country_name", "country_code", "reporting_level", "year", "welfare_type"))
setorder(china, reporting_level, year)

dir.create("data_clean", showWarnings = FALSE)
saveRDS(surveys, "data_clean/surveys.rds")
saveRDS(aggregates, "data_clean/aggregates.rds")
saveRDS(china, "data_clean/china.rds")
