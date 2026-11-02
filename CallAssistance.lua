-- CallAssistance — Gegenstueck zu CallSpell
-- Laeuft beim Anfragenden: Tabelle wie CallSpell, aber ohne Stimme.
-- "Macro erstellen" baut ein Makro, das den Fluestertext an die jeweilige Person schickt.
-- Wird das Makro gedrueckt, kommt der eigene ausgehende Chat zurueck
-- (CHAT_MSG_WHISPER_INFORM) — dann zeigt das Addon Symbol + Restlaufzeit.
--
-- Restlaufzeit: zuerst aus der Aura-API (C_UnitAuras), sonst selbst heruntergezaehlt
-- ab dem Moment des Fluesterns mit der eingetragenen Gesamtdauer.

local ADDON = "CallAssistance"
local VERSION = "2.3"

-- ---------------------------------------------------------------- Sprachen

local TEXTE = {
    de = {
        zauber = "Anfragen",
        anzeige = "Anzeige",
        kanaele = "Eigene Nachrichten, die zählen",
        sprache = "Sprache",
        sprache_auto = "automatisch", sprache_de = "Deutsch", sprache_en = "Englisch",
        col_name = "Name", col_spellid = "SpellID", col_symbol = "Symbol",
        col_phrase = "Flüstertext", col_target = "Ziel", col_dauer = "Dauer",
        cb_symbol = "Symbol zeigen", cb_zahl = "Zahl zeigen", cb_balken = "Balken zeigen",
        cb_whisper = "Flüstern", cb_party = "Gruppe", cb_raid = "Raid",
        cb_debug = "Debug-Meldungen im Chat",
        slider_size = "Symbolgröße",
        btn_macro = "Macro erstellen", btn_new = "+ Anfrage hinzufügen",
        hint_spells = "Symbol leer = Zauber-Symbol · Ziel = wer den Zauber wirkt · "
            .. "Dauer = Sekunden, die der Buff hält (0 = gar nicht anzeigen). × entfernt die Zeile.",
        hilfe_titel = "— Befehle:",
        geladen = "CallAssistance %s geladen — /ca für Befehle",
        makro_angelegt = "Makro angelegt (charakterspezifisch): %s",
        kein_platz = "kein freier Makro-Platz",
        ziel_fehlt = "Ziel fehlt in der Zeile",
        phrase_fehlt = "Flüstertext fehlt in der Zeile",
        test = "Test-Anzeige läuft (10 s)",
        an = "ist AN", aus = "ist AUS",
        an_kurz = "an", aus_kurz = "aus",
        unbekannt = "unbekannter Befehl: %s",
        zeile_falsch = "Zeilennummer fehlt oder falsch: /ca %s <Zeile> <Wert>",
        weg_fehlt = "Zeile gibt es nicht",
        neu_fehlt = "SpellID fehlt: /ca neu <SpellID> [Name]",
        neu_gemacht = "hinzugefügt: %s (ID %d) — Flüstertext jetzt mit /ca phrase %d <Text> setzen",
        gesetzt = "%s: %s = %s",
        treffer = "Anfrage erkannt: %s",
        import_ok = "%d Anfrage(n) übernommen — Namen kommen aus dem Zauber",
        import_leer = "Code fehlt: /ca import <SpellID>|<Flüstertext>|<Ziel>|<Dauer>;…",
        export_kopf = "Code zum Weitergeben:",
        kein_kampf = "im Kampf nicht möglich — bitte außerhalb",
        position_hinweis = "Anzeige hierher ziehen · /ca position beendet",
        position_an = "Platzieren: Anzeige mit der Maus verschieben, dann /ca position zum Beenden",
        position_aus = "Platzieren beendet",
        btn_move = "Anzeige verschieben",
        btn_done = "Fertig",
        buff_aus_api = "Restzeit aus Buff-API: %s",
        buff_nicht_lesbar = "Buff nicht lesbar — zähle selbst (%.0f s)",
        hilfe = [[
  /ca config                 Einstellungen (auch: Optionen -> Addons -> Call Assistance)
  /ca test                   Test-Anzeige, 10 s
  /ca an | /ca aus           Addon ein/aus
  /ca neu <SpellID> [Name]   neue Zeile in der Anfrage-Tabelle
  /ca weg <Zeile>            Zeile entfernen
  /ca phrase <Zeile> <Text>  Flüstertext setzen
  /ca icon <Zeile> <ID>      eigenes Symbol (0 = Zauber-Symbol)
  /ca ziel <Zeile> <Name>    Person, die den Zauber wirkt
  /ca dauer <Zeile> <Sek>    Gesamtdauer für den Selbst-Countdown
  /ca macro <Zeile>          Makro für die Zeile erstellen
  /ca export                 Code zum Weitergeben an einen Mitspieler
  /ca import <Code>          Tabelle aus so einem Code übernehmen
  /ca macros                 für alle Zeilen Makros anlegen
  /ca position               Anzeige mit der Maus verschieben
  /ca anzeige symbol|zahl|balken an|aus
  /ca debug                  zeigt, was erkannt wird]],
    },
    en = {
        zauber = "Requests",
        anzeige = "Display",
        kanaele = "Own messages that count",
        sprache = "Language",
        sprache_auto = "automatic", sprache_de = "German", sprache_en = "English",
        col_name = "Name", col_spellid = "SpellID", col_symbol = "Icon",
        col_phrase = "Whisper text", col_target = "Target", col_dauer = "Duration",
        cb_symbol = "Show icon", cb_zahl = "Show number", cb_balken = "Show bar",
        cb_whisper = "Whisper", cb_party = "Party", cb_raid = "Raid",
        cb_debug = "Debug messages in chat",
        slider_size = "Icon size",
        btn_macro = "Create macro", btn_new = "+ Add request",
        hint_spells = "Icon empty = spell icon · Target = who casts the spell · "
            .. "Duration = seconds the buff lasts (0 = do not show at all). × removes the row.",
        hilfe_titel = "— commands:",
        geladen = "CallAssistance %s loaded — /ca for commands",
        makro_angelegt = "macro created (character specific): %s",
        kein_platz = "no free macro slot",
        ziel_fehlt = "target missing in the row",
        phrase_fehlt = "whisper text missing in the row",
        test = "Test display running (10 s)",
        an = "is ON", aus = "is OFF",
        an_kurz = "on", aus_kurz = "off",
        unbekannt = "unknown command: %s",
        zeile_falsch = "row number missing or wrong: /ca %s <row> <value>",
        weg_fehlt = "no such row",
        neu_fehlt = "SpellID missing: /ca new <SpellID> [Name]",
        neu_gemacht = "added: %s (ID %d) — set the whisper text with /ca phrase %d <text>",
        gesetzt = "%s: %s = %s",
        treffer = "request detected: %s",
        import_ok = "%d request(s) imported — names come from the spell",
        import_leer = "code missing: /ca import <SpellID>|<whisper text>|<target>|<duration>;…",
        export_kopf = "code to share:",
        kein_kampf = "not possible in combat — please do it outside",
        position_hinweis = "drag the display here · /ca position to finish",
        position_an = "placing: move the display with the mouse, then /ca position to finish",
        position_aus = "placing finished",
        btn_move = "Move display",
        btn_done = "Done",
        buff_aus_api = "remaining from buff API: %s",
        buff_nicht_lesbar = "buff not readable — counting myself (%.0f s)",
        hilfe = [[
  /ca config                 settings (also: Options -> AddOns -> Call Assistance)
  /ca test                   test display, 10 s
  /ca an | /ca aus           addon on/off
  /ca new <SpellID> [Name]   add a row to the request table
  /ca weg <row>              remove a row
  /ca phrase <row> <text>    set the whisper text
  /ca icon <row> <ID>        custom icon (0 = spell icon)
  /ca ziel <row> <name>      who casts the spell
  /ca dauer <row> <sec>      total duration for the self-countdown
  /ca macro <row>            create the macro for the row
  /ca export                 code to share with another player
  /ca import <code>          take over a table from such a code
  /ca macros                 create macros for all rows
  /ca position               move the display with the mouse
  /ca anzeige symbol|zahl|balken an|aus
  /ca debug                  show what is detected]],
    },
}

