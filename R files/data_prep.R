# ---- Data preparation ----
# Builds the central data.table used by (almost) all analyses and plots in this project.
# Creates and saves:
#   full  : OWID x PIP, national level, countries + aggregates (World, WB regions), full outer join
#   china : China urban/rural (OWID x PIP), for the separate sub-task
library(data.table)

owid  <- fread("data/owid_poverty_lines.csv")
pip   <- fread("data/worldbank_pip.csv")
codes <- fread("data/owid_country_codes.csv")
# pipDic <- fread("data/worldbank_pip_dictionary.csv")   # variable descriptions

setnames(owid, make.names(names(owid)))   # "Share below $3 a day" -> Share.below..3.a.day

# drop constant or completely empty PIP columns
# pip[, names(.SD)[sapply(.SD, uniqueN) == 1]]
pip[, c("poverty_line", "is_interpolated", "estimation_type", "estimate_type") := NULL]

# ---- ISO3 codes for OWID ----
owid[codes, on = .(Country = entity), code := i.code]
owid[Country == "Kosovo", code := "XKX"]   # OWID_KOS -> PIP code
owid[code == "", code := NA]               # urban/rural rows, SSA subregions, World (excl. China/India)
# unique(owid[!grepl("^[A-Z]{3}$", code), .(Country, code)])   # everything that is not a country
# setdiff(owid[grepl("^[A-Z]{3}$", code), code], pip$country_code)   # character(0)

# ---- China urban/rural: split off before filtering ----
chinaOwid <- owid[Country %in% c("China (urban)", "China (rural)")]
chinaOwid[, `:=`(code = "CHN", reporting_level = sub("^China \\((.+)\\)$", "\\1", Country))]
china <- merge(chinaOwid, pip[country_code == "CHN" & reporting_level != "national"],
               by.x = c("code", "Year", "reporting_level"),
               by.y = c("country_code", "reporting_year", "reporting_level"),
               all = TRUE)
setnames(china, "welfare_type", "welfareType")
stopifnot(!anyNA(china$Country), !anyNA(china$country_name),   # matched 1:1 (2 x 23 years)
          china[, all(abs(Share.below..3.a.day - 100 * headcount) < 1e-4)])

# ---- National level only ----
# drops urban/rural-only surveys: Argentina entirely, Uruguay until 2005, a few early years
owid <- owid[!grepl("\\((urban|rural)\\)$", Country)]
pip  <- pip[reporting_level == "national"]
stopifnot(!anyDuplicated(owid, by = c("Country", "Year")),
          !anyDuplicated(pip, by = c("country_code", "reporting_year", "welfare_type")))
# pip[, .N, by = .(country_code, reporting_year)][N > 1, .N]   # 88 country-years with income AND consumption

# ---- Which welfare_type did OWID choose per country-year? Match via the $3 value ----
wt <- merge(owid[, .(code, Year, share3 = Share.below..3.a.day)],
            pip[, .(code = country_code, Year = reporting_year, welfare_type, headcount)],
            by = c("code", "Year"))[abs(share3 - 100 * headcount) < 1e-4]
stopifnot(!anyDuplicated(wt, by = c("code", "Year")))
owid[wt, on = .(code, Year), welfareType := i.welfare_type]

# ---- Full outer join ----
full <- merge(owid, pip,
              by.x = c("code", "Year", "welfareType"),
              by.y = c("country_code", "reporting_year", "welfare_type"),
              all = TRUE)
full[, source := fcase(!is.na(Country) & !is.na(country_name), "both",
                       !is.na(Country), "owid",
                       default = "pip")]
# full[, .N, by = source]   # both = series chosen by OWID, pip = PIP only, owid = aggregates only
# only aggregates may be "owid": every OWID country row has a PIP partner
stopifnot(full[source == "owid" & grepl("^[A-Z]{3}$", code), .N] == 0)

# one name per code: OWID, else PIP; aggregates without code keep the OWID name
full[!is.na(code), countryName := fcoalesce(Country[!is.na(Country)][1],
                                            country_name[!is.na(country_name)][1]), by = code]
full[is.na(code), countryName := Country]
stopifnot(!anyNA(full$countryName),
          full[, uniqueN(code), by = countryName][, all(V1 == 1)])   # name <-> code unique

# ---- region_name for the OWID region aggregates too (PIP spelling, for facets) ----
# "East Asia and Pacific (WB)" -> "East Asia & Pacific"
full[grepl(" \\(WB\\)$", Country),
     region_name := gsub(" and ", " & ", sub(" \\(WB\\)$", "", Country))]
full[!region_name %in% pip$region_name, region_name := NA]   # drop SSA subregions
full[, isRegion := source == "owid" & !is.na(region_name)]
stopifnot(setequal(full[isRegion == TRUE, unique(region_name)], pip$region_name))

setcolorder(full, c("countryName", "code", "Year", "welfareType", "source", "isRegion", "region_name"))
setorder(full, countryName, Year, welfareType)

# ---- (optional) merge auxiliary variables into full (e.g. child mortality, MPM) – probably not needed ----

save(full, china, file = "data/full.rda")   # adjust path to project structure if needed
