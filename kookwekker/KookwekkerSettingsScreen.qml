import QtQuick 1.1
import qb.components 1.0

Screen {
	id: kookwekkerSettingsScreen
	screenTitle: "Kookwekker instellingen"

	property real sc: width / 1024
	property int margin: Math.round(20 * sc)
	property int rightX: Math.round(610 * sc)
	property int rightW: width - rightX - margin
	property int leftW: Math.round(560 * sc)

	// Opent het schermtoetsenbord (indien aanwezig); callback krijgt de ingevoerde tekst
	function editText(title, current, callback) {
		if (typeof qkeyboard !== "undefined")
			qkeyboard.open(title, current, callback);
	}

	function saveUrl(text) {
		if (text !== undefined && text !== null)
			app.setHaUrl(text);
	}

	function saveWebhook(text) {
		if (text !== undefined && text !== null)
			app.setHaWebhook(text);
	}

	function saveName(text) {
		if (text !== undefined && text !== null)
			app.addName(text);
	}

	// ---------- Links: snelkeuzes ----------
	Text {
		x: kookwekkerSettingsScreen.margin
		y: Math.round(10 * kookwekkerSettingsScreen.sc)
		text: "Snelkeuzes (tik op kleur of naam om te wisselen)"
		font.family: qfont.bold.name
		font.pixelSize: Math.round(22 * kookwekkerSettingsScreen.sc)
		color: "#333333"
	}

	ListView {
		id: presetList
		x: kookwekkerSettingsScreen.margin
		y: Math.round(52 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.leftW
		height: Math.round(6 * 66 * kookwekkerSettingsScreen.sc)
		spacing: Math.round(6 * kookwekkerSettingsScreen.sc)
		clip: true
		interactive: false
		model: app.presets

		delegate: Item {
			width: presetList.width
			height: Math.round(60 * kookwekkerSettingsScreen.sc)

			Rectangle {
				x: 0
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(56 * kookwekkerSettingsScreen.sc)
				height: Math.round(52 * kookwekkerSettingsScreen.sc)
				radius: Math.round(8 * kookwekkerSettingsScreen.sc)
				color: model.col

				MouseArea {
					anchors.fill: parent
					onClicked: app.cyclePresetColor(index)
				}
			}

			StandardButton {
				x: Math.round(64 * kookwekkerSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(190 * kookwekkerSettingsScreen.sc)
				height: Math.round(52 * kookwekkerSettingsScreen.sc)
				text: model.label
				onClicked: app.cyclePresetName(index)
			}

			StandardButton {
				x: Math.round(262 * kookwekkerSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(56 * kookwekkerSettingsScreen.sc)
				height: Math.round(52 * kookwekkerSettingsScreen.sc)
				text: "-"
				onClicked: app.changePresetMinutes(index, -1)
			}

			Text {
				x: Math.round(324 * kookwekkerSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(90 * kookwekkerSettingsScreen.sc)
				horizontalAlignment: Text.AlignHCenter
				text: model.minutes + " min"
				font.family: qfont.bold.name
				font.pixelSize: Math.round(22 * kookwekkerSettingsScreen.sc)
				color: "#222222"
			}

			StandardButton {
				x: Math.round(420 * kookwekkerSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(56 * kookwekkerSettingsScreen.sc)
				height: Math.round(52 * kookwekkerSettingsScreen.sc)
				text: "+"
				onClicked: app.changePresetMinutes(index, 1)
			}

			StandardButton {
				x: Math.round(484 * kookwekkerSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(76 * kookwekkerSettingsScreen.sc)
				height: Math.round(52 * kookwekkerSettingsScreen.sc)
				text: "Weg"
				onClicked: app.removePreset(index)
			}
		}
	}

	StandardButton {
		id: addPresetButton
		x: kookwekkerSettingsScreen.margin
		y: Math.round(456 * kookwekkerSettingsScreen.sc)
		width: Math.round(272 * kookwekkerSettingsScreen.sc)
		height: Math.round(56 * kookwekkerSettingsScreen.sc)
		text: "+ Snelkeuze"
		enabled: app.presets.count < app.maxPresets
		onClicked: app.addPreset()
	}

	StandardButton {
		id: addNameButton
		x: kookwekkerSettingsScreen.margin + Math.round(288 * kookwekkerSettingsScreen.sc)
		y: Math.round(456 * kookwekkerSettingsScreen.sc)
		width: Math.round(272 * kookwekkerSettingsScreen.sc)
		height: Math.round(56 * kookwekkerSettingsScreen.sc)
		text: "+ Nieuwe naam"
		onClicked: kookwekkerSettingsScreen.editText("Nieuwe naam", "", kookwekkerSettingsScreen.saveName)
	}

	// ---------- Rechts: Home Assistant ----------
	Text {
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(10 * kookwekkerSettingsScreen.sc)
		text: "Home Assistant"
		font.family: qfont.bold.name
		font.pixelSize: Math.round(22 * kookwekkerSettingsScreen.sc)
		color: "#333333"
	}

	StandardButton {
		id: haToggle
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(52 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.rightW
		height: Math.round(56 * kookwekkerSettingsScreen.sc)
		text: app.haEnabled ? "Koppeling: AAN" : "Koppeling: UIT"
		onClicked: app.toggleHa()
	}

	KookwekkerField {
		id: urlField
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(120 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.rightW
		height: Math.round(62 * kookwekkerSettingsScreen.sc)
		sc: kookwekkerSettingsScreen.sc
		title: "Adres van Home Assistant (bijv. 192.168.1.10:8123)"
		value: app.haUrl
		onClicked: kookwekkerSettingsScreen.editText("Home Assistant-adres", app.haUrl, kookwekkerSettingsScreen.saveUrl)
	}

	KookwekkerField {
		id: hookField
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(194 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.rightW
		height: Math.round(62 * kookwekkerSettingsScreen.sc)
		sc: kookwekkerSettingsScreen.sc
		title: "Webhook-id"
		value: app.haWebhook
		onClicked: kookwekkerSettingsScreen.editText("Webhook-id", app.haWebhook, kookwekkerSettingsScreen.saveWebhook)
	}

	StandardButton {
		id: haTest
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(272 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.rightW
		height: Math.round(56 * kookwekkerSettingsScreen.sc)
		text: "Stuur testbericht"
		onClicked: app.testHa()
	}

	Text {
		id: haStatusText
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(340 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.rightW
		wrapMode: Text.WordWrap
		text: app.haStatus
		font.family: qfont.bold.name
		font.pixelSize: Math.round(18 * kookwekkerSettingsScreen.sc)
		color: "#333333"
	}

	Text {
		x: kookwekkerSettingsScreen.rightX
		y: Math.round(390 * kookwekkerSettingsScreen.sc)
		width: kookwekkerSettingsScreen.rightW
		wrapMode: Text.WordWrap
		text: "Verstuurt een POST met JSON naar adres/api/webhook/id bij: started, finished, dismissed, cancelled en extended. Zie ha-voorbeeld.yaml."
		font.family: qfont.regular.name
		font.pixelSize: Math.round(16 * kookwekkerSettingsScreen.sc)
		color: "#777777"
	}
}