local function spracheWahl()
    local quelle = CallAssistanceDB or DB
    local wahl = (quelle and quelle.sprache) or "auto"
    if wahl == "de" or wahl == "en" then return wahl end
    local spiel = GetLocale and GetLocale() or "enUS"
    if string.sub(spiel, 1, 2) == "de" then return "de" end
    return "en"
end

local function T(schluessel, ...)
    local texte = TEXTE[spracheWahl()] or TEXTE.en
    local wert = texte[schluessel] or TEXTE.en[schluessel] or schluessel
    if select("#", ...) > 0 then
        return string.format(wert, ...)
    end
    return wert
end

-- ---------------------------------------------------------------- Daten

local VORGABEN = {
    sprache = "auto",
    aktiv = true,
    fluestern = true,
    gruppe = true,
    raid = true,
    zeigeSymbol = true,
    zeigeZahl = true,
    zeigeBalken = true,
    groesse = 40,
    debug = false,
    position = nil,     -- {point, x, y}
}

-- Startzeilen der Tabelle (bewusst neutral, jeder pflegt seine Zauber selbst)
local START = {
    { name = "Rescue", spellID = 370665, icon = 0, phrase = "rescue me", ziel = "", dauer = 10 },
}

local DB

-- Einstellungsseite (Definition weiter unten, hier nur vorwaerts deklariert)
local optionenPanel, inhaltFrame, aufbauZaehler = nil, nil, 0
local aufbauen, baueOptionen, oeffneOptionen

local function kopiere(t)
    local neu = {}
    for k, v in pairs(t) do
        neu[k] = type(v) == "table" and kopiere(v) or v
    end
    return neu
end

local function dbInit()
    CallAssistanceDB = CallAssistanceDB or {}
    DB = CallAssistanceDB
    for k, v in pairs(VORGABEN) do
        if DB[k] == nil then
            DB[k] = type(v) == "table" and kopiere(v) or v
        end
    end
    if type(DB.posten) ~= "table" or #DB.posten == 0 then
        DB.posten = {}
        for _, z in ipairs(START) do
            table.insert(DB.posten, { name = z.name, spellID = z.spellID, icon = z.icon,
                                      phrase = z.phrase, ziel = z.ziel, dauer = z.dauer })
        end
    end
    if type(DB.naechsteID) ~= "number" then DB.naechsteID = 1 end
    for _, e in ipairs(DB.posten) do
        if e.name == nil then e.name = "" end
        if e.spellID == nil then e.spellID = 0 end
        if e.icon == nil then e.icon = 0 end
        if e.phrase == nil then e.phrase = "" end
        if e.ziel == nil then e.ziel = "" end
        if type(e.dauer) ~= "number" then e.dauer = 10 end
        if e.id == nil then
            e.id = DB.naechsteID
            DB.naechsteID = DB.naechsteID + 1
        end
    end
end

local function istDa()
    if not DB then dbInit() end
end

local function normalisiere(text)
    if type(text) ~= "string" then return "" end
    text = string.lower(text)
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function kurzName(name)
    if type(name) ~= "string" then return "" end
    local ohneRealm = string.match(name, "^([^%-]+)")
    return string.lower(ohneRealm or name)
end

local function passt(text, posten)
    local t = normalisiere(text)
    local p = normalisiere(posten.phrase)
    if #p == 0 then return false end
    return string.find(t, p, 1, true) ~= nil
end

local function istDebug()
    return DB and DB.debug
end

local function melde(text, farbe)
    if istDebug() then
        print((farbe or "|cff8080ff") .. "CallAssistance|r " .. text)
    end
end

-- ---------------------------------------------------------------- Anzeige
-- Ein beweglicher Rahmen, darin je Anfrage eine Zeile: Symbol, Zahl darauf, Balken darunter.

local ANZEIGE_BREITE = 220

