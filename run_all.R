# ---- Run the pipeline: raw data -> data_clean/ -> output/figures/ ----
# Working directory = project root. Exploration scripts (explore/) are not run here.
source("R/01_data_prep.R")

# each figure script sources R/00_setup.R itself and reads data_clean/*.rds
for (f in list.files("R", pattern = "^fig_.*\\.R$", full.names = TRUE)) {
  message("Running ", f)
  source(f, local = new.env())
}
