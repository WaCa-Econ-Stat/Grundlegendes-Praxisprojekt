xy <- data.frame(x = c(1, 2, 3, 4, 5), y = c(1, 2, 3, 4, 5))
library(tidyverse)
xy %>% mutate(z = x+y, x = x/z, y = y/z) |> print()
