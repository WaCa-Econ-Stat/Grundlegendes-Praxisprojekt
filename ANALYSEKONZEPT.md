# Eine zentrale Aussage je Grafik

Die Darstellung folgt der Aussage, die das Publikum mitnehmen soll. Die Titel nennen einen belegten Befund. Achsen, Hervorhebungen und direkte Beschriftungen tragen zu diesem einen Befund bei. Die Datenaufbereitung und die Auswahlregeln stehen in METHODIK.md.

| Grafik | Zentrale Aussage | Darstellung |
| --- | --- | --- |
| 1 | Der weltweite Anteil in extremer Armut sank deutlich. | Eine Weltlinie mit zwei hervorgehobenen Endwerten. |
| 2 | Subsahara-Afrika hat am Ende des Zeitraums die höchste regionale Armutsquote. | Ausgangs- und Endwerte auf einer gemeinsamen Skala, mit farblicher Hervorhebung von Subsahara-Afrika. |
| 3 | Die ausgewählten Länder entwickelten sich gegensätzlich. | Drei direkt beschriftete Balken für die absolute Veränderung in Prozentpunkten. |
| 4 | Ein Land kann sich entgegen dem Regionaltrend entwickeln. | Simbabwe und Subsahara-Afrika im selben Vergleichszeitraum. |
| 5 | Die verfügbare Erhebungsart unterscheidet sich systematisch zwischen den beiden gezeigten Regionen. | Zwei Prozentbalken mit direkter Beschriftung der dominierenden Erhebungsarten. |
| 6 | In den meisten Vergleichsländern zeigt der Median höhere Einkommensquoten. | Ein beschrifteter Differenzbalken je Land, mit der Zahl verfügbarer Vergleichsjahre. |
| 7, optional | Der weltweite Rückgang bleibt bei höheren Armutsgrenzen sichtbar. | Drei direkt beschriftete Weltlinien. |
| 8 | Bei höherem BIP pro Kopf ist extreme Armut meist seltener. | OWID-inspirierte Länderpunkte: Farbe nach Weltbankregion, Fläche nach Bevölkerung, BIP-Achse logarithmisch. |
| 9 | Höhere Ungleichheit geht in beiden Erhebungsarten mit mehr Armut einher. | Zwei Streudiagramme mit gleichen Achsen und regionalen Länderfarben. |
| 10 | Mehr extreme Armut geht meist mit höherer Kindersterblichkeit einher. | An OWIDs konkretem Armut-Sterblichkeits-Vergleich orientierte Bevölkerungskreise mit regionalen Farben. |
| 11 | Die Kindersterblichkeit sank in beiden Armutsgruppen. | Direkt beschriftete Medianverläufe zweier fester Gruppen derselben 80 Länder. Gruppenzuordnung anhand der Armutsquote um 2000. |
| 12 | In Simbabwe sank Kindersterblichkeit trotz steigender Armut. | Zwei Verläufe untereinander für dieselben Erhebungsjahre; getrennte, bei null beginnende y-Skalen. |
| 13 | Eine höhere Armutsgrenze zeigt in der Gruppe mit höherem BIP keinen automatisch stärkeren Gesundheitszusammenhang. | Dieselben 26 Länder unter 3- und 40-Dollar-Grenze; regionale Farben und direkte Ländernamen. |

Bei jedem Lauf entstehen Titelvorschläge in `output/grafiktitel.md` und im Abbildungsmanifest unter `takeaway`. Die Interpretation gilt für den angegebenen Zeitraum und die jeweilige Datenauswahl.

Die vollständigen Einzeljahre, Länder, Regionen und Auswahlentscheidungen bleiben in den exportierten Tabellen verfügbar. Der Bericht zeigt die Grafiken in dieser Reihenfolge und erläutert die methodischen Grenzen anschließend.

Die Erweiterung gibt den letzten beiden Forschungsfragen einen eigenen Platz im roten Faden: erst wirtschaftliche Leistung und Verteilung, dann der Bezug zu Überlebenschancen von Kindern. Sie beschreibt Lebensbedingungen anhand der vorhandenen Messgrößen. Ein Länderzusammenhang ist kein Nachweis einer individuellen oder kausalen Wirkung. Die schwachen Befunde in der Gruppe mit höherem BIP und der Gegenlauf in Simbabwe gehören ausdrücklich zur Geschichte.

## Konkret betrachtete OWID-Vorlagen

- [Armut und Kindersterblichkeit](https://ourworldindata.org/grapher/extreme-poverty-vs-child-mortality): regionale Farben, Bevölkerungskreise und direkte Ländernamen. Wir verwenden sieben Weltbankregionen und unsere Erhebungsjahre statt der OWID-Kontinente und der aktuellen Onlinewerte.
- [Kindersterblichkeit nach Einkommensgruppe](https://ourworldindata.org/grapher/child-mortality-by-income-level-of-country): ruhige Verlaufslinien mit Beschriftungen direkt am Ende. Wir bilden zwei feste eigene Armutsgruppen und zeigen ungewichtete Ländermediane an drei Zeitfenstern.
- [Ungleichheit und BIP](https://ourworldindata.org/grapher/gini-coefficient-vs-gdp-per-capita-pip): wirtschaftliche Indikatoren als regionaler Ländervergleich. Die beiden wirtschaftlichen Grafiken übertragen die Gestaltung auf unsere Variablen, nicht die Aussage oder die Daten der Vorlage.

Die Vorlagen wurden im Browser angesehen. Die neue Umsetzung verzichtet auf Markenlogos und dokumentiert unter jeder Abbildung die konkrete Inspiration und die Abweichungen.
