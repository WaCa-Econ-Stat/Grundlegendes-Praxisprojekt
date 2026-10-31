source(file = "Libraries.R") |> suppressWarnings() |>  suppressMessages() 
data <- read.csv("data//owid_child_mortality.csv")
head(data) |> print()
