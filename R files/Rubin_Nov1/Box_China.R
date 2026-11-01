source(file = "Libraries.R") |> suppressWarnings() |>  suppressMessages() 

### Start China
data_pip <- read.csv("data//worldbank_pip.csv")
data_China <- data_pip %>% 
    filter(country_name == "China") %>%
    select(country_name,
        reporting_year, headcount, gini, reporting_level, mld, reporting_pop, reporting_gdp)

data_China$reporting_gdp <- data_China$reporting_gdp / 11830.6

year_change <- 1988.5 #last year of income as welfare_type is 1987, consumption starts 1990

shares <- data_China %>% 
    select(reporting_year, reporting_level, reporting_pop, mld) %>%
    pivot_wider(names_from = reporting_level, values_from = c(reporting_pop, mld)) %>%
    mutate(p_rural = reporting_pop_rural/reporting_pop_national, p_urban = reporting_pop_urban/reporting_pop_national, p_national = 1) %>%
    mutate(mld_within = mld_rural*p_rural + mld_urban*p_urban) %>%
    mutate(mld_between = mld_national - mld_within) %>% 
    select(-c(reporting_pop_national, reporting_pop_rural, reporting_pop_urban, mld_rural, mld_urban)) %>%
    rename(mld_total = mld_national)
data_mld <- shares %>% select(reporting_year, mld_total, mld_within, mld_between) %>%
    mutate(share_between = mld_between/mld_total)
shares <- shares %>% select(-c(mld_total, mld_within, mld_between))
shares <- shares %>% pivot_longer(cols = c(p_rural, p_urban, p_national),
    names_to = "reporting_level", values_to = "pop_share") %>%
    mutate(reporting_level = factor(reporting_level,
    levels = c("p_national", "p_rural", "p_urban"), labels = c("national", "rural", "urban")))
data_China <- inner_join(data_China, shares, by = c("reporting_year", "reporting_level"))
### data prep over

#

#ggsave(filename = "my_plot.png", plot = my_plot)

#
Plot_pov_gini_gdp <- data_China %>% filter(reporting_level == "national") %>%
    pivot_longer(cols = c(headcount, gini, reporting_gdp), names_to = "Variable", values_to = "value") %>%
    ggplot(aes(x = reporting_year, y = value, color = Variable)) +
    geom_point() +
    geom_line() +
    theme_minimal() +
    labs(title = "Poverty in China",
         x = "Year",
         y = "value")+
     scale_color_discrete(
    name   = NULL,   # or "Indicator" if you want a legend title
    labels = c(headcount     = "Share below 3 USD",
               gini          = "Gini Index",
               reporting_gdp = "GDP")
  )
print(Plot_pov_gini_gdp)
ggsave(filename = "R files/Rubin_Nov1/Plots/Plot_pov_gini_gdp.png", plot = Plot_pov_gini_gdp)

#

temp_dat <- data_China %>% filter(reporting_level %in% c("urban", "rural")) %>%
     select(reporting_year, reporting_level, headcount)

temp_dat_urban <- temp_dat %>% filter(reporting_level == "urban") %>% arrange(reporting_year)
for(j in 1:nrow(temp_dat_urban)){
     if(temp_dat_urban[j,"headcount"] < 0.01) {print(temp_dat_urban[j,"reporting_year"]); break} else {
          j = j +1
     }
}
temp_dat_rural <- temp_dat %>% filter(reporting_level == "rural") %>% arrange(reporting_year)
for(j in 1:nrow(temp_dat_rural)){
     if(temp_dat_rural[j,"headcount"] < 0.01) {print(temp_dat_rural[j,"reporting_year"]); break} else {
          j = j +1
     }
}
pov_rural_urban <- ggplot(data = data_China, aes(x = reporting_year, y = headcount, color = reporting_level)) +
    geom_point() +
    geom_line() +
    theme_minimal() +
    labs(title = "Poverty in China",
         x = "Year",
         y = "Value", subtitle = "Urban crossed the 1% poverty threshold in 2011,\nrural in 2019\n1% share in purple")+
    geom_hline(yintercept = 0.01, linetype = "dashed", color = "purple")+
    scale_color_discrete(
    name   = NULL,   # or "Indicator" if you want a legend title
    labels = c(national     = "National",
               rural     = "Rural",
               urban     = "Urban")
  )

print(pov_rural_urban)
ggsave(filename = "R files/Rubin_Nov1/Plots/Plot_pov_rural_urban.png", plot = pov_rural_urban)
###

pov_urbanization <- data_China %>% filter(reporting_level == "rural") %>%
    pivot_longer(cols = c(headcount, pop_share), names_to = "variable", values_to = "value") %>%
    ggplot(aes(x = reporting_year, y = value, color = variable)) +
    geom_point() +
    geom_line() +
    theme_minimal() +
    labs(title = "Poverty reduction and urbanization in China",
         x = "Year",
         y = "Value")+
    scale_color_discrete(
    name   = NULL,   # or "Indicator" if you want a legend title
    labels = c(headcount     = "Share below 3 USD",
               pop_share     = "Share living in rural areas")
  )
