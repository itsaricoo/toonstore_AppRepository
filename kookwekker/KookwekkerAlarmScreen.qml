import QtQuick 1.1
import qb.components 1.0

Screen {
	id: kookwekkerAlarmScreen
	screenTitle: "Kookwekker"

	property bool flashOn: true
	property real sc: width / 1024

	onShown: {
		flashOn = true;
		flashTimer.start();
		app.startSound();
	}

	onHidden: {
		flashTimer.stop();
		app.alarmClosed();
	}

	Timer {
		id: flashTimer
		interval: 600
		repeat: true
		running: false
		onTriggered: kookwekkerAlarmScreen.flashOn = !kookwekkerAlarmScreen.flashOn
	}

	Rectangle {
		anchors.fill: parent
		color: kookwekkerAlarmScreen.flashOn ? "#d9534f" : "#f0ad4e"
	}

	Text {
		id: bigText
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(90 * kookwekkerAlarmScreen.sc)
		text: "Klaar!"
		font.family: qfont.bold.name
		font.pixelSize: Math.round(120 * kookwekkerAlarmScreen.sc)
		color: "#ffffff"
	}

	Text {
		id: whoText
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(250 * kookwekkerAlarmScreen.sc)
		width: parent.width - Math.round(80 * kookwekkerAlarmScreen.sc)
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		text: app.doneText
		font.family: qfont.regular.name
		font.pixelSize: Math.round(44 * kookwekkerAlarmScreen.sc)
		color: "#ffffff"
	}

	StandardButton {
		id: stopAll
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(380 * kookwekkerAlarmScreen.sc)
		width: Math.round(360 * kookwekkerAlarmScreen.sc)
		height: Math.round(90 * kookwekkerAlarmScreen.sc)
		text: "Stop"
		onClicked: {
			app.dismissDone();
			stage.navigateBack();
		}
	}
}
