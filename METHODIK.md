# Auswahl und Interpretation

## Daten und Einheiten

Die Eingaben stammen vollständig aus `data/`. Die Pipeline lädt keine neuen Armutsdaten. Sie zeichnet die MD5-Prüfsummen aller vier verwendeten Eingaben auf. Die gemeinsame Aufbereitung `R/01_data_prep.R` ist unverändert aus `roterFaden` (Stand `cb83cb8`) übernommen. Sie erzeugt nationale Erhebungen (`surveys.rds`), modellierte Aggregate (`aggregates.rds`) und chinesische Stadt-/Landdaten (`china.rds`) getrennt. Die Stadt-/Landdaten gehen nicht in nationale Vergleiche ein.

Nationale Quoten stehen in PIP als Anteile zwischen 0 und 1 (`headcount`). `pct_below_3` enthält für OWID-ausgewählte Erhebungen die bereits in Prozent vorliegende OWID-Quote, für die übrigen Erhebungen `100 * headcount`. Die Abweichung zwischen OWID und umgerechnetem PIP-Wert muss kleiner als 0,0001 Prozentpunkte sein. `poverty_pct` in der anschließenden Analyse ist ein Alias für `pct_below_3`. Eine Veränderung der Quote heißt Prozentpunktveränderung. Weitere Armutsgrenzen liegen bei nationalen Erhebungen nur für die OWID-ausgewählten Zeilen vor.

Kindersterblichkeit wird über Länderkennung und Jahr ergänzt und bezeichnet Todesfälle vor dem fünften Geburtstag je 100 Lebendgeburten. Unter den Aggregaten erhält ausschließlich die Weltreihe diese Variable: Die in der Sterblichkeitsdatei verwendeten geografischen Gruppen entsprechen nicht den Weltbankregionen. Die ergänzten Grafiken verwenden nationale Länderwerte.

Welt und Regionen verwenden die veröffentlichten, modellierten OWID/Weltbank-Aggregate. Nationale Erhebungen werden nicht ungewichtet zu Regionalwerten gemittelt. Der dargestellte Zeitraum 1990–2024 macht die Aggregate nicht zu direkten jährlichen Erhebungen. Prognosejahre 2025 und 2026 bleiben außerhalb des Hauptzeitraums.

## OWID-Auswahl

PIP kann für ein Land und Jahr sowohl Einkommen als auch Konsum enthalten. Die OWID-Länderreihe wählt jeweils einen Wert. Die gemeinsame Aufbereitung verwendet Länderkennung, Jahr und die Übereinstimmung der 3-Dollar-Quote für die Zuordnung. Mehrdeutige oder fehlende Zuordnungen brechen den Lauf ab. Die Analyse übernimmt anschließend ausschließlich das Kennzeichen `owid_selected`, ohne erneut zuzuordnen. Alle nationalen PIP-Erhebungen bleiben im Grunddatensatz erhalten, auch die nicht durch OWID ausgewählten. Die Datenaufbereitung mittelt die beiden Methoden nicht. Ländernamen folgen vorrangig OWID, Länderkennungen bleiben die Verknüpfungsschlüssel.

## Ländervergleich

Die Zieljahre sind 2010 und 2020. Das nächstgelegene nationale Erhebungsjahr innerhalb von jeweils ±2 Jahren entscheidet. Bei gleichem Abstand wird das frühere Jahr gewählt. Erforderlich sind mindestens acht Jahre Zeitspanne und drei Beobachtungen im tatsächlichen Intervall. Die Erhebungsart und sämtliche vorhandenen Vergleichbarkeitskennungen müssen innerhalb dieses Intervalls unverändert bleiben. Eine fehlende Kennung führt zum Ausschluss.

Zunächst entsteht eine Entscheidung je Land und Methode. Existieren mehrere geeignete Methoden, gewinnt die Reihe mit den meisten durch OWID ausgewählten Endpunkten. Danach entscheiden Zeitspanne, Beobachtungszahl und bei weiterem Gleichstand der alphabetische Methodenname. Die Tabelle `countries.csv` dokumentiert die Entscheidung. `candidates.csv` enthält auch ausgeschlossene Reihen samt Gründen.