local anzeige = CreateFrame("Frame", "CallAssistanceAnzeige", UIParent)
anzeige:SetSize(ANZEIGE_BREITE, 60)
anzeige:SetFrameStrata("HIGH")
anzeige:SetClampedToScreen(true)
anzeige:SetMovable(true)
anzeige:EnableMouse(true)
anzeige:RegisterForDrag("LeftButton")
anzeige:SetScript("OnDragStart", anzeige.StartMoving)
anzeige:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    if DB then DB.position = { point = point, x = x, y = y } end
end)
anzeige:Hide()

-- laufende Anfragen (Liste, damit die Reihenfolge stabil bleibt)
local laufend = {}

local function zeilenBauen()
    local groesse = DB.groesse or 40
    local abstand = 6
    local hoehe = groesse + 12

    for i, eintrag in ipairs(laufend) do
        local zeile = eintrag.zeile
        if not zeile then
            zeile = CreateFrame("Frame", nil, anzeige)
            zeile.symbol = zeile:CreateTexture(nil, "ARTWORK")
            zeile.symbol:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            zeile.zahl = zeile:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            zeile.zahl:SetPoint("CENTER", 0, 0)
            zeile.zahl:SetJustifyH("CENTER")
            if zeile.zahl.SetShadowColor then
                zeile.zahl:SetShadowColor(0, 0, 0, 1)
                zeile.zahl:SetShadowOffset(1, -1)
            end
            zeile.balkenHinter = zeile:CreateTexture(nil, "BACKGROUND")
            zeile.balkenHinter:SetColorTexture(0, 0, 0, 0.6)
            zeile.balken = zeile:CreateTexture(nil, "ARTWORK")
            zeile.balken:SetColorTexture(0.2, 1, 0.3, 0.95)
            zeile.namensText = zeile:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            zeile.namensText:SetWidth(60)
            zeile.namensText:SetJustifyH("LEFT")
            eintrag.zeile = zeile
        end

        local z = eintrag.zeile
        z:SetSize(groesse + 70, hoehe)
        z:SetPoint("TOPLEFT", anzeige, "TOPLEFT", 0, -(i - 1) * (hoehe + abstand))

        z.symbol:SetSize(groesse, groesse)
        z.symbol:SetPoint("TOPLEFT", z, "TOPLEFT", 0, 0)
        z.symbol:SetShown(DB.zeigeSymbol and true or false)

        z.zahl:SetPoint("CENTER", z, "TOPLEFT", groesse / 2, -groesse / 2)
        z.zahl:SetShown(DB.zeigeZahl and true or false)

        z.balkenHinter:ClearAllPoints()
        z.balkenHinter:SetPoint("TOPLEFT", z, "TOPLEFT", 0, -groesse - 2)
        z.balkenHinter:SetSize(groesse, 4)
        z.balken:ClearAllPoints()
        z.balken:SetPoint("TOPLEFT", z, "TOPLEFT", 0, -groesse - 2)
        z.balken:SetHeight(4)
        z.balkenHinter:SetShown(DB.zeigeBalken and true or false)
        z.balken:SetShown(DB.zeigeBalken and true or false)

        -- Name rechts neben dem Symbol
        z.namensText:SetPoint("LEFT", z.symbol, "RIGHT", 6, 0)
        z.namensText:SetText(eintrag.posten.name or "")
        z:Show()
    end

    local anzahl = #laufend
    anzeige:SetHeight(math.max(1, anzahl * (hoehe + abstand)))
    anzeige:SetWidth(groesse + 70)
    if anzahl > 0 then anzeige:Show() else anzeige:Hide() end
end

local function setzePosition()
    if not DB then return end
    local p = DB.position
    anzeige:ClearAllPoints()
    if p and p.point then
        anzeige:SetPoint(p.point, UIParent, p.point, p.x or 0, p.y or 0)
    else
        anzeige:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    end
end

-- Positionier-Modus: Anzeige sichtbar machen, damit sie sich mit der Maus verschieben lässt.
local platzFlaeche, platzHinweis, platzKnopf
local platzieren = false

local function setzePlatzieren(an)
    if not DB then return end
    platzieren = an and true or false
    if not platzFlaeche then
        platzFlaeche = anzeige:CreateTexture(nil, "BACKGROUND")
        platzFlaeche:SetAllPoints()
        platzFlaeche:SetColorTexture(0.2, 0.7, 1, 0.25)
        platzHinweis = anzeige:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        platzHinweis:SetPoint("BOTTOM", anzeige, "TOP", 0, 4)
    end
    if platzieren then
        if not platzKnopf then
            platzKnopf = CreateFrame("Button", "CallAssistanceFertig", UIParent, "UIPanelButtonTemplate")
            platzKnopf:SetSize(160, 30)
            platzKnopf:SetPoint("CENTER", UIParent, "CENTER", 0, -60)
            platzKnopf:SetFrameStrata("DIALOG")
            platzKnopf:SetScript("OnClick", function() setzePlatzieren(false) end)
        end
        platzKnopf:SetText(T("btn_done"))
        platzKnopf:Show()
        platzHinweis:SetText(T("position_hinweis"))
        platzFlaeche:Show()
        platzHinweis:Show()
        local groesse = DB.groesse or 40
        anzeige:SetSize(groesse + 70, groesse + 12)
        anzeige:Show()
    else
        if platzKnopf then platzKnopf:Hide() end
        platzFlaeche:Hide()
        platzHinweis:Hide()
        if #laufend == 0 then anzeige:Hide() end
    end
end

-- ---------------------------------------------------------------- Buff lesen

-- Liefert Restsekunden oder nil, wenn (gerade) nicht lesbar / nicht aktiv.
-- 🔴 Im Kampf sperrt WoW Addons den Aura-Zugriff komplett
-- ("Auras cannot be accessed when secret while tainted by ...") — dann gar nicht erst fragen,
-- sondern den Selbst-Countdown laufen lassen.
local function buffRest(posten)
    if InCombatLockdown() then return nil end
    if not posten.spellID or posten.spellID <= 0 then return nil end
    if not C_UnitAuras or not C_UnitAuras.GetPlayerAuraBySpellID then return nil end
    local ok, daten = pcall(C_UnitAuras.GetPlayerAuraBySpellID, posten.spellID)
    if not ok or not daten then return nil end
    local ablauf = daten.expirationTime
    if type(ablauf) ~= "number" or ablauf <= 0 then return nil end
    local rest = ablauf - GetTime()
    if rest <= 0 then return nil end
    return rest, daten.duration
