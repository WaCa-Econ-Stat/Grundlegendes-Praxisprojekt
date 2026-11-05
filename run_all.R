# RStudio: source("run_all.R")
# Terminal: Rscript --vanilla run_all.R
# Select UTF-8 before sourcing German-language files on Windows.
if (.Platform$OS.type == "windows" && !l10n_info()[["UTF-8"]]) {
  Sys.setlocale("LC_CTYPE", "English_United States.utf8")
}
run_project <- function(project_root, config = list()) {
  previous_directory <- setwd(project_root)
  on.exit(setwd(previous_directory), add = TRUE)
  started <- Sys.time()
  for (script in c("00_setup", "00_helpers", "01_prepare_data", "02_build_analysis_data",
                    "03_make_figures", "04_build_report")) {
    source(file.path("code", paste0(script, ".R")), local = TRUE, encoding = "UTF-8")
  }
  config <- setup_project(config)
  message("1/4 Kursdaten vorbereiten")
  prepared <- prepare_data(config)
  message("2/4 Vergleichbare Reihen und Methodenpaare bestimmen")
  analysis <- build_analysis_data(prepared, config)
  message("3/4 Grafiken erzeugen")
  figures <- make_figures(analysis, config)
  message("4/4 Bericht und Ergebnisuebersicht schreiben")
  build_report(analysis, figures, config)
  writeLines(capture.output(sessionInfo()), "output/results/session_info.txt")
  jsonlite::write_json(config, "output/results/config.json", pretty = TRUE, auto_unbox = TRUE)
  message("Fertig: ", nrow(figures), " Grafiken als PNG und SVG. Bericht und Tabellen in output/. Laufzeit: ",
          round(as.numeric(difftime(Sys.time(), started, units = "secs")), 1), " Sekunden.")
  invisible(list(analysis = analysis, figures = figures, config = config))
}
project_root <- local({
  files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  file <- if (length(files)) tail(files, 1)[[1]] else {
    args <- grep("^--file=", commandArgs(), value = TRUE)
    if (length(args)) sub("^--file=", "", args[1]) else "run_all.R"
  }
  dirname(normalizePath(file, mustWork = TRUE))
})
pipeline_result <- run_project(project_root)