Die Hauptgrafik zeigt die absolute Änderung der Armutsquote für die drei ausgewählten Fälle als Balken. Ein Balken entspricht der Differenz zwischen End- und Anfangsquote in Prozentpunkten. Die tatsächlichen Intervalle stehen direkt bei den Ländern und begrenzen Rangvergleiche. Die Auswahl der Fälle verwendet jährliche Änderungen, die Balken selbst zeigen absolute Änderungen. Die vollständigen 66 vergleichbaren Länderreihen bleiben in `countries.csv` dokumentiert. Die Grafik ist keine vollständige weltweite Rangliste.

## Fallauswahl

1. Stärkster Rückgang in Prozentpunkten pro Jahr unter den zulässigen Reihen.
2. Stärkster Anstieg unter den übrigen Reihen. Gibt es keinen Anstieg, entscheidet die geringste absolute jährliche Veränderung.
3. Ist bereits einer dieser Fälle gegenläufig zur Region, ergänzt der dritte Fall die größte absolute jährliche Abweichung von seinem Regionaltrend. Andernfalls wird zuerst eine gegenläufige Reihe gesucht. Fehlt auch diese, entscheidet die größte absolute Abweichung.

Die Regionaländerung verwendet exakt die tatsächlichen Endpunktjahre des jeweiligen Landes. Gegenläufigkeit bedeutet unterschiedliche Vorzeichen der Länder- und Regionaländerung. Null zählt weder als Anstieg noch als Rückgang. Die Fallauswahl bleibt deskriptiv. Unterschiedliche Ausgangsniveaus und Messgenauigkeiten müssen in der Diskussion berücksichtigt werden.

Die Pipeline exportiert zusätzliche Vergleiche mit ±1 Jahr und exakt gleichen Jahren. Das Kennzeichen `stable_narrow` beschreibt, ob dieselbe Erhebungsart auch im engeren Fenster verfügbar ist und dieselbe Änderungsrichtung zeigt. Fehlen dort Daten, wird das nicht als Widerlegung der Richtung ausgelegt. Die engere Verfügbarkeit wird nicht als zusätzliches Einschlusskriterium verwendet, weil dies Länder mit selteneren Befragungen nochmals ausschließen würde.

Die Zeitverlaufsgrafik konzentriert sich auf einen ausgewählten Gegenlauf, aktuell Simbabwe. Sie verwendet ausschließlich das tatsächliche Vergleichsintervall einer methodisch vergleichbaren nationalen Reihe. Die zugehörige Regionalquote ist ein modellierter Vergleichsmaßstab für dieselben Jahre. Zeitliche Parallelität oder Gegenläufigkeit belegt keine Ursache. Die Angaben zu allen drei ausgewählten Fällen stehen weiterhin in `cases.csv`.

## Erhebungsarten

Für jedes im nationalen PIP-Datensatz vertretene Land wird das jüngste Erhebungsjahr 2015–2024 gesucht. Kategorien sind Einkommen, Konsum, beide im selben jüngsten Jahr und keine Erhebung innerhalb dieses Fensters. Jedes Land zählt genau einmal. Der Nenner umfasst die Länder des Kursdatensatzes, nicht sämtliche Staaten der Welt. Die Übersicht beschreibt die jüngste verfügbare Datengrundlage und nicht sämtliche national durchgeführten Befragungen. Die Hauptgrafik verdeutlicht den Unterschied anhand von Europa und Zentralasien sowie Subsahara-Afrika. Alle sieben Regionen bleiben in `coverage_counts.csv` erhalten.

## Einkommen und Konsum

Die Paarbildung verwendet Länderkennung und Berichtsjahr. Es werden nur nationale Erhebungen mit 3-Dollar-Grenze und Jahren 1990–2024 verglichen. Die Differenz lautet `pct_below_3_income - pct_below_3_consumption` in Prozentpunkten. Sie entspricht bis auf die genannte Rundung `100 * (headcount_income - headcount_consumption)`.

Positive Werte bedeuten eine höhere einkommensbasierte Quote, negative eine höhere konsumbasierte Quote. Das Diagramm zeigt einen Balken für den Median der gepaarten Jahresdifferenzen je Land. Es ist der Median der Differenzen und nicht die Differenz zweier getrennt berechneter Mediane. n nennt die Anzahl verfügbarer Vergleichsjahre. Die Einzelpaare bleiben in `method_pairs.csv` erhalten. Das Diagramm enthält keine Konfidenzintervalle und behauptet keine statistische Unabhängigkeit wiederholter Jahre.

