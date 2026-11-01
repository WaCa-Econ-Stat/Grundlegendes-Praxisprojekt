# ---- Opener-Plots 0-2 ---- (fuer "regionalverlauf armutsquote und ...quatsch)
library(ggplot2)

# Regionslinien (WB-Schätzung via OWID); 2025/26 = Prognose -> gestrichelt
regionDt <- full[isRegion == TRUE, .(Year, region_name, share = Share.below..3.a.day)]
worldDt  <- full[Country == "World", .(Year, share = Share.below..3.a.day)]
lastObs  <- 2024  # letztes Nicht-Prognosejahr; Überlappung, damit die Linie durchgeht

# Plot 0: Gesamtbild – 7 Regionen + World in einem Panel
ggplot(regionDt[Year <= lastObs], aes(x = Year, y = share, colour = region_name)) +
  geom_line() +
  geom_line(data = regionDt[Year >= lastObs], linetype = "dashed") +
  geom_line(data = worldDt[Year <= lastObs], colour = "black", linewidth = 1) +
  geom_line(data = worldDt[Year >= lastObs], colour = "black", linewidth = 1, linetype = "dashed") +
  coord_cartesian(xlim = c(1990, 2026))

unique(full[country_name == "India", region_name])
# Plot 1: Länder (OWID) grau, Region schwarz
ggplot(full[source == "both"], aes(x = Year, y = Share.below..3.a.day)) +
  geom_line(aes(group = code), colour = "grey") +
  geom_point(colour = "grey", size = 0.5) +
  geom_line(data = regionDt[Year <= lastObs], aes(y = share), linewidth = 1) +
  geom_line(data = regionDt[Year >= lastObs], aes(y = share), linewidth = 1, linetype = "dashed") +
  facet_wrap(~ region_name, nrow = 2, labeller = label_wrap_gen(width = 20)) +
  coord_cartesian(xlim = c(1990, 2026))

# Plot 2: alle PIP-Länderdaten, Farbe = Erhebungsart, Linien brechen bei Vergleichbarkeitsbrüchen
# quatsch
pipDt <- full[source != "owid", .(code, Year, region_name, welfareType,
                                  survey_comparability, share = 100 * headcount)]

ggplot(pipDt, aes(x = Year, y = share, colour = welfareType)) +
  geom_line(aes(group = interaction(code, welfareType, survey_comparability)), alpha = 0.6) +
  geom_point(size = 0.5, alpha = 0.6) +
  geom_line(data = regionDt[Year <= lastObs], colour = "black", linewidth = 1) +
  geom_line(data = regionDt[Year >= lastObs], colour = "black", linewidth = 1, linetype = "dashed") +
  scale_colour_manual(values = c(income = "#4C72B0", consumption = "#C44E52")) +
  facet_wrap(~ region_name, nrow = 2, labeller = label_wrap_gen(width = 20)) +
  coord_cartesian(xlim = c(1990, 2026)) +
  theme(legend.position = "bottom")

# nur alternative:
# # Plot 2b: Linien = vergleichbare Reihe (gleiche Erhebungsart + comparability),
# #          Punkte nur für isolierte Erhebungen (sonst unsichtbar)
# pipDt <- full[source != "owid", .(code, Year, region_name, welfareType,
#                                   survey_comparability, share = 100 * headcount)]
# pipDt[, spell := paste(code, welfareType, survey_comparability)]
# pipDt[, nSpell := .N, by = spell]
# 
# ggplot(pipDt, aes(x = Year, y = share, colour = welfareType)) +
#   geom_line(aes(group = spell), linewidth = 0.3, alpha = 0.7) +
#   geom_point(data = pipDt[nSpell == 1], size = 0.8, alpha = 0.7) +
#   geom_line(data = regionDt[Year <= lastObs], colour = "black", linewidth = 1) +
#   geom_line(data = regionDt[Year >= lastObs], colour = "black", linewidth = 1, linetype = "dashed") +
#   scale_colour_manual(values = c(income = "#4C72B0", consumption = "#C44E52"),
#                       labels = c(income = "Einkommen", consumption = "Konsum")) +
#   facet_wrap(~ region_name, nrow = 2, labeller = label_wrap_gen(width = 20)) +
#   coord_cartesian(xlim = c(1990, 2026)) +
#   labs(x = NULL, y = "% < $3 pro Tag", colour = "Erhebungsart") +
#   theme_minimal() +
#   theme(legend.position = "bottom")



