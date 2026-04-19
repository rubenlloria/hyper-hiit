import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import ".."

Column {
    id: root
    property alias minSec: minSec.text
    property alias minSecColor: minSec.color
    property alias size: minSec.font.pixelSize
    property alias font: minSec.font
    property alias cents: cents.text

    width: timerRow.implicitWidth
    height: timerRow.implicitHeight + 4

    Rectangle {
        color: Constants.secondaryColor
        height: 2
        width: timerRow.width
        opacity: 0.4
    }
    Row {
        id: timerRow
        // anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        Item {
            id: minSecItem
            width: minSec.implicitWidth
            height: minSec.implicitHeight

            Text {
                id: minSec
                text: "00:00"
                color: Constants.primaryTextColor
                font.family: Constants.mainMonoFont.family
                font.pixelSize: 64
                font.letterSpacing: 1
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
            }
            DropShadow {
                id: minSecGlow
                anchors.fill: minSec
                source: minSec
                color: Constants.secondaryTextColor
                radius: 64
                samples: 15
                spread: 0.2
                transparentBorder: true
            }
        }
        Item {
            id: centsItem
            width: cents.implicitWidth
            height: cents.implicitHeight
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 7 // Adjusted for Orbitron's baseline
            Text {
                // We take the last 3 characters ":CC" (including the separator)
                // or just the numbers. Let's use "." + last 2 digits.
                // text: "." + myChrono.timeText.substring(6, 8)
                id: cents
                text: ".00"
                color: Constants.primaryTextColor
                font.pixelSize: 32 // Half the size of the main clock
                font.family: Constants.mainMonoFont.family
                opacity: 0.8
                renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
            }
            DropShadow {
                id: cestsGlow
                anchors.fill: cents
                source: cents
                color: Constants.secondaryTextColor
                radius: 32
                samples: 15
                spread: 0.2
                transparentBorder: true
            }
        }
    }
    Rectangle {
        color: Constants.secondaryColor
        height: 2
        width: timerRow.width
        opacity: 0.4
    }
}
