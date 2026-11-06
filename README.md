# Leben unter 3 Dollar am Tag

Neues Analyseprojekt für das Grundlegende Praxisprojekt, WiSe 2026/27.

Die Analyse beginnt mit Welt und Regionen, untersucht vergleichbare Länderreihen und ordnet die Einkommens- und Konsumdaten ein. Anschließend vergleicht sie Armut mit wirtschaftlichen Lebensbedingungen und Kindersterblichkeit. Zwölf Kerngrafiken und ein ergänzender Vergleich anderer Armutsgrenzen bilden den Aufbau.

## Start in RStudio

`Extreme-Armut.Rproj` öffnen. Beim ersten Start die benötigten Pakete installieren:

```r
source("restore_packages.R")
```

Anschließend die vollständige Analyse ausführen:

```r
source("run_all.R")
```

Im Terminal funktioniert `Rscript --vanilla run_all.R`. Das Skript findet den Projektordner auch dann, wenn es aus dem übergeordneten Ordner gestartet wird. Getestet mit R 4.5.1 unter Windows.

`restore_packages.R` verwendet die aufgezeichneten Paketversionen. Mit `source("install_packages.R")` lassen sich stattdessen die aktuell verfügbaren Versionen installieren. Die Skripte installieren Pakete in `.Rlibrary/R-<Version>` und ändern keine globale R-Bibliothek. Das Öffnen des Projekts startet keine Paketinstallation.

## Ergebnisse ansehen

- **`output/bericht.html`**: Bericht mit allen Grafiken, zentralen Aussagen, Fallauswahl und Grenzen. Die Grafiken sind eingebettet. Die HTML-Datei lässt sich einzeln weitergeben und offline öffnen.
- **`output/figures/`**: dreizehn Grafiken als PNG und SVG. Die SVG-Dateien lassen sich verlustfrei skalieren.
- **`output/ergebnisse.md`**: kurze Ergebnisübersicht.
- **`output/tables/`**: Datengrundlagen der Grafiken, Auswahl- und Ausschlussentscheidungen, Methodenpaare und Empfindlichkeit gegenüber den Zeitfenstern.
- **`output/results/`**: Abbildungsmanifest, Konfiguration, Datenprüfungen, Prüfsummen der Eingaben und verwendete R-Sitzung.

Generierte Ergebnisse und Paketbibliotheken sind in Git ausgeschlossen. Sie entstehen erneut mit `run_all.R`. Die Quelldaten bleiben unverändert und werden beim Ausführen nicht aus dem Internet aktualisiert.

## Gemeinsame Datenaufbereitung

Die Datenaufbereitung kommt unverändert aus `roterFaden`, Stand `cb83cb8` (`R/01_data_prep.R`). Sie erzeugt drei getrennte Grundlagen:

- `data_clean/surveys.rds`: nationale Erhebungen mit Einkommens-/Konsummethode, OWID-Auswahl, Armutsquoten und Kindersterblichkeit.
- `data_clean/aggregates.rds`: modellierte Welt- und Regionalreihen sowie weitere Aggregate; Prognosejahre sind gekennzeichnet.
- `data_clean/china.rds`: getrennte Stadt-/Landdaten für China. Sie werden aufbewahrt und gehen nicht in unsere nationalen Ländervergleiche ein.

`code/01_prepare_data.R` führt diese gemeinsame Aufbereitung aus und stellt anschließend den Analysezeitraum, deutsche Regionsbeschriftungen und die bisherigen Spaltennamen für die Grafiken bereit. Die OWID-Auswahl wird direkt aus `owid_selected` übernommen. Es gibt keine zweite Zuordnung von OWID und PIP. Alle drei vollständigen Grunddatensätze bleiben erhalten; `prepared_data.rds` und `analysis_data.rds` sind daraus abgeleitete Analyseobjekte. Details und Herkunft stehen in `R/README.md`.

## Grafiken

