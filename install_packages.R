# Run once from the project folder: source("install_packages.R")
version <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
project_library <- file.path(".Rlibrary", paste0("R-", version))
dir.create(project_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(normalizePath(project_library), .libPaths()))
required <- c("data.table", "ggplot2", "jsonlite", "renv")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  # Stage outside the synchronized folder. Windows cloud folders can report
  # file.access(..., 2) == -1 even when creating files succeeds.
  staging_library <- file.path(tempdir(), "project-packages")
  dir.create(staging_library, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(staging_library, .libPaths()))
  install.packages(missing, lib = staging_library, repos = "https://cloud.r-project.org")
  packages <- list.dirs(staging_library, recursive = FALSE, full.names = TRUE)
  if (!all(file.copy(packages, project_library, recursive = TRUE, overwrite = TRUE))) {
    stop("Could not copy installed packages into the project library.")
  }
  .libPaths(c(normalizePath(project_library), .libPaths()))
}
if (!all(vapply(required, requireNamespace, logical(1), quietly = TRUE))) {
  stop("Some packages could not be installed. Check the messages above.")
}
message("Project packages are available in ", normalizePath(project_library))
