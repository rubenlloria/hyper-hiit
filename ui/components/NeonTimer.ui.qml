import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import ".."

Column {
    property alias label: label.text
    property alias labelColor: label.color
    property alias size: label.font.pixelSize
    property alias font: label.font
    property alias centLabel: centLabel.text

    Rectangle {
        color: Constants.secondaryColor
        height: 2
        width: timerRow.width
        opacity: 0.4
    }
    Row {
        id: timerRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        Item {
            id: labelItem
            width: label.implicitWidth
            height: label.implicitHeight

            Text {
                id: label
                text: "00:00"
                color: Constants.primaryTextColor
                font.family: Constants.mainMonoFont.family
                font.pixelSize: 64
                font.letterSpacing: 1
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
            }
            DropShadow {
                id: labelGlow
                anchors.fill: label
                source: label
                color: Constants.secondaryTextColor
                radius: 64
                samples: 15
                spread: 0.2
                transparentBorder: true
            }
        }
        Text {
            // We take the last 3 characters ":CC" (including the separator)
            // or just the numbers. Let's use "." + last 2 digits.
            // text: "." + myChrono.timeText.substring(6, 8)
            id: centLabel
            text: ".00"
            color: Constants.primaryTextColor
            font.pixelSize: 32 // Half the size of the main clock
            font.family: Constants.mainMonoFont.family
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 7 // Adjusted for Orbitron's baseline
            opacity: 0.8
        }
    }
    Rectangle {
        color: Constants.secondaryColor
        height: 2
        width: timerRow.width
        opacity: 0.4
    }
}
