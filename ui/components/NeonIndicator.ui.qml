
/****************************************************************************
** File: NeonIndicator.ui.qml
** Date: 9/3/2026
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



/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: root
    width: indicatorRow.implicitWidth
    height: indicatorRow.implicitHeight

    property bool active: false
    property string label_on: "label_on"
    property string label_off: "label_off"
    property alias labelColor: indicatorLabel.color

    Row {
        id: indicatorRow
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter

        Item {
            width: 20
            height: 20
            Rectangle {
                id: indicatorLed
                width: 10
                height: 10
                radius: 5
                color: root.active ? Constants.onColor : Constants.offColor
                anchors.centerIn: parent
            }
            DropShadow {
                id: ledGlow
                anchors.fill: indicatorLed
                source: indicatorLed
                color: indicatorLed.color
                radius: 12
                samples: 25
                spread: 0.3
                transparentBorder: true
            }
        }

        Text {
            id: indicatorLabel
            text: root.active ? root.label_on : root.label_off
            color: Constants.primaryTextColor
            font.family: Constants.techFont.family
            font.letterSpacing: 1
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
        }
    }
}