print(pov_urbanization)
ggsave(filename = "R files/Rubin_Nov1/Plots/Plot_pov_urbanization.png", plot = pov_urbanization)

#


# Plots for MLD
#first one only "maybe"
data_mld %>% pivot_longer(cols = c(mld_total, mld_within, mld_between), names_to = "variable", values_to = "value") %>%
    ggplot(aes(x = reporting_year, y = value, color = variable)) +
    geom_point() +
    geom_line() +
    theme_minimal() +
    labs(title = "MLD",
         x = "Year",
         y = "MLD")

Share_between_mld <- ggplot(data = data_mld  , aes (x = reporting_year, y = share_between)) +
    geom_line() +
    geom_point() +
    theme_minimal() +
    labs(title = "Share of between-group MLD in China",
         x = "Year",
         y = "Share")
print(Share_between_mld)
ggsave(filename = "R files/Rubin_Nov1/Plots/Plot_Share_between_mld.png", plot = Share_between_mld)

#

ff <- function(pcc, ys){
    if(pcc > 0){
        return(-1+pcc^(1/ys))
    } else {
        pcc <- 1 + abs(pcc)
        return(pcc^(1/ys)-1	)
    }
}
gg <- Vectorize(ff)
data_boxplots <- data_pip %>% filter(welfare_type == "consumption", reporting_level == "national") %>%
    group_by(country_name) %>% summarize(min = min(reporting_year), max = max(reporting_year)) %>%
    ungroup() %>%
    pivot_longer(cols = c("min", "max"), names_to = "kind", values_to = "reporting_year") %>%
    inner_join(., filter(data_pip, welfare_type == "consumption", reporting_level == "national") %>%
    select(region_name, country_name, headcount, reporting_year), by = c("country_name", "reporting_year") ) %>%
    arrange(country_name, reporting_year) %>% pivot_wider(names_from = kind, values_from = c(headcount,reporting_year)) %>%
    mutate(headcount_min = ifelse(headcount_min <= 1e-6, abs(rnorm(1,0,1e-6)),headcount_min)) %>%
    mutate(headcount_max = ifelse(headcount_max <= 1e-6, abs(rnorm(1,0,1e-6)),headcount_max)) %>%
    mutate(pov_change = headcount_max - headcount_min,
    year_span = reporting_year_max - reporting_year_min,
    pov_change_per_year = pov_change/year_span,
    pov_change_percentage = 1 - headcount_max/headcount_min,
    pov_change_percentage_per_year = gg(pov_change_percentage, year_span))
## box
Boxplot_outlier <- ggplot(data = data_boxplots, aes(x = pov_change_per_year, color = region_name )) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Regional outliers in poverty reduction",
         x = "Poverty change in percentage points per year",
         y = "Region")+geom_vline(xintercept = 0, linetype = "dashed", color = "purple")



outlier_labels <- tibble::tribble(
  ~label,         ~px,     ~py,     ~lx,     ~ly,    ~hjust, ~vjust,
  "Sudan ",        0.0445,  0.3125,  0.0375,  0.3125, 1,      0.5,
  "Nepal ",       -0.0263,  0.1875, -0.0330,  0.1875, 1,      0.5,
  "Pakistan ",    -0.0165,  0.0625, -0.0230,  0.0625, 1,      0.5,
  " Yemen",        0.0126,  0.0625,  0.0185,  0.0625, 0,      0.5,
  " Peru",         0.0224, -0.0625,  0.0290, -0.0625, 0,      0.5,
  "Tajikistan ",  -0.0303, -0.1875, -0.0365, -0.1875, 1,      0.5,
  " Uzbekistan",   0.0276, -0.1875,  0.0335, -0.1875, 0,      0.5,
  " Micronesia",   0.0136, -0.3125,  0.0195, -0.3125, 0,      0.5,
  "China",        -0.0259, -0.3160, -0.0320, -0.3600, 0.5,    1,
  "Indonesia",    -0.0200, -0.3160, -0.0200, -0.3850, 0.5,    1
)
# px/py = arrow tip (just short of the dot), lx/ly = label position

Boxplot_outlier <- Boxplot_outlier +
  annotate("segment",
           x = outlier_labels$lx, y = outlier_labels$ly,
           xend = outlier_labels$px, yend = outlier_labels$py,
           arrow = arrow(length = unit(0.12, "cm"), type = "closed"),
           linewidth = 0.3, colour = "grey30") +
  annotate("text",
           x = outlier_labels$lx, y = outlier_labels$ly,
           label = outlier_labels$label,
           hjust = outlier_labels$hjust, vjust = outlier_labels$vjust,
           size = 3, colour = "grey20")+
           scale_color_discrete(name = "Regions")






print(Boxplot_outlier)

ggsave(filename = "R files/Rubin_Nov1/Plots/Plot_Boxplot_outlier.png", plot = Boxplot_outlier,
    width = 12, height = 7, dpi = 300, bg = "white")
