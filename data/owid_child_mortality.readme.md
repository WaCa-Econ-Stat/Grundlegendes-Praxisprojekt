# Child mortality rate - Data package

This data package contains the data that powers the chart ["Child mortality rate"](https://ourworldindata.org/grapher/child-mortality) on the Our World in Data website. It was downloaded on September 23, 2026.

## CSV structure

Each row is an observation for an entity (usually a country or region) at a timepoint.

- "Entity" — the name of the entity, e.g. "United States".
- "Code" — our internal entity code. For most countries this is the [ISO alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code, e.g. "USA"; historical and other non-standard entities get a custom code.
- "Year" or "Day" — the timepoint. Annual data has a "Year" column holding an integer year; otherwise a "Day" column holds a date string in the form "YYYY-MM-DD".
- The final column is the data column — the time series that powers the chart. Downloaded with the "full data" option it corresponds to the time series below; with "only selected data visible in the chart" it is transformed depending on the chart type, so the correspondence may be less direct.


## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc.

## How we process data at Our World in Data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stitch together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

Preparing this data involves several processing steps. Depending on the data, this can include standardizing country names and world region definitions, converting units, calculating derived indicators such as per capita measures, as well as adding or adapting metadata such as the name or the description given to an indicator.
[Read about our data pipeline](https://docs.owid.io/projects/etl/).

## Detailed information about the data


### Child mortality rate – Long-run data – Gapminder; UN IGME
Long-run estimated share of newborns who die before reaching the age of five.
Last updated: June 9, 2026  
Next expected update: June 2027  
Date range: 1751–2024  
Unit: deaths per 100 live births  
Source: Gapminder (2015); UN Inter-agency Group for Child Mortality Estimation (2025) – processed by Our World in Data  

#### How to cite this data

Gapminder (2015); UN Inter-agency Group for Child Mortality Estimation (2025) – processed by Our World in Data

#### What you should know about this data
- Child mortality, the death of children under the age of five, is still extremely common in our world today. The historical data makes clear that it doesn’t have to be this way: societies can protect their children and reduce child mortality to very low rates. For child mortality to reach low levels, many things have to go right at the same time: good healthcare, good nutrition, clean water and sanitation, maternal health, and high living standards. We can, therefore, think of child mortality as a proxy indicator of a country’s living conditions.
- The chart shows our long-run data on child mortality, which allows you to see how child mortality has changed in countries around the world. It combines data from two sources: Gapminder and the UN Inter-agency Group for Child Mortality Estimation (UN IGME).
- [Gapminder](https://www.gapminder.org/data/documentation/gd005/) provides estimates of child mortality rates from 1800 to 2015. The full list of sources used can be found in [their documentation](https://www.gapminder.org/data/documentation/gd005/).
- [UN IGME](https://childmortality.org/all-cause-mortality/data) provides estimates of child mortality rates for some countries from 1932 onward.
- For years where data from both sources is available, we prioritize the UN IGME data. See [this page](https://docs.google.com/spreadsheets/d/1SaeXxXXeBAATXH3HTmonyPiBd7j0laE6GBUlcboTgYk/edit) for more details on which source is used for each data point.
- This indicator is calculated as the number of children under the age of five who died in a given year, divided by the number of newborns in that year.

#### Notes on our processing step for this indicator
This indicator is a combination of data from two sources:
  - Gapminder, which provides estimates of child mortality rates for the years 1800 to 2015.
  - The UN Inter-agency Group for Child Mortality Estimation (UN IGME) provides estimates of child mortality rates, for some countries from 1932 onward.

For years where data from both sources is available, we prioritize the UN IGME data. See [this page](https://docs.google.com/spreadsheets/d/1SaeXxXXeBAATXH3HTmonyPiBd7j0laE6GBUlcboTgYk/edit) for more details on which source is used for each data point.

In the Gapminder dataset we remove rows where the source is labeled as "Guesstimate" or "Model based on Life Expectancy" to try and ensure we use the best available data.

We remove data for Austria before 1830 from the Gapminder dataset, as there is a jump in 1830 that is likely an error.


## Sources

These are the sources behind the data in this package. Each time series above names the ones it draws on in its citation.

### United Nations Inter-agency Group for Child Mortality Estimation

The United Nations Inter-agency Group for Child Mortality Estimation (UN IGME) was formed in 2004 to share data on child mortality, improve methods for child mortality estimation, report on progress towards child survival goals, and enhance country capacity to produce timely and properly assessed estimates of child mortality. The UN IGME is led by the United Nations Children’s Fund (UNICEF) and includes the World Health Organization (WHO), the World Bank Group and the United Nations Population Division of the Department of Economic and Social Affairs as full members.

UN IGME updates its child mortality estimates annually after reviewing newly available data and assessing data quality. The web portal contains the latest UN IGME estimates of child mortality at the country, regional and global levels, and the data used to derive them.

Producer: United Nations Inter-agency Group for Child Mortality Estimation  
Published: 2026-03-17  
Retrieved on: 2026-06-09  
Retrieved from: https://childmortality.org/all-cause-mortality/data  
Direct download: https://childmortality.org/wp-content/uploads/2026/03/UN-IGME-2025.zip  
License: Copyright © UNICEF (https://www.unicef.org/legal#copyright)  

Citation: United Nations Inter-agency Group for Child Mortality Estimation (2026).

### Gapminder – Child mortality rate under age five

Estimates of child mortality rate (under five years old) per 1,000 live births.
This data has been compiled by Klara Johansson and Mattias Lindgren (Gapminder) from a selection of sources:
* Human Mortality Database
* Child Mortality Estimates from the UN Inter-agency Group for Child Mortality Estimation.
* Gapminder model based on infant mortality ratio (version 2) https://www.gapminder.org/data/documentation/gd002/
* Model estimates based on Gapminder's life expectancy data combined with model life tables, with some additional adjustments

Producer: Gapminder  
Published: 2015-01-01  
Retrieved on: 2023-09-18  
Retrieved from: https://www.gapminder.org/data/documentation/gd005/  
Direct download: https://www.gapminder.org/documentation/documentation/gapdata005%20v7.xlsx  
License: CC BY 4.0  

Citation: Gapminder, Child Mortality Rate, under age five, version 7. https://www.gapminder.org/data/documentation/gd005/

### Gapminder based on UN IGME & UN WPP – Under-five Mortality

This file contains data on child mortality rates compiled by Gapminder, based on multiple sources:
- 1800 to 1950: Gapminder v7  ( In some cases this is also used for years after 1950, see below.) This was compiled and documented by Mattias Lindgren from many sources, but mainly based on www.mortality.org and the series of books called International Historical Statistics  by Brian R Mitchell, which often have historic estimates of Infant mortality rate which were converted to Child mortality through regression. See detailed documentation of v7 below.

- 1950 to 2018: UNIGME, is a data collaboration project between UNICEF, WHO, UN Population Division and the World Bank. They  released new estimates of child mortality for countries and a global estimate on September 19, 2019, which is available at www.childmortality.org. In this dataset 70% of all countries have estimates between 1970 and 2016, while roughly half the countries also reach back to 1950.

- 1950 to 2100: UN WPP, World Population Prospects 2019  provides annual data for Child mortality rate for all countries in the annually interpolated demographic indicators, called WPP2019_INT_F01_ANNUAL_DEMOGRAPHIC_INDICATORS.xlsx
In general, We connected our historic estimates from Gapminder v7 to the earliest available year with data in UNIGME or if it didn't have data, we used UN POP from 1950 and on, until UNIGME had data. Depending on data availability, different countries are moving between sources at different points in the period 1930-1980.After 2018, we have extended the UN IGME series with the UN POP numbers. But we haven't extended it with the  UN POP actual numbers but  instead, we extended it with the UN POP expected change.
The data is part of Gapminder effort to build a fact-based worldview by showing the big picture of global development. When we find multiple data sources that haven't been combined we combine them into one consistent timeseries. This often results in large data uncertainty, as the underlying data-sources use different methodologies etc. But we still dare to combine data that hasn't been combined, as we find it extremely important to visualize the big picture, which people otherwise tend to get absolutely wrong. Before using our data for any other purpose though, please read the documentation to make sure you are aware of our levels of doubts in the data.

Producer: Gapminder based on UN IGME & UN WPP  
Published: 2020-01-30  
Retrieved on: 2023-09-21  
Retrieved from: https://docs.google.com/spreadsheets/d/1Av7eps_zEK73-AdbFYEmtTrwFKlfruBYXdrnXAOFVpM/edit#gid=501532268  
Direct download: https://docs.google.com/spreadsheets/d/1Av7eps_zEK73-AdbFYEmtTrwFKlfruBYXdrnXAOFVpM/export?format=xlsx  
License: CC BY 4.0# License (same as origin.license, for backwards compatibility) (https://docs.google.com/document/d/1-RmthhS2EPMK_HIpnPctcXpB0n7ADSWnXa5Hb3PxNq4/edit)  

Citation: Under-five Mortality Dataset v11, Gapminder (2020)

    