rm(list = objects())

data  <- fread("data/owid_poverty_lines.csv")
pip   <- fread("data/worldbank_pip.csv")
codes <- fread("data/owid_country_codes.csv")
pipdic   <- fread("data/worldbank_pip_dictionary.csv")

lapply(list(data, mort, pip, codes), names)

unique(pip$region_code)
length(unique(data$Country))
length(unique(pip$country_code))

# Data cleaning:
# ggf ids zu factor?
# automatisch: alle die <= 10 levels haben und nur aus zahlen bestehen zu numeric?
# sonst faktor? oder falls >=15 unique als character lassen/rauswerfen
# estimate_type 

# Merging:
# unique(data$Country)[!which(unique(data$Country) %in% unique(pip$country_name))] # 0 -> fine << FALSCH
setdiff(unique(data$Country) %in% pip$country_name)
unique(data$Country)[!unique(data$Country) %in% pip$country_name] 
# aggregationen von WB?? aber bei pip nicht vorhanden??
# urban vs rural??

# get ISO3-Codes
data[codes, on = .(Country = entity), code := i.code]
data[Country == "Kosovo", code := "XKX"]  # OWID_KOS vs. XKX @Claude
data[code == "", code := NA]

unique(data$code)
unique(data$Country)
data[grepl("Suriname", data$Country), .(Country, code, Year, Share.below..3.a.day) ]# rm
data[grepl("Rwanda", data$Country), .(Country, code, Year, Share.below..3.a.day) ] # rm Rwanda (rural) 
data[grepl("Micronesia", data$Country), .(Country, code, Year, Share.below..3.a.day) ]# rm Micronesia (country) (urban)
data[grepl("Honduras (urban)", data$Country), .(Country, code, Year, Share.below..3.a.day) ] # 0
data[grepl("Ethiopia", data$Country), .(Country, code, Year, Share.below..3.a.day) ] # rm Ethiopia (rural) 
data[grepl("Colombia", data$Country), .(Country, code, Year, Share.below..3.a.day) ] # rm Colombia (urban)
data[grepl("China", data$Country), .(Country, code, Year, Share.below..3.a.day) ] #  urban 0
data[grepl("Bolivia", data$Country), .(Country, code, Year, Share.below..3.a.day) ] # rm Bolivia (urban) 2x
data[grepl("Arge", data$Country), .(Country, code, Year, Share.below..3.a.day) ] # 1980 00 ?! ...und nur urban?!
# tweak
# data <- data[grepl("^[A-Z]{3}$", code)]  # nur Länder: Aggregate und (urban)/(rural) raus
# length(unique(pip$survey_year)) # vs reporting_year? 
# length(unique(pip$reporting_year))# viel weniger... integer ok.
# unique(data$Year)[!which(unique(data$Year) %in% unique(pip$reporting_year))] # 0 good.


#outer join
dim(data)  #2914   11
dim(pip) # 2584 44

# rm urban/rural observations - regions stay
data <- data[!grepl("\\((urban|rural)\\)$", Country)]
pip  <- pip[reporting_level == "national"]

# welchen welfare_type hat OWID gewählt? (Abgleich über den $3-Wert)
wt <- merge(data[, .(code, Year, share3 = `Share.below..3.a.day`)],
            pip[, .(code = country_code, Year = reporting_year, welfare_type, headcount)],
            by = c("code", "Year"))[abs(share3 - 100 * headcount) < 1e-4]
stopifnot(!anyDuplicated(wt, by = c("code", "Year")))
data[wt, on = .(code, Year), welfareType := i.welfare_type]

# Full Outer Join
full <- merge(data, pip,
              by.x = c("code", "Year", "welfareType"),
              by.y = c("country_code", "reporting_year", "welfare_type"),
              all = TRUE)
dim(full)  #ok
full[, source := fcase(!is.na(Country) & !is.na(country_name), "both",
                       !is.na(Country), "owid",
                       default = "pip")]
# table(full$source)
# pip[grepl("Morocco", pip$country_name), .(region_name,country_name,reporting_year)]


#
library(ggplot2)
ggplot(data, aes(x = Year, y = Share.below..3.a.day, colour = Country)) +
  geom_line()

aggregate(Share.below..3.a.day ~ Country, data, unique)



