# ---- Run the pipeline: raw data -> data_clean/ -> output/figures/ ----
# Working directory = project root. Exploration scripts (explore/) are not run here.
source("R/01_data_prep.R", local = new.env())

# Each figure script sources R/00_setup.R itself and reads data_clean/*.rds.
# Figure scripts are independent of each other (run in alphabetical order, each in its own env).
# Note: 00_setup.R is sourced into the global env, so its objects (labels, colours,
# saveFigure, ...) remain there afterwards; only the fig scripts' own objects stay local.
figScripts <- list.files("R", pattern = "^fig_.*\\.R$", full.names = TRUE)
for (f in figScripts) {
  message("Running ", f)
  source(f, local = new.env())
}
rm(figScripts, f)   # remove loop variables
