# Extreme poverty below $3/day – project structure and conventions

Group project (descriptive statistics, BSc Statistics, LMU, WiSe 2026/27). Task: see `project_summary.pdf`
(questions 1–2 are essential, 3–5 optional). Graded deliverable: a 15-minute oral presentation;
the repository is for us, not graded.

**For humans and AI assistants:** this file explains *why* the code is structured as it is.
The structure is deliberately small. Please keep it unless there is a concrete reason to change it,
and update this README when you change it.

## Quick start
```r
renv::restore()        # once
source("run_all.R")    # raw data -> data_clean/ -> output/figures/
```
Working directory = project root (open the RStudio project). All paths are relative to it.

## Layout
```
data/                raw data (never modified)
R/00_setup.R         packages, global ggplot theme, German labels, fixed colours, saveFigure()
R/01_data_prep.R     raw data -> data_clean/surveys.rds, aggregates.rds, china.rds
R/fig_<n>_<topic>.R  final figures, one script per section of the talk
explore/<name>_*.R   personal, interactive exploration; not run by run_all.R
run_all.R            runs 01_data_prep.R and all R/fig_*.R
data_clean/          generated (.rds)
output/figures/      generated: <name>.pdf (for LaTeX) and <name>.png (for Quarto/preview)
report/              later: LaTeX beamer or Quarto slides (format not decided yet)
```

## Design decisions
1. **Plots are ggplot objects in plain scripts, not functions.** This lets us run them line by line,
   inspect and tweak them. Do not wrap figures into a "make_figure()" layer.
2. **One global style.** `theme_set()` in `R/00_setup.R` defines the defaults. A single plot overrides
   locally with `+ theme(...)`, its own scales or colours; the later layer wins. Do not paste full themes
   into individual plots. Use ggplot2 only: base-R graphics do not follow the global theme.
3. **Labels and colours are named vectors keyed by data values.** The data keeps the English source
   names (`region_name`, `welfare_type`); plots show German labels via
   `scale_colour_manual(values = regionColors, labels = regionLabels, breaks = names(regionLabels))`.
   Each entity has the same colour in every plot. The region palette (Okabe-Ito + wine) was checked for
   colour-vision deficiency; with all 7 regions in one panel, add direct labels or use facets.
4. **The output folder is the interface to the report.** `saveFigure(p, name)` writes PDF and PNG at
   the final size (default 14 × 7 cm ≈ text width of a 16:9 beamer slide). Include the figures unscaled,
   so the font size in the figure equals `base_size` (11 pt). This keeps LaTeX and Quarto both possible.
   The PDF uses `encoding = "WinAnsi"` so that umlauts, en dash and € render on all OS.
5. **Data prep produces base data only.** No plot-specific tables in `01_data_prep.R`. Subsets and
   derived tables live in the figure or exploration scripts, so dropping a plot leaves no dead code
   in the data layer.
6. **One table per observational unit (tidy data), not one big table.** Country surveys (irregular years,
   two welfare types possible per country-year, PIP variables) and modelled aggregates (annual, incl.
   projections, no PIP variables) are different units. A single merged table had 34 of 51 columns empty
   for aggregates and needed two filter variables in every analysis; forgetting one silently mixed
   aggregates into country statistics. Shared columns keep identical names in both tables, so
   country-vs-region work stays one join (`on = .(region_name, year)`) and one-layer plots one
   `rbind(..., fill = TRUE)`.
7. **One version per plot, German plot text.** There are no parallel "original/paper" variants.
8. **History:** an earlier pipeline (`code/`: two versions per plot, base-R map with hand-coded
   projection, figure-export manifest) was removed on purpose. Do not restore it.

## Data (`data_clean/*.rds`, data.tables)
Units everywhere: `pct_below_*` and `child_mortality` in % (per 100); PIP measures are **proportions 0–1**.

**`surveys.rds`**: one row per country × survey year × welfare type (2475 rows); unique key
`country_code, year, welfare_type`. Country values exist only for survey years (1963–2025).

| column | meaning |
|---|---|
| `country_name`, `country_code`, `region_name`, `region_code` | OWID name (else PIP), ISO3, World Bank region (PIP spelling) |
| `welfare_type` | `income` or `consumption`; 88 country-years have both |
| `owid_selected` | TRUE = the one survey OWID uses per country-year (2280 rows); FALSE = further PIP surveys |
| `pct_below_1` … `pct_below_40` | % below the line (int. $/day, 2021 PPP), from OWID, only for `owid_selected` rows; exception: `pct_below_3` is filled for all rows (`100 * headcount`) |
| `child_mortality` | deaths before age 5 per 100 live births (UN IGME via OWID), up to 2024 |
| PIP columns | `headcount`, `poverty_gap`, `gini`, `mld`, `mean`, `median`, deciles, `reporting_pop`, `reporting_gdp`, `survey_comparability`, …; see `data/worldbank_pip_dictionary.csv` |

**`aggregates.rds`**: one row per aggregate × year (525 rows); unique key `region_name, year`.
Modelled annual values, regions from 1981, World from 1990, up to 2026.

| column | meaning |
|---|---|
| `region_name` | 7 World Bank regions (same spelling as in `surveys`), `World`, `World (excluding China)`, `World (excluding India)`, 2 SSA subregions |
| `type` | `region`, `world`, `other` |
| `is_projection` | TRUE for 2025–26 (World Bank projections) |
| `pct_below_1` … `pct_below_40` | as above |
| `child_mortality` | World only; OWID has no World Bank region aggregates for it |

**`china.rds`**: China urban/rural (OWID × PIP), 2 × 23 years; the national series is in `surveys`.

Typical subsets and the country-vs-region join:
```r
countries <- surveys[owid_selected == TRUE]   # one series per country (forgetting this double-counts 88 country-years)
regions   <- aggregates[type == "region"]
countries[regions, on = .(region_name, year), region_pct := i.pct_below_3]
```

## Conventions
- R objects and functions in lowerCamel, classes in UpperCamel; data columns in snake_case (as in PIP and its dictionary)
- Comments in English; all text in plots in German
- data.table for data, ggplot2 for plots; `library()` directly; no `return()` at the end of functions
- Figure scripts start with `source("R/00_setup.R")` plus `readRDS()` and end with `saveFigure()` calls

## Interpretation caveats
- Country values exist only for survey years. Regional and world values are modelled
  (extrapolated with growth data, population-weighted, 2025–26 projected).
- Income- and consumption-based rates are not directly comparable; OWID picks one per country-year.
- `survey_comparability` marks breaks within a country's series; changes across breaks are not clean trends.
