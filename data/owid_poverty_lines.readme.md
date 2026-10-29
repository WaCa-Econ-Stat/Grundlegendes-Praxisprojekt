# Share of population living below a range of poverty lines - Data package

This data package contains the data that powers the chart ["Share of population living below a range of poverty lines"](https://ourworldindata.org/explorers/poverty-explorer?Indicator=Share+in+poverty&Poverty+line=Multiple+lines&Household+survey+data+type=Show+data+from+both+income+and+consumption+surveys&Show+breaks+between+less+comparable+surveys=false&country=BGD~BOL~KEN~MOZ~NGA~ZMB) on the Our World in Data website.

### Active Filters

A filtered subset of the full data was downloaded. The following filters were applied:

## CSV structure

Each row is an observation for an entity (usually a country or region) at a timepoint.

- "Entity" — the name of the entity, e.g. "United States".
- "Code" — our internal entity code. For most countries this is the [ISO alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code, e.g. "USA"; historical and other non-standard entities get a custom code.
- "Year" or "Day" — the timepoint. Annual data has a "Year" column holding an integer year; otherwise a "Day" column holds a date string in the form "YYYY-MM-DD".
- Every remaining column is a data column, each one a time series. Downloaded with the "full data" option each corresponds to one time series below; with "only selected data visible in the chart" they are transformed depending on the chart type, so the correspondence may be less direct.


## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc.

## How we process data at Our World in Data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stitch together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

Preparing this data involves several processing steps. Depending on the data, this can include standardizing country names and world region definitions, converting units, calculating derived indicators such as per capita measures, as well as adding or adapting metadata such as the name or the description given to an indicator.
[Read about our data pipeline](https://docs.owid.io/projects/etl/).

## Detailed information about each time series


### Country
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $1 a day
% of population living in households with an income or consumption per person below $1 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $3 a day
% of population living in households with an income or consumption per person below $3 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $4.20 a day
% of population living in households with an income or consumption per person below $4.20 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $8.30 a day
% of population living in households with an income or consumption per person below $8.30 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $10 a day
% of population living in households with an income or consumption per person below $10 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $20 a day
% of population living in households with an income or consumption per person below $20 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $30 a day
% of population living in households with an income or consumption per person below $30 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data


### Share below $40 a day
% of population living in households with an income or consumption per person below $40 a day.

The data is measured in international-$ at 2021 prices – this adjusts for inflation and for differences in living costs between countries.

Depending on the country and year, the data relates to income (measured after taxes and benefits) or to consumption, per capita. 'Per capita' means that the incomes of each household are attributed equally to each member of the household (including children).

Non-market sources of income, including food grown by subsistence farmers for their own consumption, are taken into account.

Regional and global estimates are extrapolated up until the year of the data release using GDP growth estimates and forecasts. For more details about the methodology, please refer to the [World Bank PIP documentation](https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html#nowcasts).

NOTES ON HOW WE PROCESSED THIS INDICATOR

For most countries in the PIP dataset, estimates relate to _either_ disposable income or consumption, for all available years. A number of countries, however, have a mix of income and consumption data points, with both data types sometimes available for particular years.

In most of our charts, we present the data with some data points dropped in order to present single series for each country. This allows us to make readable visualizations that combine multiple countries and metrics. In choosing which data points to drop, we try to strike a balance between maintaining comparability over time and showing as long a time series as possible. As such, the exact approach varies somewhat across countries.

If you would like to see the original data with _all_ available income and consumption data points shown separately, you can do so by selecting _Income surveys only_ or _Consumption surveys only_ in the Household survey data type dropdown or by clicking on _Show breaks between less comparable surveys_.
Source: World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data  

#### How to cite this data

World Bank Poverty and Inequality Platform (2026) – processed by Our World in Data



    