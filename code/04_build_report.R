html_escape <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub('"', "&quot;", x, fixed = TRUE)
}

html_table <- function(x) {
  header <- paste0("<th>", html_escape(names(x)), "</th>", collapse = "")
  rows <- vapply(seq_len(nrow(x)), function(i) {
    paste0("<tr>", paste0("<td>", html_escape(unlist(x[i, , drop = FALSE])), "</td>", collapse = ""), "</tr>")
  }, character(1))
  paste0("<div class='table-scroll'><table><thead><tr>", header, "</tr></thead><tbody>",
         paste(rows, collapse = ""), "</tbody></table></div>")
}

build_report <- function(a, figures, config) {
  world <- a$world[order(year)]
  cases <- as.data.frame(a$cases[, .(
    Rolle = case_role, Land = country_de, Zeitraum = paste0(start_year, "–", end_year),
    Anfang = paste0(fmt(start_pct), " %"), Ende = paste0(fmt(end_pct), " %"),
    `Änderung (PP/Jahr)` = fmt(annual_change_pp, 2),
    `Region (PP/Jahr)` = fmt(regional_annual_change_pp, 2),
    `Engeres Fenster` = narrow_status)])
  explanations <- figures$explanation
  sections <- vapply(seq_len(nrow(figures)), function(i) {
    png <- figures$png[i]
    raw <- readBin(png, what = "raw", n = file.info(png)$size)
    img <- paste0("data:image/png;base64,", jsonlite::base64_enc(raw))
    paste0("<section id='grafik-", i, "'><p class='section-number'>Grafik ", i, "</p><h2 class='sr-only'>",
           html_escape(figures$takeaway[i]), "</h2>",
           "<figure><img src='", img, "' alt='", html_escape(figures$takeaway[i]), "'></figure>",
           "<p class='interpretation'>", html_escape(explanations[i]), "</p></section>")
  }, character(1))
  excluded <- a$candidates[eligible == FALSE, .(Reihen = .N), by = .(Grund = reason)]
  excluded <- as.data.frame(excluded[order(-Reihen)])
  coverage <- merge(a$countries[, .(Eingeschlossen = .N), by = region_code],
                     a$catalog[, .(Im_Datensatz = .N), by = region_code], by = "region_code", all = TRUE)
  coverage <- merge(a$regions[, .(region_code, Region = gsub("\n", " ", region_de))], coverage, by = "region_code", all.x = TRUE)
  coverage[is.na(Eingeschlossen), Eingeschlossen := 0L]
  coverage <- as.data.frame(coverage[, .(Region, Eingeschlossen, Im_Datensatz)])
  findings <- figures$takeaway
  toc <- paste0("<li><a href='#grafik-", seq_len(nrow(figures)), "'>", html_escape(figures$takeaway), "</a></li>", collapse = "")
  body <- paste0(
    "<header><p class='eyebrow'>Grundlegendes Praxisprojekt</p><h1>Leben unter 3 Dollar am Tag</h1>",
    "<p class='lead'>Extreme Armut seit 1990. Weltweite Entwicklung, regionale Unterschiede und die Vergleichbarkeit nationaler Erhebungen.</p></header>",
    "<section><h2>Gegenstand und Daten</h2><p>3 internationale Dollar pro Person und Tag in Kaufkraft von 2021 berücksichtigen Preisunterschiede zwischen Ländern und über die Zeit. Sie entsprechen keinem aktuellen Dollar-Wechselkurs.</p>",
    "<p>Die Analyse verwendet ausschließlich den vorhandenen Kursdatensatz. Nationale Werte stammen aus Haushaltsbefragungen zu Einkommen oder Konsum. Welt- und Regionalwerte sind modelliert. Der Hauptzeitraum endet ", config$end_year, ".</p>",
    "<p>Ein Rückgang von 40 % auf 20 % entspricht 20 Prozentpunkten. Quoten und Veränderungen verwenden deshalb unterschiedliche Einheiten.</p><ol>", toc, "</ol></section>",
    paste(sections, collapse = "\n"),
    "<section><h2>Auswahl und Grenzen der Länderanalyse</h2><p>Zieljahre ", config$country_start, " und ", config$country_end,
    ", jeweils ±", config$tolerance, " Jahre. Bei gleichem Abstand entscheidet das frühere Erhebungsjahr. Mindestens ", config$min_span,
    " Jahre Zeitspanne und ", config$min_surveys, " Beobachtungen sind nötig. Erhebungsart und Vergleichbarkeitskennung bleiben innerhalb des Intervalls gleich.</p>",
    "<p>Bei mehreren geeigneten Methoden entscheidet zuerst die OWID-Auswahl an den Endpunkten, dann die längere Zeitspanne, die Zahl der Beobachtungen und schließlich der Methodenname. Jede Entscheidung steht in der exportierten Tabelle.</p>",
    "<h3>Die drei ausgewählten Fälle</h3>", html_table(cases),
    html_table(coverage), "<h3>Ausgeschlossene Länder-Methoden-Reihen</h3>", html_table(excluded),
    "<p>Die Ausschlusszahlen zählen Reihen je Land und Methode. Sie sind deshalb keine Anzahl verschiedener Länder. Engere Zeitfenster von ±1 und exakt gleichen Jahren werden zusätzlich exportiert. Ein fehlendes engeres Vergleichspaar ist kein Beleg für einen Richtungswechsel.</p>",
    "<p>Die Fallauswahl ist deskriptiv. Ausgangsniveau und tatsächliche Zeitspanne bleiben bei Vergleichen wichtig. Ein gegenläufiger Verlauf belegt keine Ursache.</p></section>",
    "<section><h2>Ergebnisse und Einordnung</h2><ul>", paste0("<li>", findings, "</li>", collapse = ""), "</ul></section>",
    "<section><h2>Quellen und visuelle Vorlagen</h2><p>Weltbank Poverty and Inequality Platform (2026), aufbereitet durch Our World in Data. Die Eingabedateien und ihre Prüfsummen stehen in output/results/input_checksums.csv.</p>",
    "<ul><li><a href='https://ourworldindata.org/grapher/share-of-population-in-extreme-poverty'>Armutsquoten für Welt, Regionen und Länder</a></li>",
    "<li><a href='https://ourworldindata.org/explorers/poverty-explorer'>Poverty Data Explorer mit Erhebungsarten und Vergleichbarkeitsbrüchen</a></li>",
    "<li><a href='https://ourworldindata.org/grapher/share-in-poverty-relative-to-different-poverty-thresholds'>Vergleich verschiedener Armutsgrenzen</a></li></ul></section>",
    "<footer>Analyse des Kursdatensatzes. Grafiken und Zusammenfassungen werden mit run_all.R reproduziert.</footer>")
  css <- "body{margin:0;background:#f4f6f7;color:#283545;font:17px/1.65 system-ui,Arial,sans-serif}main{max-width:1180px;margin:auto;background:white;padding:60px 52px}header{border-bottom:2px solid #315f87;padding-bottom:32px}h1{font:700 48px/1.15 Georgia,serif;margin:10px 0 20px}h2{font-size:27px;line-height:1.3}h3{font-size:20px}.lead{font-size:21px;max-width:900px}.eyebrow,.section-number{font-size:13px;letter-spacing:.1em;text-transform:uppercase;color:#586674}section{padding:28px 0;border-bottom:1px solid #dfe4e8}a{color:#315f87}figure{margin:20px -20px}img{display:block;width:100%;height:auto}table{border-collapse:collapse;width:100%;font-size:14px}td,th{padding:9px 10px;border-bottom:1px solid #dfe4e8;text-align:left;vertical-align:top}th{background:#f1f4f6}.table-scroll{overflow:auto} .sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}.interpretation{max-width:1000px}footer{padding-top:30px;color:#586674;font-size:13px}@media(max-width:700px){main{padding:28px 18px}h1{font-size:35px}h2{font-size:23px}figure{margin:20px -10px}}@media print{body{background:white}main{max-width:none;padding:0}section{break-inside:avoid}a{color:inherit}img{max-height:85vh;object-fit:contain}}"
  html <- paste0("<!doctype html><html lang='de'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>",
                 "<title>Extreme Armut seit 1990</title><style>", css, "</style></head><body><main>", body, "</main></body></html>")
  writeLines(enc2utf8(html), "output/bericht.html", useBytes = TRUE)
  writeLines(enc2utf8(c("# Ergebnisse", "", findings, "", "## Fallauswahl", "",
                         capture.output(print(cases, row.names = FALSE)))), "output/ergebnisse.md", useBytes = TRUE)
  invisible("output/bericht.html")
}
