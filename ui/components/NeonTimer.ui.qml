
/****************************************************************************
** File: NeonTimer.ui.qml
** Date: 15/4/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/

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
