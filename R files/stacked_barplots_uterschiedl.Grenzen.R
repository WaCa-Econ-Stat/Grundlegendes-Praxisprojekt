library(data.table)
library(ggplot2)

load("data/full.rda")          # oder: source("data_prep.R")

yearsCmp <- c(2002, 2020)      # 2020 = Covid-Jahr; ggf. 2019/2022

# Reihenfolge + Kurzlabels (Namen = region_name in full, "World" = countryName)
regionLabels <- c(`Sub-Saharan Africa`                                = "Subsahara-Afrika",
                  `Middle East, North Africa, Afghanistan & Pakistan` = "Naher Osten, Nordafrika, AFG & PAK",
                  `Latin America & Caribbean`                         = "Lateinamerika & Karibik",
                  `South Asia`                                        = "Südasien",
                  `East Asia & Pacific`                               = "Ostasien & Pazifik",
                  World                                               = "Welt",
                  `Europe & Central Asia`                             = "Europa & Zentralasien",
                  `North America`                                     = "Nordamerika")

bandLevels <- c("< $3", "$3-10", "$10-30", "> $30")
bandDt <- full[(isRegion == TRUE | countryName == "World") & Year %in% yearsCmp,
               .(region = fifelse(countryName == "World", "World", region_name), Year,
                 `< $3`   = Share.below..3.a.day,
                 `$3-10`  = Share.below..10.a.day - Share.below..3.a.day,
                 `$10-30` = Share.below..30.a.day - Share.below..10.a.day,
                 `> $30`  = 100 - Share.below..30.a.day)]
stopifnot(nrow(bandDt) == 2 * length(regionLabels))
bandDt <- melt(bandDt, id.vars = c("region", "Year"), variable.name = "band")
bandDt[, band := factor(band, levels = rev(bandLevels))]       # letzte Stufe = unten im Stapel
bandDt[, region := factor(regionLabels[region], levels = regionLabels)]

ggplot(bandDt, aes(factor(Year), value, fill = band)) +
  geom_col(width = 0.9) +
  # geom_text(aes(label = ifelse(value >= 5, sprintf("%.0f", value), "")),
  #           position = position_stack(vjust = 0.5), size = 2.8) +
  facet_grid(~ region, switch = "x", labeller = label_wrap_gen(width = 15)) +
  scale_fill_manual(values = c(`< $3` = "#E04B4B", `$3-10` = "#FBBE82",
                               `$10-30` = "#BCE1EA", `> $30` = "#5A97C9"),
                    breaks = bandLevels) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = NULL, y = "% der Bevölkerung", fill = NULL) +
  theme_minimal() +
  theme(strip.placement = "outside", panel.spacing.x = unit(1, "lines"),
        panel.grid.major.x = element_blank(), legend.position = "top")