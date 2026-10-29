import QtQuick 1.1
import qb.components 1.0

Screen {
	id: kookwekkerScreen
	screenTitle: "Kookwekker"

	// Ontworpen op 1024x600, schaalt mee naar 800x480
	property real sc: width / 1024
	property int gap: Math.round(12 * sc)
	property int margin: Math.round(20 * sc)
	property int leftW: Math.round(470 * sc)
	property int rightX: Math.round(500 * sc)
	property int rightW: width - rightX - margin
	property bool full: app.timers.count >= app.maxTimers
	property int customMinutes: 10
	property int customNameIndex: 0
	property int customColorIndex: 0

	function changeCustom(delta) {
		var m = customMinutes + delta;
		if (m < 1)
			m = 1;
		if (m > 180)
			m = 180;
		customMinutes = m;
	}

	function currentName() {
		var n = app.names.length;
		if (n === 0)
			return "Timer";
		return app.names[customNameIndex % n];
	}

	function changeName(dir) {
		var n = app.names.length;
		if (n === 0)
			return;
		customNameIndex = (customNameIndex + dir + n) % n;
	}

	function nextCustomColor() {
		customColorIndex = (customColorIndex + 1) % app.palette.length;
	}

	// ---------- Links: lopende timers ----------
	Text {
		id: runningTitle
		x: kookwekkerScreen.margin
		y: Math.round(10 * kookwekkerScreen.sc)
		text: "Lopende timers"
		font.family: qfont.bold.name
		font.pixelSize: Math.round(24 * kookwekkerScreen.sc)
		color: "#333333"
	}

	Text {
		id: emptyHint
		x: kookwekkerScreen.margin
		y: Math.round(70 * kookwekkerScreen.sc)
		visible: app.timers.count === 0
		text: "Geen actieve timers.\nKies rechts een snelkeuze of stel een eigen tijd in."
		font.family: qfont.regular.name
		font.pixelSize: Math.round(20 * kookwekkerScreen.sc)
		color: "#777777"
	}

	ListView {
		id: timerList
		x: kookwekkerScreen.margin
		y: Math.round(52 * kookwekkerScreen.sc)
		width: kookwekkerScreen.leftW
		height: Math.round(4 * 96 * kookwekkerScreen.sc)
		spacing: Math.round(8 * kookwekkerScreen.sc)
		clip: true
		interactive: false
		model: app.timers

		delegate: Rectangle {
			width: timerList.width
			height: Math.round(88 * kookwekkerScreen.sc)
			radius: Math.round(8 * kookwekkerScreen.sc)
			color: model.done ? "#f0ad4e" : "#e8eef2"

			// Kleurstrook van de timer
			Rectangle {
				x: 0
				y: 0
				width: Math.round(12 * kookwekkerScreen.sc)
				height: parent.height
				radius: Math.round(6 * kookwekkerScreen.sc)
				color: model.col
			}

			Text {
				x: Math.round(26 * kookwekkerScreen.sc)
				y: Math.round(8 * kookwekkerScreen.sc)
				text: model.label
				font.family: qfont.regular.name
				font.pixelSize: Math.round(20 * kookwekkerScreen.sc)
				color: "#333333"
			}

			Text {
				x: Math.round(26 * kookwekkerScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				anchors.verticalCenterOffset: Math.round(6 * kookwekkerScreen.sc)
				text: model.done ? "Klaar!" : app.fmt(model.remaining)
				font.family: qfont.bold.name
				font.pixelSize: Math.round(44 * kookwekkerScreen.sc)
				color: model.done ? "#8a1c1c" : "#222222"
			}

			StandardButton {
				id: plusButton
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: stopButton.left
				anchors.rightMargin: Math.round(8 * kookwekkerScreen.sc)
				width: Math.round(70 * kookwekkerScreen.sc)
				height: Math.round(60 * kookwekkerScreen.sc)
				text: "+1"
				onClicked: app.extendTimer(index, 60)
			}

			StandardButton {
				id: stopButton
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				anchors.rightMargin: Math.round(10 * kookwekkerScreen.sc)
				width: Math.round(90 * kookwekkerScreen.sc)
				height: Math.round(60 * kookwekkerScreen.sc)
				text: "Stop"
				onClicked: app.removeTimer(index)
			}

			// Voortgangsbalkje onderaan
			Rectangle {
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				height: Math.round(5 * kookwekkerScreen.sc)
				radius: height / 2
				color: model.done ? "#8a1c1c" : model.col
				width: model.done ? parent.width : (model.totalSec > 0 ? parent.width * model.remaining / model.totalSec : 0)
			}
		}
	}

	StandardButton {
		id: settingsButton
		x: kookwekkerScreen.margin
		y: Math.round(448 * kookwekkerScreen.sc)
		width: kookwekkerScreen.leftW
		height: Math.round(56 * kookwekkerScreen.sc)
		text: "Instellingen"
		onClicked: stage.openFullscreen(app.settingsScreenUrl)
	}

	// ---------- Rechts: snelkeuzes ----------
	Text {
		id: presetsTitle
		x: kookwekkerScreen.rightX
		y: Math.round(10 * kookwekkerScreen.sc)
		text: "Snel starten"
		font.family: qfont.bold.name
		font.pixelSize: Math.round(24 * kookwekkerScreen.sc)
		color: "#333333"
	}

	Grid {
		id: presetGrid
		x: kookwekkerScreen.rightX
		y: Math.round(52 * kookwekkerScreen.sc)
		columns: 2
		spacing: kookwekkerScreen.gap

		Repeater {
			model: app.presets

			Item {
				width: Math.floor((kookwekkerScreen.rightW - kookwekkerScreen.gap) / 2)
				height: Math.round(56 * kookwekkerScreen.sc)

				StandardButton {
					anchors.fill: parent
					text: model.label + "  " + model.minutes + " min"
					enabled: !kookwekkerScreen.full
					onClicked: app.addTimer(model.label, model.minutes * 60, model.col)
				}

				// Kleurmarkering links op de knop
				Rectangle {
					x: Math.round(6 * kookwekkerScreen.sc)
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(10 * kookwekkerScreen.sc)
					height: parent.height - Math.round(16 * kookwekkerScreen.sc)
					radius: width / 2
					color: model.col
				}
			}
		}
	}

	// ---------- Rechts: eigen timer ----------
	Text {
		id: customTitle
		x: kookwekkerScreen.rightX
		y: Math.round(254 * kookwekkerScreen.sc)
		text: "Eigen timer"
		font.family: qfont.bold.name
		font.pixelSize: Math.round(22 * kookwekkerScreen.sc)
		color: "#333333"
	}

	// Minuten
	Row {
		id: customRow
		x: kookwekkerScreen.rightX
		y: Math.round(284 * kookwekkerScreen.sc)
		spacing: kookwekkerScreen.gap

		property int dispW: Math.round(140 * kookwekkerScreen.sc)
		property int btnW: Math.floor((kookwekkerScreen.rightW - 4 * kookwekkerScreen.gap - dispW) / 4)

		StandardButton {
			width: customRow.btnW
			height: Math.round(56 * kookwekkerScreen.sc)
			text: "-5"
			onClicked: kookwekkerScreen.changeCustom(-5)
		}

		StandardButton {
			width: customRow.btnW
			height: Math.round(56 * kookwekkerScreen.sc)
			text: "-1"
			onClicked: kookwekkerScreen.changeCustom(-1)
		}

		Text {
			width: customRow.dispW
			height: Math.round(56 * kookwekkerScreen.sc)
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			text: kookwekkerScreen.customMinutes + " min"
			font.family: qfont.bold.name
			font.pixelSize: Math.round(30 * kookwekkerScreen.sc)
			color: "#222222"
		}

		StandardButton {
			width: customRow.btnW
			height: Math.round(56 * kookwekkerScreen.sc)
			text: "+1"
			onClicked: kookwekkerScreen.changeCustom(1)
		}

		StandardButton {
			width: customRow.btnW
			height: Math.round(56 * kookwekkerScreen.sc)
			text: "+5"
			onClicked: kookwekkerScreen.changeCustom(5)
		}
	}

	// Naam en kleur
	Row {
		id: nameRow
		x: kookwekkerScreen.rightX
		y: Math.round(352 * kookwekkerScreen.sc)
		spacing: kookwekkerScreen.gap

		property int arrowW: Math.round(64 * kookwekkerScreen.sc)
		property int swatchW: Math.round(56 * kookwekkerScreen.sc)
		property int nameW: kookwekkerScreen.rightW - 2 * arrowW - swatchW - 3 * kookwekkerScreen.gap

		StandardButton {
			width: nameRow.arrowW
			height: Math.round(56 * kookwekkerScreen.sc)
			text: "<"
			onClicked: kookwekkerScreen.changeName(-1)
		}

		Rectangle {
			width: nameRow.nameW
			height: Math.round(56 * kookwekkerScreen.sc)
			radius: Math.round(8 * kookwekkerScreen.sc)
			color: "#e8eef2"

			Text {
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
				text: kookwekkerScreen.currentName()
				font.family: qfont.bold.name
				font.pixelSize: Math.round(26 * kookwekkerScreen.sc)
				color: "#222222"
			}
		}

		StandardButton {
			width: nameRow.arrowW
			height: Math.round(56 * kookwekkerScreen.sc)
			text: ">"
			onClicked: kookwekkerScreen.changeName(1)
		}

		Rectangle {
			width: nameRow.swatchW
			height: Math.round(56 * kookwekkerScreen.sc)
			radius: Math.round(8 * kookwekkerScreen.sc)
			color: app.palette[kookwekkerScreen.customColorIndex]

			MouseArea {
				anchors.fill: parent
				onClicked: kookwekkerScreen.nextCustomColor()
			}
		}
	}

	StandardButton {
		id: startButton
		x: kookwekkerScreen.rightX
		y: Math.round(420 * kookwekkerScreen.sc)
		width: kookwekkerScreen.rightW
		height: Math.round(70 * kookwekkerScreen.sc)
		text: kookwekkerScreen.full ? "Maximaal " + app.maxTimers + " timers" : "Start " + kookwekkerScreen.currentName() + " (" + kookwekkerScreen.customMinutes + " min)"
		enabled: !kookwekkerScreen.full
		onClicked: app.addTimer(kookwekkerScreen.currentName(), kookwekkerScreen.customMinutes * 60, app.palette[kookwekkerScreen.customColorIndex])
	}
}
