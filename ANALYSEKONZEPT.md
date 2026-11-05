# Neues Projektkonzept: Extreme Armut seit 1990

Arbeitsfassung vom 5. November 2026. Dieses Dokument legt Gliederung, Grafiken und Auswahlregeln fest. Es enthält noch keine neu gebauten Grafiken und keine abschließenden Ergebnisbehauptungen.

## Leitfrage und Aufbau

**Wie hat sich extreme Armut weltweit, regional und in einzelnen Ländern entwickelt, und wie beeinflusst die Datengrundlage unsere Vergleiche?**

Reihenfolge des Vortrags:

1. Gegenstand und Daten kurz erklären: 3 internationale Dollar, Kaufkraft von 2021, Einkommen und Konsum; nationale Erhebungen und modellierte Aggregate unterscheiden.
2. Weltweite Entwicklung zeigen.
3. Regionale Unterschiede untersuchen.
4. Veränderungen zwischen Ländern vergleichen und drei begründet ausgewählte Fälle vertiefen.
5. Verfügbarkeit und Unterschiede von Einkommens- und Konsumdaten analysieren.
6. Optional: prüfen, ob andere Armutsgrenzen die beobachteten Trends verändern.
7. Die Leitfrage beantworten und die wichtigsten Grenzen einordnen.

Der Kern umfasst sechs Grafiken. Der optionale Vergleich anderer Armutsgrenzen ergänzt eine siebte. Einführungs- und Schlussfolien benötigen keine zusätzlichen Ergebnisgrafiken.

## Grafik 1: Der weltweite Verlauf