end

-- ---------------------------------------------------------------- Anfrage starten

local indexLaufend = {}
local beende

local function formatiere(rest)
    if rest >= 60 then
        return string.format("%d:%02d", math.floor(rest / 60), math.floor(rest % 60))
    end
    if rest >= 3 then return string.format("%d", math.floor(rest + 0.5)) end
    return string.format("%.1f", math.max(0, rest))
end

local function starte(posten, dauerOverride)
    istDa()
    local jetzt = GetTime()
    local eintrag = indexLaufend[posten.id]
    if not eintrag then
        eintrag = { posten = posten, start = jetzt }
        indexLaufend[posten.id] = eintrag
        table.insert(laufend, eintrag)
    end
    eintrag.start = jetzt
    -- Dauer 0 = diese Anfrage soll gar nicht angezeigt werden
    local dauer = dauerOverride or posten.dauer
    if not dauer or dauer <= 0 then
        if indexLaufend[posten.id] then beende(indexLaufend[posten.id]) end
        return nil
    end
    eintrag.dauer = dauer
    eintrag.gesamt = eintrag.dauer
    eintrag.bis = nil
    eintrag.ausApi = false
    eintrag.aktiv = true
    zeilenBauen()

    local icon = posten.icon
    local z = eintrag.zeile
    if not icon or icon <= 0 then
        icon = (posten.spellID and posten.spellID > 0) and C_Spell.GetSpellTexture(posten.spellID) or nil
    end
    if icon then z.symbol:SetTexture(icon) end
    z.namensText:SetText(posten.name or "")
    z.zahl:SetText(formatiere(eintrag.dauer))
    z.zahl:SetTextColor(1, 1, 1)
    z.balken:SetWidth(DB.groesse or 40)
    z.balken:SetColorTexture(0.2, 1, 0.3, 0.95)
    return eintrag
end

beende = function(eintrag)
    indexLaufend[eintrag.posten.id] = nil
    for i, e in ipairs(laufend) do
        if e == eintrag then
            table.remove(laufend, i)
            break
        end
    end
    if eintrag.zeile then eintrag.zeile:Hide() end
    eintrag.aktiv = false
    zeilenBauen()
end

anzeige:SetScript("OnUpdate", function(_, dt)
    if #laufend == 0 then return end
    local jetzt = GetTime()
    for i = #laufend, 1, -1 do
        local eintrag = laufend[i]
        if eintrag ~= nil then
            local rest, buffDauer = buffRest(eintrag.posten)
            if rest then
                eintrag.rest = rest
                eintrag.ausApi = true
                if buffDauer and buffDauer > 0 then eintrag.dauer = buffDauer end
                eintrag.gesamt = eintrag.gesamt or eintrag.dauer
            else
                eintrag.ausApi = false
                rest = eintrag.dauer - (jetzt - eintrag.start)
                eintrag.rest = rest
                eintrag.gesamt = eintrag.dauer
            end

            local z = eintrag.zeile
            if z then
                if rest <= 0 then
                    beende(eintrag)
                else
                    z.zahl:SetText(formatiere(rest))
                    local anteil = 1
                    if eintrag.gesamt and eintrag.gesamt > 0 then
                        anteil = math.max(0, math.min(1, rest / eintrag.gesamt))
                    end
                    z.balken:SetWidth(math.max(1, (DB.groesse or 40) * anteil))
                    if rest <= 5 then
                        z.zahl:SetTextColor(1, 0.35, 0.35)
                        z.balken:SetColorTexture(1, 0.25, 0.25, 0.95)
                    else
                        z.zahl:SetTextColor(1, 1, 1)
                        z.balken:SetColorTexture(0.2, 1, 0.3, 0.95)
                    end
                    -- Symbol bleibt voll sichtbar; im Kampf ist der Buff grundsätzlich
                    -- nicht abfragbar, ein Hinweis darauf wäre also immer an.
                    z.symbol:SetDesaturated(false)
                    z.symbol:SetAlpha(1)
                end
            end
        end
    end
end)

-- ---------------------------------------------------------------- Ereignisse

local rahmen = CreateFrame("Frame")

local function istEigeneNachricht(event, absender)
    if event == "CHAT_MSG_WHISPER_INFORM" then return true end
    local ich = kurzName(UnitName and UnitName("player") or "")
    return #ich > 0 and kurzName(absender) == ich
end