| Datei | Inhalt |
| --- | --- |
| `01_weltweiter_verlauf` | Weltweite Armutsquote 1990–2024 |
| `02_regionale_verlaeufe` | Ausgangs- und Endquote der sieben Weltregionen, Subsahara-Afrika hervorgehoben |
| `03_laendervergleich` | Direkter Balkenvergleich der Veränderungen in drei ausgewählten Ländern |
| `04_laender_im_regionalen_vergleich` | Ein Land als Beispiel für einen Gegenlauf zum Regionaltrend |
| `05_erhebungsarten` | Gegensatz von Einkommen und Konsum in Europa/Zentralasien und Subsahara-Afrika |
| `06_einkommen_konsum_differenzen` | Ein Balken für den Median der Methodenunterschiede je Land |
| `07_alternative_armutsgrenzen` | Drei weltweite Verläufe unter 3, 4,20 und 8,30 int. Dollar pro Tag |
| `08_bip_und_armut` | BIP und Armut: regionale Farben, Punktflächen nach Bevölkerung |
| `09_ungleichheit_und_armut` | Gini und Armut, getrennt nach Erhebungsart und farblich nach Region |
| `10_kindersterblichkeit_und_armut` | OWID-inspirierter Vergleich mit regionalen Farben und Bevölkerungsflächen |
| `11_kindersterblichkeit_zeitvergleich` | Zwei feste Armutsgruppen aus denselben 80 Ländern; direkt beschriftete Medianverläufe |
| `12_kindersterblichkeit_fallbeispiele` | Simbabwe: Armuts- und Sterblichkeitsverlauf untereinander, dieselben Jahre |
| `13_hoehere_grenze_kindersterblichkeit` | 3- und 40-Dollar-Grenze, regionale Farben und direkte Ländernamen |

Jede Grafik stellt eine zentrale Aussage in den Titel. Die Darstellung zeigt die dafür nötigen Vergleiche mit direkten Beschriftungen. Das Manifest enthält die Aussage im Feld `takeaway` und die zugehörige kurze Erläuterung. Vollständige Länder- und Jahresdaten bleiben in den Tabellen erhalten.

Die sechs Grafiken zu Lebensbedingungen sind an konkreten OWID-Darstellungen orientiert: regionale Länderfarben, Bevölkerung als Punktfläche, direkt beschriftete Linien und ruhige Achsen. Der Bericht verlinkt unter jeder dieser Grafiken die Vorlage und erläutert die Anpassung. `owid_reference` und `design_note` im Manifest dokumentieren dies ebenfalls. Die Umsetzung ist eigener R-Code; Messwerte, Weltbankregionen und Erhebungsauswahl stammen weiterhin aus unserem Kursprojekt.

Die neuen Grafiken beantworten die Fragen nach wirtschaftlichen Indikatoren und Kindersterblichkeit. Sie beschreiben Zusammenhänge zwischen Ländern. Eine Wirkung von Armut auf einzelne Menschen wird damit nicht geschätzt. Direkte Messreihen zu Wasserzugang, Bildung oder Lebenserwartung sind im Kursauszug nicht enthalten. Kindersterblichkeit ist der vorhandene gesundheitliche Indikator.

Für die neuen Querschnitte wird je Land zunächst die OWID-Erhebung mit dem geringsten Abstand zu 2020 innerhalb von ±2 Jahren ausgewählt. Erst danach werden fehlende Indikatoren ausgeschlossen. Kindersterblichkeit und Armut gehören immer zum selben tatsächlichen Berichtsjahr. Alle Auswahlen und Fehlstellen stehen in `indicator_audit.csv`; Rangkorrelationen in `indicator_associations.csv`. Die festen Zeitverlaufsgruppen und ihre Mediane stehen in `mortality_group_membership.csv` und `mortality_groups.csv`, die Simbabwe-Verläufe in `mortality_focus.csv`. Die BIP-Abgrenzung der letzten Grafik wird zusätzlich bei 10.000, 20.000 und 30.000 US-Dollar geprüft (`higher_gdp_sensitivity.csv`).

## Einstellungen und Änderungen

Die zentralen Einstellungen stehen am Anfang von `code/00_setup.R`: Analysezeitraum, Länderfenster, Mindestzeitspanne, Mindestanzahl der Erhebungen, Aktualitätsfenster, Indikator-Zieljahr und Zeitfenster, Sterblichkeits-Vergleichsjahre, BIP-Abgrenzung, Auflösung und der optionale Schwellenvergleich.

