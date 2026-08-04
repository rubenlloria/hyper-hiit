
/****************************************************************************
** File: NeonText.ui.qml
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
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: root
    width: label.implicitWidth
    height: label.implicitHeight

    property alias label: label.text
    property alias labelColor: label.color
    property alias size: label.font.pixelSize
    property alias font: label.font
    property int cornerSize: label.font.pixelSize / 2 - 1
    property int cornerWidth: 0

    Text {
        id: label
        text: "LABEL"
        color: Constants.secondaryTextColor
        font.family: Constants.techFont.family
        font.pixelSize: 20
        font.letterSpacing: 1
        anchors.verticalCenter: parent.verticalCenter
        renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
    }
    DropShadow {
        id: labelGlow
        anchors.fill: label
        source: label
        color: label.color
        radius: 20
        samples: 25
        spread: 0.3
        transparentBorder: true
    }
    Item {
        id: techCorners
        anchors.fill: label
        // anchors.topMargin: -spacing
        // anchors.bottomMargin: -spacing
        anchors.leftMargin: -(label.font.pixelSize / 3)
        anchors.rightMargin: anchors.leftMargin
        opacity: 0.7
        // Top-Left
        Rectangle {
            width: root.cornerSize
            height: root.cornerWidth
            color: label.color
            x: -root.cornerWidth
            y: -root.cornerWidth
        }
        Rectangle {
            width: root.cornerWidth
            height: root.cornerSize
            color: label.color
            x: -root.cornerWidth
            y: -root.cornerWidth
        }
        // Top-Right
        Rectangle {
            width: root.cornerSize
            height: root.cornerWidth
            color: label.color
            // x: label.width - 8
            anchors.right: parent.right
            anchors.rightMargin: -root.cornerWidth
            y: -root.cornerWidth
        }
        Rectangle {
            width: root.cornerWidth
            height: root.cornerSize
            color: label.color
            anchors.left: parent.right
            y: -root.cornerWidth
        }
        // Bottom-Left
        Rectangle {
            width: root.cornerSize
            height: root.cornerWidth
            color: label.color
            x: -root.cornerWidth
            anchors.top: parent.bottom
        }
        Rectangle {
            width: root.cornerWidth
            height: root.cornerSize
            color: label.color
            x: -root.cornerWidth
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -root.cornerWidth
        }
        // Bottom-Right
        Rectangle {
            width: root.cornerSize
            height: root.cornerWidth
            color: label.color
            anchors.right: parent.right
            anchors.rightMargin: -root.cornerWidth
            anchors.top: parent.bottom
        }
        Rectangle {
            width: root.cornerWidth
            height: root.cornerSize
            color: label.color
            anchors.left: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -root.cornerWidth
        }
    }
}
