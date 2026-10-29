import QtQuick 1.1
import qb.components 1.0

Tile {
	id: kookwekkerTile
	onClicked: stage.openFullscreen(app.screenUrl)

	property real sc: width / 200

	Text {
		id: tileLabel
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(parent.height * 0.14)
		width: parent.width - Math.round(16 * kookwekkerTile.sc)
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
		text: app.summaryLabel
		font.family: qfont.regular.name
		font.pixelSize: Math.round(18 * kookwekkerTile.sc)
		color: colors.tileTextColor
	}

	Text {
		id: tileTime
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		anchors.verticalCenterOffset: Math.round(10 * kookwekkerTile.sc)
		text: app.summaryTime
		font.family: qfont.bold.name
		font.pixelSize: Math.round(40 * kookwekkerTile.sc)
		color: app.anyDone ? "#d9534f" : colors.tileTextColor
	}

	// Kleurbalk van de eerstvolgende timer
	Rectangle {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: Math.round(parent.height * 0.1)
		width: Math.round(parent.width * 0.5)
		height: Math.round(6 * kookwekkerTile.sc)
		radius: height / 2
		color: app.summaryColor
		visible: app.timers.count > 0
	}
}
