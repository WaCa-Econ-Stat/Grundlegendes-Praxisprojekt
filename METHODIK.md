# Auswahl und Interpretation

## Daten und Einheiten

Die Eingaben stammen vollständig aus `data/`. Die Pipeline lädt keine neuen Armutsdaten. Sie zeichnet ihre MD5-Prüfsummen auf. Nationale Quoten stehen in PIP als Anteile zwischen 0 und 1 und werden mit 100 in Prozent umgerechnet. OWID-Quoten liegen bereits in Prozent vor. Eine Veränderung der Quote heißt Prozentpunktveränderung.

Welt und Regionen verwenden die veröffentlichten, modellierten OWID/Weltbank-Aggregate. Nationale Erhebungen werden nicht ungewichtet zu Regionalwerten gemittelt. Der dargestellte Zeitraum 1990–2024 macht die Aggregate nicht zu direkten jährlichen Erhebungen. Prognosejahre 2025 und 2026 bleiben außerhalb des Hauptzeitraums.

## OWID-Auswahl

PIP kann für ein Land und Jahr sowohl Einkommen als auch Konsum enthalten. Die OWID-Länderreihe wählt jeweils einen Wert. Die Zuordnung verwendet Länderkennung, Jahr und die Übereinstimmung der 3-Dollar-Quote. Mehrdeutige oder fehlende Zuordnungen brechen den Lauf ab. Die Datenaufbereitung mittelt die beiden Methoden nicht.

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

Die Paarbildung verwendet Länderkennung und Berichtsjahr. Es werden nur nationale Erhebungen mit 3-Dollar-Grenze und Jahren 1990–2024 verglichen. Die Differenz lautet `100 * (headcount_income - headcount_consumption)`.

Positive Werte bedeuten eine höhere einkommensbasierte Quote, negative eine höhere konsumbasierte Quote. Das Diagramm zeigt einen Balken für den Median der gepaarten Jahresdifferenzen je Land. Es ist der Median der Differenzen und nicht die Differenz zweier getrennt berechneter Mediane. n nennt die Anzahl verfügbarer Vergleichsjahre. Die Einzelpaare bleiben in `method_pairs.csv` erhalten. Das Diagramm enthält keine Konfidenzintervalle und behauptet keine statistische Unabhängigkeit wiederholter Jahre.

Die Tabelle dokumentiert Übereinstimmungen von Erhebungsbezeichnung, tatsächlichem Erhebungsjahr, geografischer Abdeckung und Vergleichbarkeitskennung. Kennungen verschiedener Methoden begründen für sich allein keine Stichprobengleichheit. Auch gleiche Bezeichnungen garantieren keine identische Stichprobe. Die beobachteten Unterschiede sind deshalb kein isolierter kausaler Methodeneffekt.

## Alternative Grenzen

Die zusätzlichen Reihen verwenden 3, 4,20 und 8,30 internationale Dollar in Kaufkraft von 2021. Alle stammen aus derselben Datenversion. Die Hauptgrafik konzentriert sich auf die Weltreihe und prüft die Richtung der Änderung über den gesamten Zeitraum. Regionale Eingabereihen bleiben in den aufbereiteten Daten erhalten. Höhere Grenzen verändern zwangsläufig die Niveaus. Für Aussagen über die Entwicklung sind zusätzlich Veränderungen, Richtungen und Zeitabschnitte zu vergleichen.
