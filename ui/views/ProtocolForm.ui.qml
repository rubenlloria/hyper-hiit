import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

// Access to Constants.qml
Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.backgroundColor

    property alias header: header
    property string protocolName: "PROTOCOL_NAME"
    property color themeColor: Constants.primaryColor
    property string rank: "NEWBIE"
    property int calories: 123
    property int moduleCount: 0
    property string duration: "00:00"
    property int personalBest: 0
    property var protocolDataModel: []
    // property alias subsystemRepeater: subsystemRepeater

    // property alias executeButton: executeButton

    // --- VIEW CONTENT ---
    Column {
        width: parent.width
        height: parent.height
        spacing: 40
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
            titlePart1: "sys"
            titlePart2: "protocol"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }

        NeonTimer {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 3
            Rectangle {
                width: 50
                height: 3
                color: Constants.descriptionColor
                opacity: 1
            }
            Rectangle {
                width: 50
                height: 3
                color: Constants.descriptionColor
                opacity: 0.5
            }
            Rectangle {
                width: 50
                height: 3
                color: Constants.descriptionColor
                opacity: 0.5
            }
            Rectangle {
                width: 50
                height: 3
                color: Constants.descriptionColor
                opacity: 0.5
            }
            Rectangle {
                width: 50
                height: 3
                color: Constants.descriptionColor
                opacity: 0.5
            }
            Rectangle {
                width: 50
                height: 3
                color: Constants.descriptionColor
                opacity: 0.5
            }
        }
        ProgressDial {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 250
            height: 250
            value: 1
            moduleName: "Burpees"
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            NeonText {
                label: "Next Module: "
                labelColor: Constants.primaryTextColor
            }
            NeonText {
                label: "30x Situps"
                labelColor: Constants.secondaryTextColor
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            NeonMetadata {
                keyLabel: "HEART_RATE"
                valueLabel: "--"
                unitLabel: "BPM"
                color: Constants.primaryColor
            }
            NeonMetadata {
                keyLabel: "CALORIES"
                valueLabel: "150"
                unitLabel: "kcal"
                color: Constants.primaryColor
            }
        }
    }
}
