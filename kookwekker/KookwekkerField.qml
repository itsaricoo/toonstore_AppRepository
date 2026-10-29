import QtQuick 1.1

// Aantikbaar tekstveld: toont een titel en de huidige waarde.
// Bij tikken wordt het clicked-signaal afgegeven (de aanroeper opent het toetsenbord).
Rectangle {
	id: field

	property string title: ""
	property string value: ""
	property real sc: 1

	signal clicked()

	radius: Math.round(8 * sc)
	color: "#e8eef2"
	border.width: 1
	border.color: "#c5d0d8"

	Text {
		id: fieldTitle
		x: Math.round(12 * field.sc)
		y: Math.round(4 * field.sc)
		text: field.title
		font.family: qfont.regular.name
		font.pixelSize: Math.round(15 * field.sc)
		color: "#777777"
	}

	Text {
		x: Math.round(12 * field.sc)
		anchors.top: fieldTitle.bottom
		width: field.width - Math.round(24 * field.sc)
		elide: Text.ElideRight
		text: field.value === "" ? "(tik om in te vullen)" : field.value
		font.family: qfont.bold.name
		font.pixelSize: Math.round(22 * field.sc)
		color: field.value === "" ? "#999999" : "#222222"
	}

	MouseArea {
		anchors.fill: parent
		onClicked: field.clicked()
	}
}
