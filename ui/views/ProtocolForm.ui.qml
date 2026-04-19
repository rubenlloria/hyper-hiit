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

    property string currentModuleName: "ENGAGING"
    property string dialMessage: "WAIT"
    property int countdownTimer: -5
    property string unit: "s"
    property int unitType: 0 // 0: SECONDS | 1: REPS [Source 8]
    property real progressValue: 0.0
    property string currentQuantity: "-5s"

    property alias header: header
    property alias mainTimer: mainTimer
    property alias progressDial: progressDial
    property alias nextModuleText: nextModuleText
    property alias nextModuleTitle: nextModuleTitle

    property int activeProtocolId: 0
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
        spacing: 30
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

        NeonText {
            anchors.horizontalCenter: parent.horizontalCenter
            label: protocolName
            size: 35
        }

        NeonTimer {
            id: mainTimer
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

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            NeonText {
                id: currentModuleText
                anchors.horizontalCenter: parent.horizontalCenter
                size: 30
                label: root.currentModuleName
                labelColor: Constants.primaryTextColor
            }

            NeonDial {
                id: progressDial
                anchors.horizontalCenter: parent.horizontalCenter
                // width: 250
                // height: 250
                size: 250
                value: 0
                dialMessage: root.dialMessage
                quantity: root.currentQuantity
                unit: root.unit
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            NeonText {
                id: nextModuleTitle
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Next Module"
                labelColor: Constants.secondaryTextColor
            }
            NeonText {
                id: nextModuleText
                anchors.horizontalCenter: parent.horizontalCenter
                size: 25
                label: "30x Situps"
                labelColor: Constants.primaryTextColor
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
