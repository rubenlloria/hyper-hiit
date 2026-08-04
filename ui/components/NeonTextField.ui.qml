
/****************************************************************************
** File: NeonTextField.ui.qml
** Date: 3/6/2026
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
    width: 350
    height: 60

    property alias text: textInput.text
    property string placeholder: qsTr("ENTER_DATA...")
    property color neonColor: Constants.primaryTextColor
    property string label: qsTr("FIELD_NAME")
    property color labelColor: Constants.primaryTextColor
    property bool showSuccessPulse: false
    property alias textInput: textInput

    // Etiqueta superior (Tipografia Share Tech Mono)
    Text {
        id: fieldLabel
        text: root.label
        color: root.labelColor
        font.family: Constants.techFont.family
        font.pixelSize: 11
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 5
    }

    // Contenidor de l'entrada
    Rectangle {
        id: inputBackground
        width: parent.width
        height: 40
        color: Constants.deepColor
        border.color: root.neonColor
        border.width: 1
        anchors.bottom: parent.bottom

        TextInput {
            id: textInput
            text: ""
            anchors.fill: parent
            anchors.margins: 10
            color: Constants.descriptionColor
            font.family: Constants.techFont.family
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            clip: true

            Text {
                text: root.placeholder
                color: Constants.descriptionColor
                opacity: 0.4
                visible: !textInput.text && !textInput.activeFocus
                font: textInput.font
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Resplendor de la vora
    DropShadow {
        anchors.fill: inputBackground
        source: inputBackground
        color: root.neonColor
        radius: root.showSuccessPulse ? 12 : 8
        samples: 12
        spread: root.showSuccessPulse ? 0.5 : 0.1

        Behavior on radius {
            NumberAnimation {
                duration: 300
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }
    }
}
