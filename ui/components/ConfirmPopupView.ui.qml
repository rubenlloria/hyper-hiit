
/****************************************************************************
** File: ConfirmPopupView.ui.qml
** Date: 9/7/2026
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
import QtQuick.Layouts
import QtQuick.Controls
import ".."
import "../components"

import Qt5Compat.GraphicalEffects


/*
   ConfirmPopupView.ui.qml
   Declarative UI for critical task confirmation (v0.9.2).
   Strictly declarative for Qt Design Studio compatibility.
*/
Item {
    id: root
    width: 280
    height: mainLayout.implicitHeight + 50
    anchors.centerIn: parent

    property alias messageText: confirmationMessage.text
    property string targetText: "TARGET MODULE"
    property alias confirmButton: executeButton
    property alias cancelButton: abortButton
    property bool enableCancelButton: true

    Rectangle {
        id: viewGlow
        anchors.fill: view
        color: Constants.rootColor
    }

    DropShadow {
        id: borderGlow
        anchors.fill: viewGlow
        source: viewGlow
        color: Constants.rootColor
        radius: 30
        samples: 15
        spread: 0.3
        transparentBorder: true
        opacity: 0.5
    }

    Rectangle {
        id: mainFrame
        anchors.fill: parent
        color: Constants.backgroundColor
        border.color: Constants.rootColor
        border.width: 1

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 15
            spacing: 20

            // TITLE HEADER
            Rectangle {
                id: headerRect
                color: "transparent"
                border.color: Constants.rootColor
                width: headerLayout.implicitWidth
                height: headerLayout.implicitHeight
                Layout.alignment: Qt.AlignHCenter
                RowLayout {
                    id: headerLayout
                    spacing: 5
                    NeonIcon {
                        glyph: Constants.alertIcon
                        size: 18
                        color: Constants.rootColor
                    }
                    NeonText {
                        label: qsTr("SYSTEM_WARNING")
                        labelColor: Constants.rootColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 12
                        font.letterSpacing: 2
                        font.bold: true
                        cornerWidth: 2
                    }
                    Item {
                        width: 10
                        height: 18
                    }
                }
            }

            // 2. MESSAGE BODY AREA
            Text {
                id: targetMessage
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("TARGET: ") + root.targetText
                color: Constants.primaryTextColor
                font.family: Constants.mainFont.family
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // 2. MESSAGE BODY AREA
            Text {
                id: confirmationMessage
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("ARE YOU SURE YOU WANT TO EXECUTE THIS DESTRUCTIVE OPERATION?")
                color: Constants.descriptionColor
                font.family: Constants.techFont.family
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                lineHeight: 1.4
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // 3. ACTION CONTROLS
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                NeonButton {
                    id: abortButton
                    label: qsTr("CANCEL")
                    themeColor: Constants.secondaryColor
                    iconGlyph: Constants.cancelIcon
                    visible: enableCancelButton
                }

                NeonButton {
                    id: executeButton
                    label: qsTr("CONFIRM")
                    themeColor: Constants.rootColor
                    iconGlyph: Constants.confirmIcon
                }
            }
        }
    }
}