- **Frage:** Wie hat sich der Anteil der Weltbevölkerung unter 3 internationalen Dollar pro Tag seit 1990 verändert?
- **Darstellung:** Eine Linie; x = Jahr, y = Bevölkerungsanteil in Prozent. Anfangs- und Endwert direkt beschriften. Die y-Achse beginnt bei null.
- **Daten:** Die vorhandene Weltreihe aus `owid_poverty_lines.csv`, 1990–2024.
- **Aussageziel:** Richtung, Ausmaß und zeitlicher Verlauf der Veränderung. Einzelne Unterbrechungen werden erst nach Prüfung hervorgehoben; zeitliches Zusammentreffen begründet keine Ursache.
- **OWID-Vorlage:** [Share of population living in extreme poverty – World, 1990–2024](https://ourworldindata.org/grapher/share-of-population-in-extreme-poverty?tab=chart&time=1990..2024&country=~OWID_WRL).
- **Übernehmen:** Ruhige Gestaltung, wenige Achsenmarken, direkte Beschriftung, verständliche Einheit und Quellenzeile.

## Grafik 2: Die regionalen Verläufe

- **Frage:** Welche Weltregionen unterscheiden sich im Ausgangsniveau, in der Veränderung und im jüngsten Niveau?
- **Darstellung:** Sieben kleine Liniendiagramme mit gleicher Zeitachse und gleicher Prozentskala. Pro Feld eine Region; Anfangs- und Endwert beschriften. Die gemeinsame Skala muss sämtliche regionalen Werte abdecken und bei null beginnen.
- **Daten:** Die sieben Weltbank-Regionalreihen aus dem Kursdatensatz, 1990–2024. Unterregionen Afrikas werden nicht zusätzlich neben Subsahara-Afrika gezählt.
- **Regel:** Veröffentlichte Regionalaggregate verwenden. Ein ungewichteter Mittelwert der verfügbaren Länderwerte ersetzt diese nicht.
- **Aussageziel:** Herausarbeiten, welche Unterschiede eine einzelne Weltlinie verdeckt.
- **OWID-Vorlage:** [Dieselbe Armutsquoten-Grafik](https://ourworldindata.org/grapher/share-of-population-in-extreme-poverty), mit den sieben Weltbankregionen ausgewählt. Die Mehrlinienansicht wurde angesehen; für unseren Vortrag wird sie in einzelne Felder aufgeteilt, damit die dichten Linien und Beschriftungen am unteren Rand lesbar bleiben.

## Grafik 3: Länder am Anfang und Ende eines Vergleichszeitraums

- **Frage:** Welche Veränderungen treten innerhalb der verfügbaren vergleichbaren Länderreihen auf?
- **Darstellung:** Streudiagramm; x = Armutsquote am Anfang, y = Armutsquote am Ende. Beide Achsen erhalten dieselbe Skala. Die Diagonale bedeutet unveränderte Quote; Punkte darunter zeigen einen Rückgang, Punkte darüber einen Anstieg. Ein Punkt je Land, Farbe nach Region.
- **Zeitrahmen:** Zieljahre 2010 und 2020. Nationale Erhebungen werden innerhalb von 2008–2012 beziehungsweise 2018–2022 gesucht. Der geringste Abstand zum Zieljahr entscheidet; bei gleichem Abstand wird das frühere Jahr gewählt.
- **Einschluss:** Mindestens acht Jahre zwischen den tatsächlichen Endpunkten und mindestens drei nationale Beobachtungen im Intervall. Dieselbe Erhebungsart und eine durchgehend vorhandene, unveränderte Vergleichbarkeitskennung sind erforderlich. Fehlende Quoten werden nicht ergänzt.
- **Mehrere geeignete Reihen:** Die von OWID durchgängig ausgewählte Reihe bevorzugen. Mehrdeutige Fälle separat prüfen; Länder nicht unbemerkt doppelt zählen.
- **Beschriftung:** Tatsächliche Jahre für hervorgehobene Länder nennen; die Zeitfenster und die Zahl eingeschlossener Länder stehen in der Bildunterschrift.
- **Aussagegrenze:** Dies ist eine Auswahl verfügbarer vergleichbarer Länderreihen. Daraus entsteht keine vollständige weltweite Rangliste. Unterschiedliche tatsächliche Intervalle bleiben bei der Interpretation relevant.
- **Prüfung:** Auffällige Fälle zusätzlich mit engeren Zeitfenstern und den dazwischenliegenden Erhebungen prüfen. Ein einzelner Endpunkt soll die Fallauswahl nicht allein tragen.
- **Herkunft:** Eigene Auswertung; die OWID-Länderzeitreihen liefern Daten- und Gestaltungsorientierung. Für dieses Streudiagramm wird keine identische OWID-Vorlage behauptet.

## Grafik 4: Drei begründet ausgewählte Länder und ihre Regionen

- **Frage:** Wie verlaufen auffällige Entwicklungen über die Zeit, und wie passen sie zum regionalen Verlauf?
- **Darstellung:** Drei kleine Zeitverlaufsdiagramme für die verfügbaren Jahre innerhalb von 1990–2024. Nationale Erhebungen als Punkte; Linien nur innerhalb vergleichbarer Abschnitte. Die jeweilige modellierte Regionalquote liegt als zweite, klar unterscheidbare Linie dahinter. Gemeinsame Achsen soweit lesbar.
- **Auswahl:** Aus den zulässigen Reihen von Grafik 3 werden drei verschiedene Fälle bestimmt: ein starker Rückgang, ein Anstieg oder eine ausgeprägte Stagnation und ein Fall zur regionalen Abweichung. Ist der Anstiegsfall bereits gegenläufig zur Region, zeigt der dritte Fall eine weitere Form der regionalen Abweichung. Die genaue Auswahl und die Prüfung engerer Zeitfenster stehen in `METHODIK.md`.
- **Auswahlmaß:** Veränderungen zusätzlich in Prozentpunkten pro Jahr betrachten und die Ausgangsquote berücksichtigen. Eine jährliche Umrechnung beseitigt Unterschiede der Zeiträume nicht. Die endgültige Auswahl folgt der Prüfung der gesamten Reihe.
- **Regionalvergleich:** Für die Klassifikation einer gegenläufigen Entwicklung exakt die tatsächlichen Anfangs- und Endjahre des Landes verwenden. Ein Anstieg im Land bei einem Rückgang der Regionalquote ist ein möglicher Gegenlauf.
- **Aussageziel:** Zeitliche Muster und Abweichungen beschreiben. Ursachen werden nur bei gesonderter inhaltlicher Prüfung diskutiert.
- **OWID-Vorlage:** [Poverty Data Explorer mit sichtbaren Vergleichbarkeitsbrüchen](https://ourworldindata.org/explorers/poverty-explorer?Indicator=Share+in+poverty&Poverty+line=%243+per+day%3A+International+Poverty+Line&Household+survey+data+type=Show+data+from+both+income+and+consumption+surveys&Show+breaks+between+less+comparable+surveys=true&country=BGD~BOL~KEN~MOZ~NGA~ZMB). Die Linienansicht wurde angesehen: einzelne Länderfelder, Farben nach Erhebungsart und unterbrochene Linien zwischen weniger vergleichbaren Abschnitten. Unsere Ergänzung ist die systematische Gegenüberstellung mit der zugehörigen Region. Die in der verlinkten Vorlage ausgewählten Länder legen unsere Fallauswahl nicht fest.

## Grafik 5: Welche Erhebungsarten stehen zur Verfügung?

- **Frage:** Wie unterscheiden sich die im Datensatz vertretenen Regionen hinsichtlich der jüngsten verfügbaren Einkommens- und Konsumdaten?
- **Darstellung:** Ein horizontaler 100-Prozent-Balken je Region, unterteilt in Einkommen, Konsum, beide und keine aktuelle Erhebung. Die Zahl der zugrunde liegenden Länder wird daneben angegeben.
- **Zähleinheit:** Jedes Land zählt einmal. Für 2015–2024 wird das jüngste nationale Erhebungsjahr je Land verwendet. Liegen in diesem Jahr beide Erhebungsarten vor, lautet die Kategorie „beide“.
- **Grundgesamtheit:** Die Länder, die in den nationalen PIP-Daten des Kurses überhaupt vertreten sind. Ohne nationale Erhebung 2015–2024 fallen sie in „keine aktuelle Erhebung“. Das ist keine vollständige Bestandsaufnahme sämtlicher Staaten der Welt.
- **Aussageziel:** Sichtbar machen, welche Daten die regionalen Vergleiche tragen. Der Balken beschreibt die Verfügbarkeit im Datensatz, nicht die gesamte nationale Erhebungspraxis.
- **OWID-Anregung:** [Number of income/consumption surveys in the past decade](https://ourworldindata.org/grapher/data-deprivation-poverty-surveys-per-decade). Dort geht es um zeitliche Datenabdeckung; unsere Unterteilung nach Erhebungsart ist eine eigene Auswertung.

## Grafik 6: Einkommen und Konsum innerhalb derselben Länder und Jahre

- **Frage:** Wie groß sind die beobachteten Unterschiede zwischen einkommens- und konsumbasierten Armutsquoten, und wie unterscheiden sie sich zwischen Ländern und Jahren?
- **Darstellung:** Differenzdiagramm; x = Einkommensquote minus Konsumquote in Prozentpunkten, y = Land. Jeder kleine Punkt steht für ein Land-Jahr-Paar. Ein größeres Symbol zeigt den Median der verfügbaren Differenzen je Land; eine senkrechte Linie markiert null. Länder nach ihrem Median ordnen; Anzahl der Paare und Zeitraum angeben.
- **Daten:** Alle nationalen PIP-Paare mit derselben Länderkennung und demselben Berichtsjahr, 1990–2024. Die vorhandenen Daten enthalten vor weiterer Detailprüfung 88 Paare aus 19 Ländern.
- **Prüfung:** Erhebungsbezeichnung, tatsächliches Erhebungsjahr und geografische Abdeckung der Partner kontrollieren. Gleiches Land und Berichtsjahr allein garantieren keine identische Stichprobe.
- **Aussagegrenze:** Beobachtete Unterschiede beschreiben. Die Paare sind weder ein Experiment noch automatisch derselbe Haushalt unter zwei Messmethoden. Wiederholte Jahre eines Landes gelten nicht als unabhängige Länder; der Ländermedian verhindert in der Darstellung, dass viele Erhebungsjahre mit vielen Ländern verwechselt werden.
- **OWID-Bezug:** Der [Poverty Data Explorer](https://ourworldindata.org/explorers/poverty-explorer) erlaubt die getrennte Anzeige von Einkommen und Konsum sowie von Vergleichbarkeitsbrüchen. Unser Differenzdiagramm ist eine eigene Zusammenfassung dieser Gegenüberstellung.

## Optionale Grafik 7: Andere Armutsgrenzen

- **Frage:** Bleiben Richtung und zeitlicher Verlauf der Entwicklung bei höheren Armutsgrenzen ähnlich?
- **Darstellung:** Kleine Zeitverlaufsdiagramme für Welt und Regionen; drei Linien für 3, 4,20 und 8,30 internationale Dollar. Einheitliche Farben für die Grenzen und eine gemeinsame Prozentskala. Falls die Folie überladen wird, zwei Folien verwenden.
- **Daten:** Die bereits vorhandenen Schwellenwerte derselben Welt- und Regionalreihen, 1990–2024.
- **Auswertung:** Niveaus und Veränderungen in Prozentpunkten getrennt betrachten. Drei unterschiedliche Niveaus allein beantworten noch nicht, ob sich die Trends unterscheiden.
- **OWID-Vorlage:** [Share in poverty relative to different poverty lines](https://ourworldindata.org/grapher/share-in-poverty-relative-to-different-poverty-thresholds). Die dortige Linienansicht wurde angesehen. Wir reduzieren die Zahl der Grenzen und richten den Blick auf den Vergleich der Verläufe.

## Gemeinsame Regeln für den späteren Bau

- Die vorhandenen Kursdaten bilden eine feste Datenversion. OWID liefert visuelle Vorlagen und methodische Orientierung; aktuelle Onlinewerte werden nicht stillschweigend in den Kursdatensatz übernommen.
- Als gemeinsame Hauptgrenze gelten 3 internationale Dollar pro Tag in Kaufkraft von 2021. Quoten werden in Prozent, Differenzen in Prozentpunkten angegeben.
- Welt- und Regionalwerte sind modellierte Aggregate. Nationale Beobachtungen stammen aus Erhebungen. Die Bildunterschriften machen diesen Unterschied sichtbar.
- Der Hauptzeitraum für Aggregate endet 2024; 2025/2026 werden in dieser Fassung nicht gezeigt. Auch Aggregate bis 2024 werden dadurch nicht zu direkten jährlichen Erhebungen.
- Farben für Regionen und für Erhebungsmethoden erfüllen unterschiedliche Aufgaben und werden innerhalb ihrer jeweiligen Grafikgruppen konsistent verwendet.
- Beschriftungen, Stichprobenumfang, tatsächliche Vergleichsjahre und Quellen gehören zur Grafik. Ergebnisüberschriften werden erst nach der Auswertung formuliert.

## Ergebnis der Machbarkeitsprüfung

Die vorgeschlagenen Länderregeln sind mit dem vorhandenen Datenauszug grundsätzlich umsetzbar: Vor der Auflösung mehrfach geeigneter Erhebungsarten verbleiben 69 Reihen aus 66 Ländern, mit Vertretung aller sieben Regionen. Die Stichprobe ist deutlich regional ungleich verteilt. Das begründet die transparente Auswahl und die vorsichtige Formulierung der Länderergebnisse.

Diese Prüfung hat nur die Eignung des Konzepts untersucht. Sie ersetzt nicht die spätere Kontrolle der einzelnen Reihen und legt noch keine konkreten Länderbeispiele fest.
