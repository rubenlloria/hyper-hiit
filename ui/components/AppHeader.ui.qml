import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import ".."

import Qt5Compat.GraphicalEffects

Rectangle {
    id: headerRoot
    width: Constants.width
    height: 100
    color: "#030213"

    // --- VIEWMODEL PROPERTIES ---
    property string titlePart1: "hyper"
    property string titlePart2: "hiit"
    property color cyanNeon: "#00fff9"
    property color fuchsiaNeon: "#bf00ff"
    property string statusLabel: "SYSTEM_ONLINE"
    property string buttonLabel: "ARCHITECT"
    property string buttonGlyph: "\uE154"
    property string buttonLink: "ArchitectForm.qml"
    property alias settingsMouseArea: settingsMouseArea

    // FontLoader {
    //     id: lucideFont
    //     source: "fonts/lucide.ttf"
    //     // font.family: "lucide"
    // }

    // LEFT BRACKET (Top-Left corner facing DOWN)
    Item {
        id: bracketLeft
        width: 15
        height: 15
        anchors.left: parent.left
        anchors.leftMargin: 20
        x: 20
        Rectangle {
            id: bracketLeftV
            width: 2
            height: 15
            color: Constants.cyanNeon
            anchors.top: parent.top
            anchors.left: parent.left
        }
        Rectangle {
            id: bracketLeftH
            width: 15
            height: 2
            color: Constants.cyanNeon
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }

    // RIGHT BRACKET (Top-Right corner facing DOWN)
    Item {
        id: bracketRight
        x: 225
        y: 0
        width: 15
        height: 15
        anchors.right: titleArea.right
        anchors.rightMargin: 20
        Rectangle {
            id: bracketRightV
            width: 2
            height: 15
            color: Constants.cyanNeon
            anchors.top: parent.top
            anchors.right: parent.right
        }
        Rectangle {
            id: bracketRightH
            width: 15
            height: 2
            color: Constants.cyanNeon
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
    }

    // 1. TITLE CONTAINER (Stable Positioning)
    Item {
        id: titleArea
        // We give it a fixed or well-buffered size so the glow doesn't push neighbors
        width: 250
        height: 60
        anchors.left: parent.left
        // anchors.leftMargin: 00
        anchors.verticalCenter: parent.verticalCenter

        // 2. GLOW LAYER (Invisible source)
        Row {
            id: titleTextRowSource
            anchors.centerIn: parent
            spacing: 2
            visible: false // Hidden source for the shadow

            Text {
                text: headerRoot.titlePart1
                font: Constants.titleFont
            }
            Text {
                text: "//"
                font: Constants.titleFont
            }
            Text {
                text: headerRoot.titlePart2
                font: Constants.titleFont
            }
        }

        // 3. THE ACTUAL SHADOW (Anchored to the source)
        DropShadow {
            anchors.fill: titleTextRowSource
            source: titleTextRowSource
            color: Constants.cyanNeon
            radius: 20 // You can increase this now without displacement
            samples: 25
            spread: 0.2
            transparentBorder: true
        }

        // 4. THE VISIBLE CONTENT (Sharp and centered)
        Row {
            id: titleTextRowVisible
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: headerRoot.titlePart1
                color: Constants.cyanNeon // White core for better neon contrast
                font: Constants.titleFont
            }
            Text {
                text: "//"
                color: Constants.fuchsiaNeon
                font: Constants.titleFont

                // // Inner glow for the slashes (Specific)
                // layer.enabled: true
                // layer.effect: DropShadow {
                //     color: Constants.fuchsiaNeon
                //     radius: 3
                //     transparentBorder: true
                // }
            }
            Text {
                text: headerRoot.titlePart2
                color: Constants.cyanNeon
                font: Constants.titleFont
            }
        }
    }

    Item {
        id: settingsActionGroup
        width: settingsIcon.width + neonText.width + neonText.anchors.leftMargin
        height: Math.max(settingsIcon.height, neonText.height)

        // Position the whole group relative to the title
        anchors.left: titleArea.right
        anchors.top: bracketRight.bottom

        // Single MouseArea for both elements
        MouseArea {
            id: settingsMouseArea
            anchors.fill: parent
        }
        // Settings Gear
        NeonIcon {
            id: settingsIcon
            anchors.left: titleArea.right
            anchors.top: bracketRight.bottom

            glyph: headerRoot.buttonGlyph
            color: Constants.fuchsiaNeon
            size: 40
            glowRadius: 15
        }

        NeonText {
            id: neonText
            anchors.left: settingsIcon.right
            anchors.leftMargin: 5
            anchors.verticalCenter: settingsIcon.verticalCenter
            label: headerRoot.buttonLabel
            labelColor: Constants.fuchsiaNeon
            size: 20
        }
    }

    // 2. STATUS INDICATOR (Aligned to the right)
    NeonIndicator {
        // anchors.left: titleArea.right
        // anchors.right: neonText.right
        anchors.right: headerRoot.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        label: "SYSTEM_ONLINE"
        labelColor: Constants.cyanNeon
        ledColor: Constants.cyanNeon
    }

    // 3. DECORATIVE BOTTOM LINE
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Constants.cyanNeon
        opacity: 0.2
    }
}
