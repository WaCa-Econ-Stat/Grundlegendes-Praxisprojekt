# Leben unter 3 Dollar am Tag

Neues Analyseprojekt für das Grundlegende Praxisprojekt, WiSe 2026/27.

Die Analyse beginnt mit Welt und Regionen, untersucht vergleichbare Länderreihen und ordnet anschließend die Einkommens- und Konsumdaten ein. Sechs Kerngrafiken und ein ergänzender Vergleich anderer Armutsgrenzen bilden den Aufbau.

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
- **`output/figures/`**: sieben Grafiken als PNG und SVG. Die SVG-Dateien lassen sich verlustfrei skalieren.
- **`output/ergebnisse.md`**: kurze Ergebnisübersicht.
- **`output/tables/`**: Datengrundlagen der Grafiken, Auswahl- und Ausschlussentscheidungen, Methodenpaare und Empfindlichkeit gegenüber den Zeitfenstern.
- **`output/results/`**: Abbildungsmanifest, Konfiguration, Datenprüfungen, Prüfsummen der Eingaben und verwendete R-Sitzung.

Generierte Ergebnisse und Paketbibliotheken sind in Git ausgeschlossen. Sie entstehen erneut mit `run_all.R`. Die Quelldaten bleiben unverändert und werden beim Ausführen nicht aus dem Internet aktualisiert.

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

Jede Grafik stellt eine zentrale Aussage in den Titel. Die Darstellung zeigt die dafür nötigen Vergleiche mit direkten Beschriftungen. Das Manifest enthält die Aussage im Feld `takeaway` und die zugehörige kurze Erläuterung. Vollständige Länder- und Jahresdaten bleiben in den Tabellen erhalten.

## Einstellungen und Änderungen

Die zentralen Einstellungen stehen am Anfang von `code/00_setup.R`: Analysezeitraum, Länderfenster, Mindestzeitspanne, Mindestanzahl der Erhebungen, Aktualitätsfenster, Auflösung und der optionale Schwellenvergleich.

Nach dem Laden von `run_all.R` können Einstellungen auch gezielt übergeben werden:

```r
result <- run_project(project_root, config = list(include_thresholds = FALSE))
```

Das erzeugt die sechs Kerngrafiken und einen dazu passenden Bericht. Bereits erzeugte, jetzt nicht verwendete Bilddateien bleiben erhalten. Das aktuelle Abbildungsmanifest entscheidet, welche Grafiken zum aktuellen Lauf gehören.

## Projektstruktur

```text
code/
  00_setup.R                 Einstellungen, Bibliotheken und Regionszuordnung
  00_helpers.R               Prüfungen, Beschriftung und Grafikexport
  01_prepare_data.R          Quelldaten und eindeutige OWID/PIP-Zuordnung
  02_build_analysis_data.R   Länderreihen, Fallauswahl, Erhebungsarten und Paare
  03_make_figures.R          Grafiken
  04_build_report.R          Bericht und Ergebnisübersicht
data/                       Unveränderte Kursdaten und Metadaten
tests/run_checks.R          Fachliche Prüfungen und Integration
ANALYSEKONZEPT.md            Gliederung und Gestaltungsideen
METHODIK.md                 Verbindliche Auswahl- und Interpretationsregeln
run_all.R                   Einstiegspunkt
renv.lock                   Aufgezeichnete Paketversionen
```

Die nicht verwendeten weiteren Kursdaten bleiben als Quellenmaterial erhalten. Die alten Analyseskripte liegen im ursprünglichen Stand von `main`. Der Neubau erfolgt auf `codex/neustart-armutsanalyse`.

## Prüfen

Nach einem vollständigen Lauf:

```r
source("tests/run_checks.R")
```

Die Prüfungen verwenden künstliche Problemfälle für Zeitfenster, Nullquoten, Vergleichbarkeitsbrüche, Methodenwahl und Paarbildung. Anschließend prüfen sie die tatsächlich erzeugten Daten, Abbildungen und Eingabeprüfsummen.

## Quellen und Vorlagen

Weltbank Poverty and Inequality Platform (2026), aufbereitet durch Our World in Data. Internationale Dollar in Kaufkraft von 2021.

- [Armutsquoten für Welt, Regionen und Länder](https://ourworldindata.org/grapher/share-of-population-in-extreme-poverty)
- [Poverty Data Explorer](https://ourworldindata.org/explorers/poverty-explorer)
- [Vergleich anderer Armutsgrenzen](https://ourworldindata.org/grapher/share-in-poverty-relative-to-different-poverty-thresholds)
- [Datenabdeckung durch Haushaltsbefragungen](https://ourworldindata.org/grapher/data-deprivation-poverty-surveys-per-decade)

Die Linienansichten und sichtbaren Vergleichbarkeitsbrüche dienen als visuelle Orientierung. Länderbalkenvergleich, Erhebungsartenübersicht und Differenzbalken sind eigene Auswertungen des Kursdatensatzes.
