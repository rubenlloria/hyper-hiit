import QtQuick
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: iconRoot
    width: 40
    height: 40

    property alias glyph: shadowSource.text
    property alias size: shadowSource.font.pixelSize
    property alias color: shadowSource.color
    property alias glowRadius: shadow.radius

    // Shadow source (Invisible)
    Text {
        id: shadowSource
        text: "x"
        font.family: Constants.iconFont.family
        font.pixelSize: 40
        color: Constants.primaryColor
        anchors.centerIn: parent
        visible: false
    }

    // Neon Glow effect
    DropShadow {
        id: shadow
        anchors.fill: shadowSource
        source: shadowSource
        color: shadowSource.color
        radius: 20
        samples: 25
        spread: 0.2
        transparentBorder: true
        opacity: 0.8
    }

    // Main visible icon
    Text {
        id: mainIconText
        text: shadowSource.text
        font: shadowSource.font
        color: shadowSource.color
        anchors.centerIn: parent
        visible: true
        renderType: Text.QtRendering
    }
}
