import QtQuick
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: iconRoot
    width: 40
    height: 40

    // Properties to customize the icon from outside
    // property alias text: "\ue154"
    property alias glyph: shadowSource.text
    property alias size: shadowSource.font.pixelSize
    property alias color: shadowSource.color
    property alias glowRadius: shadow.radius

    // We need to load the font here too or ensure it's loaded in the parent
    // FontLoader {
    //     id: internalLucideFont
    //     source: "fonts/lucide.ttf"
    // }

    // 1. Shadow source (Invisible)
    Text {
        id: shadowSource
        text: "x"
        font.family: Constants.iconFont.family
        font.pixelSize: 40
        color: Constants.primaryColor
        anchors.centerIn: parent
        visible: false
    }

    // 2. Neon Glow effect
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

    // 3. Main visible icon
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