local function pruefe(event, text, absender)
    istDa()
    if not DB.aktiv then return end

    if event == "CHAT_MSG_WHISPER_INFORM" and not DB.fluestern then return end
    if (event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER") and not DB.gruppe then return end
    if (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") and not DB.raid then return end
    if event ~= "CHAT_MSG_WHISPER_INFORM" and not istEigeneNachricht(event, absender) then return end

    melde("eigene Nachricht: " .. tostring(text), "|cff8080ff")

    for _, posten in ipairs(DB.posten) do
        -- pcall: im Kampf kann Chat-Text gesperrt sein — dann still weitermachen
        local ok, treffer = pcall(passt, text, posten)
        if not ok then
            melde("Text nicht lesbar (Kampf?): " .. tostring(treffer), "|cffff4040")
            return
        end
        if treffer then
            local eintrag = starte(posten)
            if not eintrag then return end
            melde(T("treffer", posten.name or "?"), "|cff80ff80")
            local rest = buffRest(posten)
            if rest then
                melde(T("buff_aus_api", formatiere(rest)), "|cff80ff80")
            else
                melde(T("buff_nicht_lesbar", eintrag.dauer), "|cffcccccc")
            end
            return
        end
    end
    melde("kein Treffer: " .. tostring(text), "|cffcccccc")
end

rahmen:RegisterEvent("PLAYER_LOGIN")
rahmen:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
rahmen:RegisterEvent("CHAT_MSG_PARTY")
rahmen:RegisterEvent("CHAT_MSG_PARTY_LEADER")
rahmen:RegisterEvent("CHAT_MSG_RAID")
rahmen:RegisterEvent("CHAT_MSG_RAID_LEADER")

rahmen:SetScript("OnEvent", function(_, event, arg1, arg2, ...)
    if event == "PLAYER_LOGIN" then
        dbInit()
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            C_ChatInfo.RegisterAddonMessagePrefix("CALLSPELL")
        end
        setzePosition()
        print("|cff40ff40CallAssistance|r " .. T("geladen", VERSION))
        baueOptionen()
        return
    end
    pruefe(event, arg1, arg2)
end)

-- ---------------------------------------------------------------- Makro

local function makroName(posten)
    local name = "CA" .. tostring(posten.name or "Call")
    if #name > 16 then name = string.sub(name, 1, 16) end
    return name
end

local function makroErstellen(posten)
    istDa()
    if InCombatLockdown() then return end
    if not posten.ziel or #posten.ziel == 0 then
        print("|cffff8080CallAssistance|r " .. T("ziel_fehlt"))
        return
    end
    if not posten.phrase or #posten.phrase == 0 then
        print("|cffff8080CallAssistance|r " .. T("phrase_fehlt"))
        return
    end

    local name = makroName(posten)
    local texture = (posten.icon and posten.icon > 0) and posten.icon or nil
    if not texture and posten.spellID and posten.spellID > 0 then
        texture = C_Spell.GetSpellTexture(posten.spellID)
    end
    texture = texture or 134400

    -- Zweite Zeile startet den Countdown direkt: im Kampf ist der eigene Chattext
    -- für Addons gesperrt ("secret string"), das Chat-Ereignis allein reicht dort nicht.
    local koerper = string.format("/w %s %s\n/ca start %d", posten.ziel, posten.phrase,
        math.floor(posten.spellID or 0))

    local index = GetMacroIndexByName and GetMacroIndexByName(name) or 0
    if index and index > 0 then
        DeleteMacro(index)
    end

    local neu = CreateMacro(name, texture, koerper, true)   -- true = charakterspezifisch
    if neu then
        print("|cff00ff00CallAssistance|r " .. T("makro_angelegt", name))
    else
        print("|cffff8080CallAssistance|r " .. T("kein_platz"))
    end
end

-- ---------------------------------------------------------------- Export / Import
-- Kompakter Textcode, damit der Mitspieler nichts eintippen muss:
--   <SpellID>|<Flüstertext>|<Ziel>;<SpellID>|<Flüstertext>|<Ziel>
-- Der Name der Anfrage kommt aus dem Zauber (C_Spell.GetSpellInfo), nicht aus dem Code.

local function exportCode()
    local teile = {}
    for _, p in ipairs(DB.posten) do
        local phrase = tostring(p.phrase or ""):gsub("[;|]", " ")
        local ziel = tostring(p.ziel or ""):gsub("[;|]", " ")
        table.insert(teile, string.format("%d|%s|%s|%d", p.spellID or 0, phrase, ziel,
            math.floor(p.dauer or 10)))
    end
    return table.concat(teile, ";")
end

local function importCode(code)
    if type(code) ~= "string" or #code == 0 then return 0 end
    -- Trenner tolerant: | ist der Standard, # und , werden ebenfalls akzeptiert
    if not string.find(code, "|", 1, true) then
        code = string.gsub(code, "#", "|")
        code = string.gsub(code, ",", "|")
    end
    local anzahl = 0
    for eintrag in string.gmatch(code, "([^;]+)") do
        local felder = {}
        for feld in string.gmatch(eintrag .. "|", "([^|]*)|") do
            table.insert(felder, feld)
        end
        local spellID = tonumber(felder[1])
        if spellID and spellID > 0 then
            local phrase = felder[2] or ""
            local ziel = felder[3] or ""
            local dauer = tonumber(felder[4])
            if dauer then dauer = math.floor(dauer) end
            if not dauer or dauer < 0 then dauer = nil end
            local name
            if C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(spellID)
                if info and info.name then name = info.name end
            end
            local vorhanden
            for _, p in ipairs(DB.posten) do
                if p.spellID == spellID then vorhanden = p; break end
            end
            if vorhanden then
                vorhanden.phrase = phrase
                vorhanden.ziel = ziel
                if dauer then vorhanden.dauer = dauer end
                if name and #name > 0 then vorhanden.name = name end
            else
                DB.naechsteID = (DB.naechsteID or 1) + 1
                table.insert(DB.posten, {
                    id = DB.naechsteID,
                    name = name or ("Spell " .. tostring(spellID)),
                    spellID = spellID,
                    icon = 0,
                    phrase = phrase,
                    ziel = ziel,
                    dauer = dauer or 10,
                })
            end
            anzahl = anzahl + 1
        end
    end
    if optionenPanel and aufbauen then aufbauen() end
    -- Makros gleich mit anlegen, damit dem Mitspieler ein Befehl reicht
    if not InCombatLockdown() then
        for _, posten in ipairs(DB.posten) do
            if posten.ziel and #tostring(posten.ziel) > 0
                and posten.phrase and #tostring(posten.phrase) > 0 then
                makroErstellen(posten)
            end
        end
    end
    return anzahl
end

-- ---------------------------------------------------------------- Slash

local function hilfe()
    print("|cff40ff40CallAssistance|r " .. T("hilfe_titel") or "—")
    print(T("hilfe"))
end

SLASH_CALLASSISTANCE1 = "/ca"
SLASH_CALLASSISTANCE2 = "/callassist"
SlashCmdList["CALLASSISTANCE"] = function(rest)
    istDa()
    rest = rest or ""
    local befehl, arg = rest:match("^(%S*)%s*(.*)$")
    befehl = string.lower(befehl or "")

    if befehl == "" or befehl == "help" then
        hilfe()
    elseif befehl == "config" then
        oeffneOptionen()
    elseif befehl == "an" then
        DB.aktiv = true; print("|cff40ff40CallAssistance|r " .. T("an"))
    elseif befehl == "aus" then
        DB.aktiv = false; print("|cff40ff40CallAssistance|r " .. T("aus"))
    elseif befehl == "debug" then
        DB.debug = not DB.debug
        print("|cff40ff40CallAssistance|r debug: " .. (DB.debug and "an" or "aus"))
    elseif befehl == "test" then
        local p = DB.posten[1]
        if p then
            local e = starte(p, 10)
            local z = e.zeile
            local icon = p.icon > 0 and p.icon or C_Spell.GetSpellTexture(p.spellID)
            if icon then z.symbol:SetTexture(icon) end
            e.bis = GetTime() + 10
            print("|cff40ff40CallAssistance|r " .. T("test"))
        end
    elseif befehl == "neu" or befehl == "new" then
        local id = tonumber(arg:match("^(%d+)"))
        local name = arg:match("^%d+%s+(.*)$")
        if not id then
            print("|cffff8080CallAssistance|r " .. T("neu_fehlt"))
            return
        end
        if not name or #name == 0 then name = T("zauber") end
        DB.naechsteID = (DB.naechsteID or 1) + 1
        table.insert(DB.posten, { id = DB.naechsteID, name = name, spellID = id, icon = 0,
                                  phrase = "", ziel = "", dauer = 10 })
        print("|cff40ff40CallAssistance|r " .. T("neu_gemacht", name, id, #DB.posten))
        if optionenPanel then aufbauen() end
    elseif befehl == "weg" then
        local idx = tonumber(arg)
        if not idx or not DB.posten[math.floor(idx)] then
            print("|cffff8080CallAssistance|r " .. T("weg_fehlt"))
            return
        end
        local eintrag = DB.posten[math.floor(idx)]
        if eintrag and indexLaufend[eintrag.id] then beende(indexLaufend[eintrag.id]) end
        table.remove(DB.posten, math.floor(idx))
        if optionenPanel then aufbauen() end
    elseif befehl == "phrase" or befehl == "ziel" or befehl == "dauer" or befehl == "icon" then
        local nr, wert = arg:match("^(%d+)%s*(.-)$")
        local posten = nr and DB.posten[math.floor(tonumber(nr))]
        if not posten then
            print("|cffff8080CallAssistance|r " .. T("zeile_falsch", befehl))
            return
        end
        if befehl == "phrase" then
            posten.phrase = wert
        elseif befehl == "ziel" then
            posten.ziel = wert
        elseif befehl == "icon" then
            local n = tonumber(wert)
            posten.icon = (n and n > 0) and math.floor(n) or 0
        elseif befehl == "dauer" then
            local n = tonumber(wert)
            if n and n >= 0 then posten.dauer = math.floor(n) end
        end
        print("|cff40ff40CallAssistance|r " .. T("gesetzt", posten.name or "?", befehl, tostring(wert)))
        if optionenPanel then aufbauen() end
    elseif befehl == "import" then
        local anzahl = importCode(arg)
        if anzahl == 0 then
            print("|cffff8080CallAssistance|r " .. T("import_leer"))
        else
            print("|cff40ff40CallAssistance|r " .. T("import_ok", anzahl))
        end
    elseif befehl == "export" then
        print("|cff40ff40CallAssistance|r " .. T("export_kopf"))
        print(exportCode())
    elseif befehl == "position" or befehl == "bewegen" then
        setzePlatzieren(not platzieren)
        print("|cff40ff40CallAssistance|r " .. (platzieren and T("position_an") or T("position_aus")))
    elseif befehl == "start" then
        local id = tonumber(arg)
        local gefunden
        if id then
            for _, posten in ipairs(DB.posten) do
                if posten.spellID == math.floor(id) then gefunden = posten; break end
            end
        end
        if not gefunden and id then gefunden = DB.posten[math.floor(id)] end
        if gefunden then
            starte(gefunden)
            -- Zusätzlich per Addon-Kanal an den Caster: dort zeigt CallSpell das Symbol,
            -- auch im Kampf, wo der Chattext gesperrt ist.
            local ziel = gefunden.ziel
            if ziel and #tostring(ziel) > 0 and C_ChatInfo and C_ChatInfo.SendAddonMessage then
                pcall(C_ChatInfo.SendAddonMessage, "CALLSPELL",
                    tostring(math.floor(gefunden.spellID or 0)), "WHISPER", ziel)
            end
        end
    elseif befehl == "macros" then
        istDa()
        if InCombatLockdown() then
            print("|cffff8080CallAssistance|r " .. T("kein_kampf"))
            return
        end
        local anzahl = 0
        for _, posten in ipairs(DB.posten) do
            if posten.ziel and #posten.ziel > 0 then
                makroErstellen(posten)
                anzahl = anzahl + 1
            end
        end
        if anzahl == 0 then print("|cffff8080CallAssistance|r " .. T("ziel_fehlt")) end
    elseif befehl == "macro" then
        local idx = tonumber(arg)
        local posten = idx and DB.posten[math.floor(idx)]
        if not posten then
            print("|cffff8080CallAssistance|r " .. T("zeile_falsch", "macro"))
            return
        end
        makroErstellen(posten)
    elseif befehl == "anzeige" then
        local was, wert = arg:match("^(%S+)%s*(%S*)$")
        local felder = { symbol = "zeigeSymbol", zahl = "zeigeZahl", balken = "zeigeBalken" }
        local feld = was and felder[string.lower(was)]
        if not feld then
            print("|cffff8080CallAssistance|r " .. T("unbekannt", tostring(was)))
            return
        end
        DB[feld] = (wert ~= "aus" and wert ~= "off")
        zeilenBauen()
        print("|cff40ff40CallAssistance|r " .. was .. ": " .. (DB[feld] and "an" or "aus"))
    else
        print("|cffff8080CallAssistance|r " .. T("unbekannt", befehl))
    end
end

-- ---------------------------------------------------------------- Einstellungen (Spiel-Optionen)

local function ueberschrift(eltern, text, y)
    local fs = eltern:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", eltern, "TOPLEFT", 12, y)
    fs:SetText(text)
    return fs
end

local function hinweis(eltern, text, y, breite)
    local fs = eltern:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", eltern, "TOPLEFT", 12, y)
    fs:SetWidth(breite or 480)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    return fs
end

local function kaestchen(eltern, beschriftung, x, y, lesen, schreiben)
    local cb = CreateFrame("CheckButton", nil, eltern, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", eltern, "TOPLEFT", x, y)
    cb:SetSize(26, 26)
    if cb.Text then cb.Text:SetText(beschriftung) end
    cb:SetScript("OnClick", function(self) schreiben(self:GetChecked() and true or false) end)
    cb.aktualisiere = function() cb:SetChecked(lesen() and true or false) end
    cb.aktualisiere()
    return cb
end

-- Schlichtes Eingabefeld (kein InputBoxTemplate: das verschiebt den Textbereich)
local function feld(eltern, x, y, breite, lesen, schreiben)
    local eb = CreateFrame("EditBox", nil, eltern)
    eb:SetSize(breite, 20)
    eb:SetPoint("TOPLEFT", eltern, "TOPLEFT", x, y)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(80)
    eb:SetFontObject(GameFontHighlight)
    eb:SetTextColor(1, 1, 1)
    eb:SetJustifyH("LEFT")
    eb:SetTextInsets(4, 4, 0, 0)
    eb:EnableMouse(true)
    local bg = eb:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.08)
    eb:SetText(tostring(lesen() or ""))
    eb:SetCursorPosition(0)
    local function sichern(self) schreiben(self:GetText() or "") end
    eb:SetScript("OnEnterPressed", function(self) sichern(self); self:ClearFocus() end)
    eb:SetScript("OnEditFocusLost", sichern)
    eb:SetScript("OnEscapePressed", function(self) self:SetText(tostring(lesen() or "")); self:ClearFocus() end)
    eb.aktualisiere = function() eb:SetText(tostring(lesen() or "")) end
    return eb
end

-- Spalten: Name, SpellID, Symbol, Fluestertext, Ziel, Dauer | Macro | ×
local SPALTEN = { { "col_name", 8, 70 }, { "col_spellid", 82, 56 }, { "col_symbol", 142, 56 },
                  { "col_phrase", 202, 86 }, { "col_target", 292, 76 }, { "col_dauer", 372, 40 } }

aufbauen = function()
    if inhaltFrame then
        inhaltFrame:Hide()
        inhaltFrame = nil
    end
    aufbauZaehler = aufbauZaehler + 1
    local c = CreateFrame("Frame", nil, optionenPanel)
    c:SetAllPoints(optionenPanel)
    inhaltFrame = c

    local y = -16

    -- ---------------- Anfrage-Tabelle
    ueberschrift(c, T("zauber"), y)
    y = y - 30

    for _, spalte in ipairs(SPALTEN) do
        local fs = c:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", c, "TOPLEFT", spalte[2], y)
        fs:SetText(T(spalte[1]))
    end

    local linie = c:CreateTexture(nil, "ARTWORK")
    linie:SetColorTexture(1, 1, 1, 0.15)
    linie:SetPoint("TOPLEFT", c, "TOPLEFT", 12, y - 14)
    linie:SetSize(596, 1)

    local felder = {}
    local zeilenY = y - 22

    for i, posten in ipairs(DB.posten) do
        local idx = i          -- eigene Kopie je Zeile (Lua 5.1 teilt die Laufvariable)
        local zy = zeilenY - (i - 1) * 28
        felder[i] = {
            name = feld(c, 8, zy, 70,
                function() return DB.posten[idx] and DB.posten[idx].name end,
                function(t) local e = DB.posten[idx]; if e and #t > 0 then e.name = t end end),
            spellID = feld(c, 82, zy, 56,
                function() local e = DB.posten[idx]; return e and tostring(e.spellID) end,
                function(t) local e = DB.posten[idx]; local n = tonumber(t)
                    if e and n and n > 0 then e.spellID = math.floor(n) end end),
            icon = feld(c, 142, zy, 56,
                function() local e = DB.posten[idx]; return (e and e.icon and e.icon > 0) and tostring(e.icon) or "" end,
                function(t) local e = DB.posten[idx]; local n = tonumber(t)
                    if e then e.icon = (n and n > 0) and math.floor(n) or 0 end end),
            phrase = feld(c, 202, zy, 86,
                function() local e = DB.posten[idx]; return e and e.phrase end,
                function(t) local e = DB.posten[idx]; if e then e.phrase = t end end),
            ziel = feld(c, 292, zy, 76,
                function() local e = DB.posten[idx]; return e and e.ziel end,
                function(t) local e = DB.posten[idx]; if e then e.ziel = t end end),
            dauer = feld(c, 372, zy, 40,
                function() local e = DB.posten[idx]; return e and tostring(e.dauer) end,
                function(t) local e = DB.posten[idx]; local n = tonumber(t)
                    if e and n and n >= 0 then e.dauer = math.floor(n) end end),
        }
        local makro = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
        makro:SetSize(104, 20)
        makro:SetPoint("TOPLEFT", c, "TOPLEFT", 418, zy)
        makro:SetText(T("btn_macro"))
        makro:SetScript("OnClick", function() makroErstellen(DB.posten[idx]) end)
        felder[i].makro = makro

        local weg = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
        weg:SetSize(18, 18)
        weg:SetPoint("TOPLEFT", c, "TOPLEFT", 534, zy + 1)
        weg:SetText("×")
        weg:SetScript("OnClick", function()
            local eintrag = DB.posten[idx]
            if eintrag and indexLaufend[eintrag.id] then beende(indexLaufend[eintrag.id]) end
            table.remove(DB.posten, idx)
            aufbauen()
        end)
        felder[i].weg = weg
    end

    y = zeilenY - math.max(1, #DB.posten) * 28 - 6

    local neuerKnopf = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    neuerKnopf:SetSize(170, 22)
    neuerKnopf:SetPoint("TOPLEFT", c, "TOPLEFT", 12, y)
    neuerKnopf:SetText(T("btn_new"))
    neuerKnopf:SetScript("OnClick", function()
        DB.naechsteID = (DB.naechsteID or 1) + 1
        table.insert(DB.posten, { id = DB.naechsteID, name = T("zauber"), spellID = 0,
                                  icon = 0, phrase = "", ziel = "", dauer = 10 })
        aufbauen()
    end)

    y = y - 26
    hinweis(c, T("hint_spells"), y, 540)

    -- ---------------- Anzeige
    y = y - 30
    ueberschrift(c, T("anzeige"), y)
    y = y - 30
    kaestchen(c, T("cb_symbol"), 16, y, function() return DB.zeigeSymbol end,
        function(w) DB.zeigeSymbol = w; zeilenBauen() end)
    kaestchen(c, T("cb_zahl"), 190, y, function() return DB.zeigeZahl end,
        function(w) DB.zeigeZahl = w; zeilenBauen() end)
    kaestchen(c, T("cb_balken"), 340, y, function() return DB.zeigeBalken end,
        function(w) DB.zeigeBalken = w; zeilenBauen() end)

    local groesseWert = c:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    groesseWert:SetPoint("TOPLEFT", c, "TOPLEFT", 500, y - 6)
    groesseWert:SetText(string.format("%d", DB.groesse))

    local sliderName = "CallAssistanceGroesse" .. aufbauZaehler
    local slider = CreateFrame("Slider", sliderName, c, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", c, "TOPLEFT", 16, y - 40)
    slider:SetSize(280, 16)
    slider:SetMinMaxValues(20, 64)
    slider:SetValueStep(2)
    slider:SetObeyStepOnDrag(true)
    if _G[sliderName .. "Text"] then _G[sliderName .. "Text"]:SetText(T("slider_size")) end
    if _G[sliderName .. "Low"] then _G[sliderName .. "Low"]:SetText("20") end
    if _G[sliderName .. "High"] then _G[sliderName .. "High"]:SetText("64") end
    slider:SetValue(DB.groesse)
    slider:SetScript("OnValueChanged", function(_, wert)
        wert = math.floor((wert or 40) + 0.5)
        DB.groesse = wert
        groesseWert:SetText(string.format("%d", wert))
        zeilenBauen()
    end)

    local verschieben = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    verschieben:SetSize(190, 22)
    verschieben:SetPoint("TOPLEFT", c, "TOPLEFT", 330, y - 38)
    verschieben:SetText(T("btn_move"))
    verschieben:SetScript("OnClick", function()
        if InCombatLockdown() then
            print("|cffff8080CallAssistance|r " .. T("kein_kampf"))
            return
        end
        if SettingsPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
        setzePlatzieren(true)
        print("|cff40ff40CallAssistance|r " .. T("position_an"))
    end)

    -- ---------------- Kanaele
    y = y - 84
    ueberschrift(c, T("kanaele"), y)
    y = y - 30
    kaestchen(c, T("cb_whisper"), 16, y, function() return DB.fluestern end, function(w) DB.fluestern = w end)
    kaestchen(c, T("cb_party"), 170, y, function() return DB.gruppe end, function(w) DB.gruppe = w end)
    kaestchen(c, T("cb_raid"), 300, y, function() return DB.raid end, function(w) DB.raid = w end)

    -- ---------------- Sprache + Debug
    y = y - 46
    kaestchen(c, T("cb_debug"), 16, y, function() return DB.debug end, function(w) DB.debug = w end)

    y = y - 40
    ueberschrift(c, T("sprache"), y)
    y = y - 30
    local sprachKnopf = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    sprachKnopf:SetSize(220, 22)
    sprachKnopf:SetPoint("TOPLEFT", c, "TOPLEFT", 12, y)
    local function sprachText()
        local w = DB.sprache or "auto"
        if w == "de" then return T("sprache_de") end
        if w == "en" then return T("sprache_en") end
        return T("sprache_auto")
    end
    sprachKnopf:SetText(sprachText())
    sprachKnopf:SetScript("OnClick", function()
        local w = DB.sprache or "auto"
        if w == "auto" then DB.sprache = "de"
        elseif w == "de" then DB.sprache = "en"
        else DB.sprache = "auto" end
        aufbauen()
    end)

    optionenPanel.aktualisiere = function()
        for _, satz in ipairs(felder) do
            for _, f in pairs(satz) do
                if type(f) == "table" and f.aktualisiere then f:aktualisiere() end
            end
        end
        groesseWert:SetText(string.format("%d", DB.groesse))
        slider:SetValue(DB.groesse)
    end

    return c
end

baueOptionen = function()
    if optionenPanel then return optionenPanel end

    local p = CreateFrame("Frame", "CallAssistanceOptionen")
    p.name = "Call Assistance"
    optionenPanel = p

    aufbauen()

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local kat = Settings.RegisterCanvasLayoutCategory(p, "Call Assistance")
        if kat then
            Settings.RegisterAddOnCategory(kat)
            p.kategorie = kat
        end
    end

    if not p.kategorie then
        p:SetSize(600, 560)
        p:SetPoint("CENTER")
        p:SetFrameStrata("DIALOG")
        p:EnableMouse(true)
        p:SetMovable(true)
        p:RegisterForDrag("LeftButton")
        p:SetScript("OnDragStart", p.StartMoving)
        p:SetScript("OnDragStop", p.StopMovingOrSizing)
        local bg = p:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.05, 0.05, 0.07, 0.92)
        local t = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        t:SetPoint("TOP", 0, -10)
        t:SetText("Call Assistance")
        local zu = CreateFrame("Button", nil, p, "UIPanelCloseButton")
        zu:SetPoint("TOPRIGHT", -4, -4)
        tinsert(UISpecialFrames, "CallAssistanceOptionen")
    end

    return p
end

oeffneOptionen = function()
    istDa()
    local p = baueOptionen()
    if p.aktualisiere then p.aktualisiere() end
    if p.kategorie and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(p.kategorie:GetID())
    else
        p:Show()
    end
end