Die Tabelle dokumentiert Übereinstimmungen von Erhebungsbezeichnung, tatsächlichem Erhebungsjahr, geografischer Abdeckung und Vergleichbarkeitskennung. Kennungen verschiedener Methoden begründen für sich allein keine Stichprobengleichheit. Auch gleiche Bezeichnungen garantieren keine identische Stichprobe. Die beobachteten Unterschiede sind deshalb kein isolierter kausaler Methodeneffekt.

## Alternative Grenzen

Die zusätzlichen Reihen verwenden 3, 4,20 und 8,30 internationale Dollar in Kaufkraft von 2021. Alle stammen aus derselben Datenversion. Die Hauptgrafik konzentriert sich auf die Weltreihe und prüft die Richtung der Änderung über den gesamten Zeitraum. Regionale Eingabereihen bleiben in den aufbereiteten Daten erhalten. Höhere Grenzen verändern zwangsläufig die Niveaus. Für Aussagen über die Entwicklung sind zusätzlich Veränderungen, Richtungen und Zeitabschnitte zu vergleichen.

## Wirtschaftliche Lebensbedingungen und Gesundheit

Die Fragen nach BIP, Ungleichheit und Kindersterblichkeit werden in sechs zusätzlichen Grafiken behandelt. Die gemeinsame Aufbereitung aus `roterFaden` bleibt unverändert; die Erweiterung setzt in `code/02_living_conditions.R` auf ihren Daten auf. Die Indikatoren werden nicht als gleichwertige direkte Maße individueller Lebensqualität bezeichnet: BIP beschreibt wirtschaftliche Leistung, Gini die Verteilung von Einkommen bzw. Konsum und Kindersterblichkeit einen gesundheitlichen Ausgang.

### Querschnitt und Einheiten

Zieljahr ist 2020. Je Land wird die nächstgelegene nationale, durch OWID ausgewählte Erhebung innerhalb von ±2 Jahren verwendet. Gleichstand wird zugunsten des früheren Jahres gelöst. Die Auswahl erfolgt vor dem Ausschluss fehlender Indikatoren. Eine fehlende Kindersterblichkeit löst keinen Wechsel zu einer weiter entfernten Erhebung aus. Für jede Grafik werden danach nur Länder mit den benötigten Messwerten berücksichtigt. Der Auswahlbericht enthält alle 171 Länder des nationalen Katalogs, auch ohne passende Erhebung. Es gibt keine Interpolation, keine Ersetzung fehlender Werte und keine Bevölkerungsgewichtung.

2020 ist ein gemeinsames Referenzjahr mit breiter Erhebungsabdeckung; die tatsächlich verwendeten Berichtsjahre liegen 2018–2022. Es ist kein exakter Gleichjahresvergleich und keine Aussage über einen Zustand vor der Pandemie. Der BIP-Vergleich umfasst 130, der Sterblichkeitsvergleich 129 Länder. Kindersterblichkeit wird über die exakte Länderkennung und das tatsächliche Berichtsjahr zugeordnet. Die Haushalte der Armutsbefragung werden nicht mit einzelnen Sterbefällen verknüpft.

