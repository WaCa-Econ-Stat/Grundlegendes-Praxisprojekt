# ---- Exploration (interactive, not part of run_all.R) ----
source("R/00_setup.R")

surveys    <- fread("data_clean/surveys.rds")
aggregates <- readRDS("data_clean/aggregates.rds")
china      <- readRDS("data_clean/china.rds")

# ---- Frequently used subsets ----
countries <- surveys[owid_selected == TRUE]   # one survey per country-year (OWID choice)
regions   <- aggregates[type == "region"]
world     <- aggregates[type == "world"]
surveys$owid_selected

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


ggplot(data = countries, aes(x = diff_pp, y = region_name)) +
  geom_boxplot()
ggplot(data = countries, aes(x = diff_pp, y = region_name)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_boxplot() +
  scale_y_discrete(labels = regionLabels) +
  labs(x = "Land-Jahr minus Regionalschätzung desselben Jahres (pp)", y = NULL, caption = sourcePoverty)

countryDiff <- countries[, .(mean_diff_pp = mean(diff_pp, na.rm = TRUE)), by = .(country_code, region_name)]
ggplot(countryDiff[!is.nan(mean_diff_pp)], aes(x = mean_diff_pp, y = region_name)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(height = 0.15, width = 0, size = 1, alpha = 0.5) +
  scale_y_discrete(labels = regionLabels) +
  labs(x = "Mittel über Survey-Jahre: Land minus Regionalschätzung (pp)", y = NULL,
       caption = sourcePoverty)


both <- rbind(
  countries[!is.na(diff_pp), .(region_name, diff = diff_pp, level = "Land-Jahr")],
  countryDiff[!is.nan(mean_diff_pp), .(region_name, diff = mean_diff_pp, level = "Land (Mittel über Survey-Jahre)")]
)
both[, level := factor(level, levels = unique(level))]

ggplot(both, aes(x = diff, y = region_name)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_boxplot() +
  facet_wrap(~ level, ncol = 2) +          # ncol = 1 -> übereinander
  scale_y_discrete(labels = regionLabels) +
  labs(x = "Land minus Regionalschätzung desselben Jahres (pp)", y = NULL, caption = sourcePoverty)

#
############################


ggplot(regions[year >= 1990], aes(year, pct_below_3)) +
  geom_line(aes(group = region_name), colour = "grey75")
ggplot(regions[year >= 1990], aes(year, pct_below_10)) +
  geom_line(aes(group = region_name), colour = "grey75")


ggplot(regions[year >= 1990], aes(year, pct_below_3)) +
  geom_line(aes(group = region_name), colour = "grey75") +
  geom_line(aes(y = pct_below_10, group = region_name, colour = "10 $/Tag")) +
  geom_line(aes(y = pct_below_40, group = region_name, colour = "40 $/Tag")) +
  scale_colour_manual(values = c("10 $/Tag" = "#E69F00", "40 $/Tag" = "#0072B2")) +
  facet_wrap(~ region_name, ncol = 4, labeller = as_labeller(regionLabels)) +
  labs(colour = NULL)

lineCols   <- c(pct_below_3 = "< 3 $/Tag", pct_below_10 = "< 10 $/Tag", pct_below_40 = "< 40 $/Tag")
regionsSel <- melt(regions[year >= 1990], id.vars = c("region_name", "year"),
                   measure.vars = names(lineCols), variable.name = "line", value.name = "pct")
regionsSel[, line := factor(lineCols[as.character(line)], levels = lineCols)]

ggplot(regionsSel, aes(year, pct, colour = region_name)) +
  geom_line() +
  facet_wrap(~ line, nrow = 1) +
  scale_colour_manual(values = regionColors, labels = regionLabels, breaks = names(regionLabels)) +
  scale_y_continuous(labels = labelPct, limits = c(0, 100)) +
  labs(x = NULL, y = "Anteil unter Armutsgrenze", colour = NULL, caption = sourcePoverty)

