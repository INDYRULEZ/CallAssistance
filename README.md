# Call Assistance

Das Gegenstück zu [Call Spell](https://github.com/INDYRULEZ/CallSpell): Call Spell meldet sich,
wenn dich jemand um einen Zauber bittet. **Call Assistance** ist die Seite, die bittet — eine
Tabelle mit Anfragen, ein Klick auf ein Makro, und danach läuft sichtbar ein Countdown für den
Buff, den man angefordert hat.

Gedacht für Mitspieler, die „Rescue", „Spatial Paradox", „Power Infusion" & Co. nicht im
Kampfgetümmel tippen wollen — und wissen möchten, wie lange der Buff noch läuft.

## So funktioniert es

1. Du pflegst eine Tabelle: **Name · SpellID · Symbol · Flüstertext · Ziel · Dauer**.
   `Ziel` ist die Person, die den Zauber wirkt (z. B. der Freund, der Rescue castet).
2. Für jede Zeile lässt du einmal ein Makro anlegen („Macro erstellen", `/ca macros` oder automatisch
   beim `/ca import`) und ziehst es auf die Aktionsleiste. Das Makro flüstert
   `/w <Ziel> <Flüstertext>` **und** ruft `/ca start <SpellID>` auf — der zweite Aufruf startet den
   Countdown. Nötig, weil im Kampf der eigene Chattext für Addons gesperrt ist („secret string");
   der Befehl aus dem Makro funktioniert dagegen auch im Kampf.
3. Drückst du das Makro, erkennt das Addon die eigene ausgehende Nachricht
   (`CHAT_MSG_WHISPER_INFORM`) und blendet Symbol, Restzeit und Balken ein.
4. Die Restzeit zählt ab dem Flüstern mit der eingetragenen **Dauer** herunter.

**Die Dauer trägst du selbst ein.** Blizzard liefert Addons weder im Kampf die Laufzeit eines
laufenden Buffs noch überhaupt ein Feld für die Gesamtdauer eines Zaubers. Außerhalb des Kampfes
liest das Addon die echte Buff-Laufzeit, sobald sie sichtbar ist, und korrigiert sich damit.

## Installation

**Mit WowUp** (empfohlen, dann gibt es Updates):

1. In WowUp: *Addons* → *Install from URL*
2. `https://github.com/INDYRULEZ/CallAssistance` eintragen
3. Installieren — WowUp nimmt das neueste Release

**Von Hand:**

1. [Neuestes Release](https://github.com/INDYRULEZ/CallAssistance/releases/latest) herunterladen
2. ZIP entpacken, Ordner `CallAssistance` nach
   `World of Warcraft/_retail_/Interface/AddOns/` kopieren
3. Spiel starten (bei neuen Addons reicht kein `/reload`)

## Bedienung

`/ca` zeigt die Befehle, `/ca config` öffnet die Einstellungen (auch unter
*Optionen → Addons → Call Assistance*).

| Befehl | Wirkung |
|---|---|
| `/ca neu <SpellID> [Name]` | neue Zeile in der Tabelle |
| `/ca weg <Zeile>` | Zeile entfernen |
| `/ca phrase <Zeile> <Text>` | Flüstertext setzen |
| `/ca ziel <Zeile> <Name>` | wer den Zauber wirkt |
| `/ca dauer <Zeile> <Sekunden>` | Dauer für den Countdown |
| `/ca icon <Zeile> <ID>` | eigenes Symbol (0 = Symbol des Zaubers) |
| `/ca macro <Zeile>` | Makro für diese Zeile erstellen |
| `/ca export` | Code zum Weitergeben an einen Mitspieler |
| `/ca import <Code>` | Tabelle aus so einem Code übernehmen |
| `/ca macros` | für alle Zeilen Makros anlegen |
| `/ca position` | Anzeige mit der Maus verschieben |
| `/ca anzeige symbol\|zahl\|balken an\|aus` | Anzeige umschalten |
| `/ca test` | Test-Anzeige, 10 Sekunden |
| `/ca debug` | zeigt im Chat, was erkannt wird |
| `/ca an` / `/ca aus` | Addon ein/aus |

Die Anzeige lässt sich mit der Maus verschieben. Weil sie ohne laufenden Countdown unsichtbar
ist, gibt es dafür `/ca position`: dann erscheint ein blauer Platzhalter, den du an die richtige
stelle ziehst — nochmal `/ca position` oder der Knopf **„Fertig"** in der Bildschirmmitte beendet
den Modus. Die Position wird gespeichert. Dasselbe geht über den Knopf **„Anzeige verschieben"**
in den Einstellungen (der schließt die Optionen gleich mit). Größe und Bestandteile der Anzeige
stehen in den Einstellungen.

**Dauer 0** heißt: für diese Zeile wird kein Symbol angezeigt (z. B. bei Zaubern ohne Buff).

## Tabelle weitergeben

Damit der Mitspieler nichts eintippen muss: `/ca export` gibt einen kurzen Code aus

```
370665|Rescue me|CharName|3;407497|Paradox me|CharName|12
```

Der andere fügt ihn mit `/ca import <Code>` ein. Format ist
`SpellID|Flüstertext|Ziel|Dauer`, mehrere Zeilen durch `;` getrennt (Dauer darf fehlen).
Im Chat funktionieren auch **Komma** oder `#` als Trenner — die Pipe wird beim Einfügen
manchmal verschluckt.
Der **Name** der Anfrage wird nicht mitgeschickt — er kommt aus dem Zauber selbst.
Vorhandene Zauber werden aktualisiert statt doppelt angelegt.

Danach ist nichts weiter zu tun: Tabelle gefüllt und die Makros sind schon angelegt (die
Makro-Namen stehen im Chat). Nur noch auf die Aktionsleiste ziehen. Wurde im Kampf importiert,
legt Blizzard keine Makros an — dann danach `/ca macros`.

## Grenzen

- Der Countdown läuft ab dem Moment **deines** Flüsterns. Wirkt der andere den Zauber später,
  läuft die Anzeige vor der echten Buff-Zeit. Außerhalb des Kampfes korrigiert das Addon sich
  auf die echte Laufzeit, sobald der Buff lesbar ist.
- Läuft der Buff ab, passiert nichts weiter — es gibt bewusst keine automatische Wiederholung.
- Die Tabelle ist frei konfigurierbar; mitgeliefert ist nur eine Beispielzeile (Rescue).

## Kontakt

Fragen, Fehler, Ideen: [Issue im Repo](https://github.com/INDYRULEZ/CallAssistance/issues) oder
eine Mail an jonas@jagerke.de. Größere Ideen bespreche ich lieber in einem Discord-Call.

Lizenz: MIT — siehe `LICENSE`.
