# Run the project with source("run_all.R") or Rscript run_all.R.
# Both figure versions are built from the same prepared data.
run_project <- function(project_root, versions = c("original", "paper"), rebuild_data = TRUE) {
  previous_directory <- setwd(project_root)
  on.exit(setwd(previous_directory), add = TRUE)
  if (.Platform$OS.type == "windows" && !l10n_info()[["UTF-8"]]) {
    previous_ctype <- Sys.getlocale("LC_CTYPE")
    Sys.setlocale("LC_CTYPE", "English_United States.utf8")
    on.exit(Sys.setlocale("LC_CTYPE", previous_ctype), add = TRUE)
  }
  start_time <- Sys.time()
  if (!all(versions %in% c("original", "paper"))) stop("Unknown figure version.")

  # Use the existing project library without invoking renv's startup installer.
  r_version <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  local_library <- file.path("renv/library/windows", paste0("R-", r_version), R.version$platform)
  if (dir.exists(local_library)) .libPaths(c(local_library, .libPaths()))

  source("code/00_setup.R", local = TRUE, encoding = "UTF-8")
  source("code/00_helpers.R", local = TRUE, encoding = "UTF-8")
  config <- setup_project()
  scripts <- c("01_prepare_data", "02_build_analysis_data", "03_world_poverty_map",
               "04_regional_poverty_trends", "05_survey_method_comparison", "06_poverty_income_bands",
               "07_country_poverty_changes", "08_china_poverty")
  for (script in scripts) source(paste0("code/", script, ".R"), local = TRUE, encoding = "UTF-8")

  message("Preparing the shared analysis data")
  if (rebuild_data) prepare_data(config)
  analysis <- build_analysis_data(config)
  manifest <- list()
  for (version in unique(versions)) {
    message("Building figure version: ", version)
    manifest[[version]] <- rbind(
      make_world_poverty_map(analysis, version, config),
      make_regional_poverty_trends(analysis, version, config),
      make_survey_method_comparison(analysis, version, config),
      make_poverty_income_bands(analysis, version, config),
      make_country_poverty_changes(analysis, version, config),
      make_china_poverty(analysis, version, config)
    )
    write_result(manifest[[version]], paste0("figure_manifest_", version))
  }
  manifest <- do.call(rbind, manifest)
  if (!all(file.exists(manifest$png))) stop("A figure export is missing.")
  writeLines(c(capture.output(sessionInfo())), "output/results/session_info.txt")
  message("Completed ", nrow(manifest), " PNG figures in ",
          round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 1), " seconds.")
  invisible(list(analysis = analysis, figures = manifest))
}

# Locate this file so the same command also works from the parent directory.
project_root <- local({
  source_files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  script <- if (length(source_files)) tail(source_files, 1)[[1]] else {
    args <- grep("^--file=", commandArgs(), value = TRUE)
    if (length(args)) sub("^--file=", "", args[1]) else "run_all.R"
  }
  dirname(normalizePath(script, mustWork = TRUE))
})
pipeline_result <- run_project(project_root)
