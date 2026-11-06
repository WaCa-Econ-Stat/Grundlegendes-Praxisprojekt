# Gemeinsame Datenaufbereitung aus roterFaden

`01_data_prep.R` wurde unverändert aus dem gepushten Branch `origin/roterFaden` übernommen.

- Commit: `cb83cb8b6218ef2375f250c7895ec2fd18c69708`
- Git-Blob des Skripts: `ff955322d48a34797c266f84d3d9d6cf93b5ed0d`
- Quelldateien: `data/owid_poverty_lines.csv`, `data/worldbank_pip.csv`, `data/owid_country_codes.csv`, `data/owid_child_mortality.csv`.

Die vier Quelldateien sind auf beiden Branches identisch. Die Übernahme benötigt nur `data.table`, das bereits zu unseren Abhängigkeiten gehört. Ein Fetch aktualisiert das übernommene Skript nicht automatisch; spätere Änderungen lassen sich gezielt mit dem gemeinsamen Branch vergleichen.

## Erzeugte Datensätze

| Datei unter `data_clean/` | Beobachtungseinheit | Schlüssel |
| --- | --- | --- |
| `surveys.rds` | Nationale Erhebung je Land, Berichtsjahr und Einkommens-/Konsummethode | `country_code`, `year`, `welfare_type` |
| `aggregates.rds` | Modelliertes Aggregat je Jahr | `region_name`, `year` |
| `china.rds` | Chinesische Stadt-/Landerhebung je Jahr und Methode | `country_code`, `reporting_level`, `year`, `welfare_type` |

`surveys.rds` enthält auch Erhebungen, die OWID nicht ausgewählt hat. Das Kennzeichen `owid_selected` dokumentiert die Auswahl. `pct_below_3` ist für alle Erhebungen in Prozent verfügbar; weitere `pct_below_*`-Spalten sind nur für OWID-ausgewählte Erhebungen gefüllt. PIP-Kennzahlen wie `headcount` bleiben Anteile zwischen 0 und 1. `child_mortality` steht in Todesfällen vor dem fünften Geburtstag je 100 Lebendgeburten und ist bei Aggregaten nur für die Welt verfügbar.

`aggregates.rds` unterscheidet `type = world`, `region` und `other`. Werte nach 2024 sind mit `is_projection` markiert. Die chinesischen Stadt-/Landdaten bleiben getrennt; die nationale chinesische Reihe steht in `surveys.rds`.

## Anschluss an die Analyse

`run_all.R` ruft `code/01_prepare_data.R` auf. Dieser Adapter führt das gemeinsame Skript in einer eigenen R-Umgebung aus, liest seine drei RDS-Dateien und ergänzt die Analysesicht:

- Filter auf den eingestellten Zeitraum, standardmäßig 1990–2024.
- `poverty_pct` als Alias für `pct_below_3` bei nationalen Erhebungen.
- `below_*` als zusätzliche Namen für `pct_below_*` bei Welt- und Regionalreihen.
- Deutsche Regionsbeschriftungen und Farben anhand von `region_code`.

Die Zuordnung von OWID zu PIP, die Erhebungsauswahl und die Quoten stammen vollständig aus dem gemeinsamen Skript. Die drei Grunddateien werden vom Adapter nicht verändert. Die weitere Fallauswahl, Grafiken und Bericht bleiben in `code/02_build_analysis_data.R` bis `code/04_build_report.R`.

Für eine eigenständige Ausführung im Projektordner reicht bei installiertem `data.table`:

```r
source("R/01_data_prep.R")
```

Im vollständigen Projekt übernimmt `setup_project()` die Paketpfade. Danach genügen `source("run_all.R")` und `source("tests/run_checks.R")`.