`reporting_gdp` ist jährliches BIP pro Kopf in konstanten US-Dollar von 2015, laut [offiziellem Weltbank-PIP-Quellcode](https://github.com/worldbank/pip/blob/master/pip_cl.ado). Diese Größe ist nicht in denselben Kaufkrafteinheiten wie die internationale Armutsgrenze angegeben. Die logarithmische BIP-Achse macht Faktoren vergleichbar; der Vergleich ist keine Schätzung der Wirkung eines zusätzlichen Dollars BIP. Gini-Werte im Kursdatensatz liegen zwischen 0 und 1 und werden nur für die Analysesicht mit 100 auf die Skala 0–100 gebracht. Das mitgelieferte Wörterbuch nennt bereits die 0–100-Skala; die tatsächliche Rohdatenskalierung wird deshalb explizit geprüft.

Die Ungleichheitsgrafik trennt Einkommen und Konsum. Sie hält BIP und durchschnittliches Einkommen bzw. durchschnittlichen Konsum nicht konstant. Aus der positiven Assoziation lässt sich kein isolierter Verteilungseffekt ableiten. Nationale Mittelwerte erlauben zudem keine Aussagen darüber, welche einzelnen Bevölkerungsgruppen von Entwicklungen profitieren.

### Zeitliche Stabilität der Verbindung zur Kindersterblichkeit

Um 2000, 2010 und 2020 wird dieselbe Auswahlregel angewendet. Gezeigt wird ausschließlich die Schnittmenge der Länder mit Armutsquote und Kindersterblichkeit in allen drei Fenstern: 80 Länder, jeweils ein Punkt pro Land und Fenster, identische Achsen. Die tatsächlichen Jahre stehen in den Daten und an den Feldern. Der Vergleich beschreibt wiederholte Querschnitte. Erhebungsart und Vergleichbarkeitsabschnitte dürfen zwischen den Fenstern wechseln; diese Verfügbarkeit wird im Panelbericht dokumentiert. Die Felder sind kein Nachweis methodisch unveränderter nationaler Reihen über 20 Jahre.

Spearman-Rangkorrelationen ergänzen die sichtbaren Muster in den Tabellen. Sie beschreiben monotone Zusammenhänge ohne einen linearen Zusammenhang vorauszusetzen. Es werden keine kausalen Effekte, Signifikanztests oder Konfidenzintervalle behauptet. Wiederholte Länder in verschiedenen Fenstern werden nicht als unabhängige zusätzliche Länder gezählt. Der gleichgerichtete Zusammenhang bleibt sichtbar; daraus folgt keine unveränderte Stärke.

### Fallbeispiele und Länder mit höherem BIP

Die Kindersterblichkeits-Fallgrafik übernimmt dieselben drei Länder und tatsächlichen Endpunkte aus der bestehenden Armutsanalyse. Es wird keine neue Auswahl anhand besonders großer Sterblichkeitsänderungen getroffen. Das Gegenbeispiel Simbabwe zeigt sinkende Kindersterblichkeit bei steigender monetärer Armut. Zeitliche Gegenläufigkeit erklärt ihre Ursachen nicht und widerlegt keinen möglichen individuellen Armutszusammenhang.

Eine ergänzende Gruppe umfasst Länder mit mindestens 20.000 US-Dollar BIP pro Kopf in Preisen von 2015 im jeweils ausgewählten Jahr. Dies ist eine eigene transparente BIP-Abgrenzung, keine offizielle Weltbank-Einkommensklasse. Die Grafik verwendet dieselben 26 Länder und dieselben Jahre unter 3 und 40 internationalen Dollar pro Tag; nur die Armutsgrenze wechselt. Die Kindersterblichkeitsskala bleibt gleich, die x-Skalen unterscheiden sich sichtbar. Die 40-Dollar-Grenze ist eine Vergleichsgrenze aus dem vorhandenen Datensatz und keine internationale Definition extremer Armut.

In dieser Gruppe bleiben die beobachteten Zusammenhänge schwach, auch bei 40 Dollar. Der Befund ist von der BIP-Abgrenzung abhängig: `higher_gdp_sensitivity.csv` zeigt auch 10.000 und 30.000 US-Dollar sowie die Grenzen 3, 8,30 und 40 Dollar. Bei der breiteren 10.000-Dollar-Gruppe ist der Zusammenhang unter höheren Armutsgrenzen stärker. Deshalb wird das schwache Ergebnis nicht auf alle wohlhabenderen Länder oder alle Abgrenzungen verallgemeinert.

Wasserzugang, Bildung, Ernährung und Lebenserwartung sind im vorliegenden Datenauszug nicht als zusätzliche Messreihen enthalten. Das umfangreichere PIP-Wörterbuch nennt zwar weitere Variablen, die CSV enthält diese Spalten jedoch nicht. Die Analyse behauptet für diese Bereiche keine gemessenen Zusammenhänge. Mögliche Ursachen wie Gesundheitsversorgung, Wasser und Ernährung werden nicht aus diesen Daten isoliert.
