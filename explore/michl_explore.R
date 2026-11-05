# ---- Exploration (interactive, not part of run_all.R) ----
source("R/00_setup.R")
surveys    <- readRDS("data_clean/surveys.rds")
aggregates <- readRDS("data_clean/aggregates.rds")
china      <- readRDS("data_clean/china.rds")

# ---- Frequently used subsets ----
countries <- surveys[owid_selected == TRUE]   # one survey per country-year (OWID choice)
regions   <- aggregates[type == "region"]
world     <- aggregates[type == "world"]

# long format over all poverty lines, e.g. for regions
regionsLong <- melt(regions, id.vars = c("region_name", "year", "is_projection"),
                    measure.vars = names(povertyLines), variable.name = "line", value.name = "pct")
regionsLong[, line_usd := povertyLines[as.character(line)]]

# ---- Example: country series (grey) + regional estimate, one panel per region ----
p <- ggplot(countries[year >= 1990], aes(year, pct_below_3)) +
  geom_line(aes(group = country_code), colour = "grey75", linewidth = 0.3) +
  geom_line(data = regions[year >= 1990 & is_projection == FALSE], linewidth = 0.8) +
  facet_wrap(~ region_name, ncol = 4, labeller = as_labeller(regionLabels)) +
  scale_x_continuous(breaks = c(1990, 2005, 2020)) +
  scale_y_continuous(labels = labelPct) +
  labs(x = NULL, y = "Anteil unter 3 $/Tag", caption = sourcePoverty)
p
p2 <- p + theme(strip.text = element_text(size = 7), strip.clip = "off")   # local override
p2
# saveFigure(p2, "test_regions", height = 9)          # -> output/figures/test_regions.pdf/.png

# ---- Example: distance country vs. regional estimate in the same year ----
countries[regions, on = .(region_name, year), region_pct := i.pct_below_3]
countries[, diff_pp := pct_below_3 - region_pct]
