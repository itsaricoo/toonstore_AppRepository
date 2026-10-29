# Kookwekker (Toon QML-app)

Functies: tot 4 timers met naam en kleur, eigen snelkeuzes (instellingen), tile, tray, alarm met geluid en Home Assistant-webhook.

Bestanden:
- kookwekkerApp.qml: timerlogica, opslag, alarm, geluid
- KookwekkerScreen.qml: hoofdscherm (lopende timers, snelkeuzes, eigen tijd)
- KookwekkerAlarmScreen.qml: knipperend scherm als een timer afloopt
- KookwekkerTile.qml: tile met de eerstvolgende afteltijd
- KookwekkerSettingsScreen.qml: snelkeuzes beheren, namen toevoegen, Home Assistant instellen
- KookwekkerField.qml: klein aantikbaar tekstveld (opent het toetsenbord)
- ha-voorbeeld.yaml: voorbeeld-automation voor de webhook
- KookwekkerSystray.qml: tray-icoon met de resterende tijd ("5m", "42s", "!"), alleen zichtbaar als er een timer is; tik opent het hoofdscherm
- drawables/ (kookwekker.png, kookwekker-tray.png, kookwekker-tray-alarm.png), sounds/alarm.wav

Testen op een geroote Toon:
1. Kopieer de map `kookwekker` naar `/qmf/qml/apps/kookwekker/` (zelfde plek als je andere apps).
2. Herstart de GUI en voeg de tile toe via het tegel-overzicht.

Opslag: timers, snelkeuzes, namen en HA-instellingen staan in `/mnt/data/tsc/kookwekker_userSettings.json`
(werkt alleen als TSC schrijven via file:// toestaat, zoals bij andere apps).
Verloopt geluid niet? Dan mist waarschijnlijk QtMultimediaKit; het visuele alarm werkt dan nog.

Voor ToonStore: voeg `ToonRepo-entry.xml` toe aan ToonRepo.xml en lever de map aan als eigen app-repo.

Home Assistant: zet bij Instellingen de koppeling AAN, vul adres en webhook-id in en druk op 'Stuur testbericht'. Het bericht gaat via HTTP (geen HTTPS) naar je lokale HA.
Het toetsenbord (qkeyboard) bestaat niet op elke firmware: ontbreekt het, dan kun je adres, webhook-id en namen niet via het scherm wijzigen en pas je ze aan in het JSON-bestand.
