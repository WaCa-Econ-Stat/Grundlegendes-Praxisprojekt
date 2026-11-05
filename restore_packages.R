# Restore the recorded versions into the local project library.
version <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
project_library <- file.path(".Rlibrary", paste0("R-", version))
dir.create(project_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(normalizePath(project_library), .libPaths()))
if (!requireNamespace("renv", quietly = TRUE)) {
  staging <- file.path(tempdir(), "renv-bootstrap")
  dir.create(staging, recursive = TRUE, showWarnings = FALSE)
  install.packages("renv", lib = staging, repos = "https://cloud.r-project.org")
  if (!file.copy(file.path(staging, "renv"), project_library, recursive = TRUE, overwrite = TRUE)) {
    stop("Could not bootstrap renv into the project library.")
  }
}
renv::restore(project = getwd(), library = normalizePath(project_library), lockfile = "renv.lock", prompt = FALSE)
