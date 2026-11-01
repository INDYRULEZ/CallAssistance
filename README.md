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
2. **„Macro erstellen"** baut ein charakterspezifisches Makro: `/w <Ziel> <Flüstertext>`.
   Im Kampf ist `SendChatMessage` für Addons gesperrt — ein Makro, das **du** drückst, geht.
   Deshalb der Umweg über das Makro.
3. Drückst du das Makro, erkennt das Addon die eigene ausgehende Nachricht
   (`CHAT_MSG_WHISPER_INFORM`) und blendet Symbol, Restzeit und Balken ein.
4. Die Restzeit zählt ab dem Flüstern mit der eingetragenen **Dauer** herunter.

**Warum die Dauer von Hand?** Die Laufzeit eines laufenden Buffs ist im Kampf für Addons
gesperrt — Blizzard liefert sie nur außerhalb des Kampfes. Ein API-Feld für die Gesamtdauer
eines Zaubers gibt es nicht. Als Zugabe versucht das Addon, die Dauer aus dem Zauber-Tooltip
zu lesen, wenn in der Spalte `Dauer` eine **0** steht; das klappt nicht bei jedem Zauber.
Außerhalb des Kampfes liest es die echte Buff-Laufzeit und merkt sie sich.

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
| `/ca dauer <Zeile> <Sekunden>` | Dauer für den Countdown (0 = aus dem Tooltip versuchen) |
| `/ca icon <Zeile> <ID>` | eigenes Symbol (0 = Symbol des Zaubers) |
| `/ca macro <Zeile>` | Makro für diese Zeile erstellen |
| `/ca anzeige symbol\|zahl\|balken an\|aus` | Anzeige umschalten |
| `/ca test` | Test-Anzeige, 10 Sekunden |
| `/ca debug` | zeigt im Chat, was erkannt wird |
| `/ca an` / `/ca aus` | Addon ein/aus |

Die Anzeige lässt sich mit der Maus verschieben; Größe und Bestandteile stehen in den
Einstellungen.

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
