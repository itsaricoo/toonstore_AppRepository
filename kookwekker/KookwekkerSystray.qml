import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: kookwekkerSystrayIcon

	// Alleen zichtbaar zolang er een timer loopt of afgelopen is
	visible: app.timers.count > 0
	posIndex: 9000
	property string objectName: "kookwekkerSystrayIcon"

	onClicked: stage.openFullscreen(app.screenUrl)

	Image {
		id: trayImage
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 2
		source: app.anyDone ? "drawables/kookwekker-tray-alarm.png" : "drawables/kookwekker-tray.png"
	}

	Text {
		id: trayLabel
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: trayImage.bottom
		text: app.trayText
		font.family: qfont.bold.name
		font.pixelSize: 12
		color: app.anyDone ? "#d9534f" : app.summaryColor
	}
}
