# ---- Setup: packages, global plot style, labels, colours, figure export ----
# Source at the top of every exploration and figure script (working dir = project root).
# Global defaults only: any single plot can override them with + theme(...), its own
# scales or colours (the later layer wins).
library(data.table)
library(ggplot2)

# ---- Global theme ----
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor      = element_blank(),
      panel.grid.major.x    = element_blank(),
      panel.grid.major.y    = element_line(colour = "grey90", linewidth = 0.3),
      axis.ticks            = element_line(colour = "grey60", linewidth = 0.3),
      axis.text             = element_text(colour = "grey30"),
      strip.text            = element_text(face = "bold", hjust = 0),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.caption          = element_text(hjust = 0, colour = "grey40", size = rel(0.75)),
      legend.position       = "right"    # 16:9 slides: width is cheaper than height
    )
)

# Okabe-Ito: default for any discrete colour/fill scale not set explicitly
okabeIto <- c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7", "#882255", "#000000")
options(ggplot2.discrete.colour = okabeIto, ggplot2.discrete.fill = okabeIto)

# ---- Labels (German) and fixed colours per entity ----
# Names = values in the data; order = suggested factor/legend order
# (scale_colour_manual(..., breaks = names(regionLabels)) or factor(levels = ...)).
regionLabels <- c(
  "Sub-Saharan Africa"                                = "Subsahara-Afrika",
  "South Asia"                                        = "Südasien",
  "East Asia & Pacific"                               = "Ostasien & Pazifik",
  "Middle East, North Africa, Afghanistan & Pakistan" = "Nahost, Nordafrika,\nAfghanistan & Pakistan",
  "Latin America & Caribbean"                         = "Lateinamerika & Karibik",
  "Europe & Central Asia"                             = "Europa & Zentralasien",
  "North America"                                     = "Nordamerika",
  "World"                                             = "Welt"
)
# colour-vision checked for all pairs; with all 7 regions in one panel still add
# direct labels or use facets
regionColors <- c(
  "Sub-Saharan Africa"                                = "#D55E00",
  "South Asia"                                        = "#E69F00",
  "East Asia & Pacific"                               = "#009E73",
  "Middle East, North Africa, Afghanistan & Pakistan" = "#0072B2",
  "Latin America & Caribbean"                         = "#CC79A7",
  "Europe & Central Asia"                             = "#56B4E9",
  "North America"                                     = "#882255",
  "World"                                             = "#000000"
)
welfareLabels <- c(income = "Einkommen", consumption = "Konsum")
welfareColors <- c(income = "#3F5BA9", consumption = "#B8860B")

# poverty line columns -> int. $ per day (2021 PPP)
povertyLines <- c(pct_below_1 = 1, pct_below_3 = 3, pct_below_4_20 = 4.2, pct_below_8_30 = 8.3,
                  pct_below_10 = 10, pct_below_20 = 20, pct_below_30 = 30, pct_below_40 = 40)

sourcePoverty   <- "Quelle: Weltbank PIP (2026), aufbereitet von Our World in Data"
sourceMortality <- "Quelle: UN IGME (2026), aufbereitet von Our World in Data"

# German number formats for axes: scale_y_continuous(labels = labelPct)
labelPct <- scales::label_number(suffix = " %", decimal.mark = ",", big.mark = ".")
labelNum <- scales::label_number(decimal.mark = ",", big.mark = ".")
labelMio <- scales::label_number(scale = 1e-6, suffix = " Mio.", decimal.mark = ",", big.mark = ".")

# ---- Figure export ----
# Save at final size and include unscaled (LaTeX: \includegraphics without width=),
# then the font size in the figure equals base_size in pt.
figWidth  <- 14   # cm, about the text width of a 16:9 beamer slide
figHeight <- 7    # cm

saveFigure <- function(p, name, width = figWidth, height = figHeight, dir = "output/figures") {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  file <- file.path(dir, name)
  # WinAnsi: umlauts, en dash and euro sign render with the base pdf device on all OS
  ggsave(paste0(file, ".pdf"), p, width = width, height = height, units = "cm",
         device = "pdf", encoding = "WinAnsi")
  ggsave(paste0(file, ".png"), p, width = width, height = height, units = "cm",
         dpi = 300, bg = "white")
  invisible(p)
}
