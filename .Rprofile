# Packages are installed explicitly with install_packages.R or restore_packages.R.
# Opening the project never downloads packages or restores an old workspace.
local({
  version <- paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".")
  paths <- file.path(".Rlibrary", paste0("R-", version))
  if (.Platform$OS.type == "windows") {
    paths <- c(paths, file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library", version),
               file.path(Sys.getenv("USERPROFILE"), "AppData", "Local", "R", "win-library", version))
  }
  .libPaths(c(paths[dir.exists(paths)], .libPaths()))
})