Nach dem Laden von `run_all.R` können Einstellungen auch gezielt übergeben werden:

```r
result <- run_project(project_root, config = list(include_thresholds = FALSE))
```

Das erzeugt die zwölf Kerngrafiken und einen dazu passenden Bericht. Bereits erzeugte, jetzt nicht verwendete Bilddateien bleiben erhalten. Das aktuelle Abbildungsmanifest entscheidet, welche Grafiken zum aktuellen Lauf gehören.

## Projektstruktur

```text
R/
  01_data_prep.R             Unveränderte gemeinsame Aufbereitung aus roterFaden
  README.md                  Herkunft, Datensätze und Einheiten
code/
  00_setup.R                 Einstellungen, Bibliotheken und Regionszuordnung
  00_helpers.R               Prüfungen, Beschriftung und Grafikexport
  01_prepare_data.R          Aufbereitung ausführen und Analyse anschließen
  02_build_analysis_data.R   Länderreihen, Fallauswahl, Erhebungsarten und Paare
  02_living_conditions.R     Indikator-Querschnitte, Zeitvergleich und Prüfungen
  03_make_figures.R          Grafiken
  03_living_conditions_figures.R  Sechs Grafiken zu Lebensbedingungen
  04_build_report.R          Bericht und Ergebnisübersicht
data/                       Unveränderte Kursdaten und Metadaten
tests/run_checks.R          Fachliche Prüfungen und Integration
ANALYSEKONZEPT.md            Gliederung und Gestaltungsideen
METHODIK.md                 Verbindliche Auswahl- und Interpretationsregeln
run_all.R                   Einstiegspunkt
renv.lock                   Aufgezeichnete Paketversionen
```

Die weiteren Kursdaten bleiben als Quellenmaterial erhalten. Die alten Analyseskripte liegen im ursprünglichen Stand von `main`. Der Neubau erfolgt auf `codex/neustart-armutsanalyse`.

## Prüfen

Nach einem vollständigen Lauf:

```r
source("tests/run_checks.R")
```

Die Prüfungen verwenden künstliche Problemfälle für Zeitfenster, Nullquoten, Vergleichbarkeitsbrüche, Methodenwahl und Paarbildung. Anschließend prüfen sie die Übernahme der gemeinsamen Datensätze, die Trennung der Beobachtungsebenen, Einheiten, OWID-Auswahl, Kindersterblichkeit, erzeugte Abbildungen und Eingabeprüfsummen.

## Quellen und Vorlagen

Weltbank Poverty and Inequality Platform (2026), aufbereitet durch Our World in Data. Internationale Dollar in Kaufkraft von 2021.

- [Armutsquoten für Welt, Regionen und Länder](https://ourworldindata.org/grapher/share-of-population-in-extreme-poverty)
- [Poverty Data Explorer](https://ourworldindata.org/explorers/poverty-explorer)
- [Vergleich anderer Armutsgrenzen](https://ourworldindata.org/grapher/share-in-poverty-relative-to-different-poverty-thresholds)
- [Datenabdeckung durch Haushaltsbefragungen](https://ourworldindata.org/grapher/data-deprivation-poverty-surveys-per-decade)
- [Kindersterblichkeit: UN IGME/Gapminder via OWID](https://ourworldindata.org/grapher/child-mortality)
- [Konkrete Vorlage: Kindersterblichkeit und extreme Armut](https://ourworldindata.org/grapher/extreme-poverty-vs-child-mortality)
- [Konkrete Vorlage: direkt beschriftete Sterblichkeitsverläufe nach Einkommensgruppe](https://ourworldindata.org/grapher/child-mortality-by-income-level-of-country)
- [Konkrete Vorlage: wirtschaftliche Indikatoren im regionalen Ländervergleich](https://ourworldindata.org/grapher/gini-coefficient-vs-gdp-per-capita-pip)
- [Weltbank-PIP-Quellcode mit Einheit von `reporting_gdp`](https://github.com/worldbank/pip/blob/master/pip_cl.ado)

Die Linienansichten und sichtbaren Vergleichbarkeitsbrüche dienen als visuelle Orientierung. Länderbalkenvergleich, Erhebungsartenübersicht und Differenzbalken sind eigene Auswertungen des Kursdatensatzes.
