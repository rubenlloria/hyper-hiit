

/****************************************************************************
** File: BriefingForm.ui.qml
** Date: 13/4/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License version 2 as
** published by the Free Software Foundation.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
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

    // --- VIEW CONTENT ---
    Column {
        width: parent.width
        height: parent.height
        spacing: 10
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
            titlePart1: "sys"
            titlePart2: "briefing"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }

        Flickable {
            id: briefingScroll
            anchors.fill: parent
            anchors.topMargin: 100 // Leave space for AppHeader
            contentWidth: parent.width
            contentHeight: mainLayout.height - 20
            clip: true // Critical: prevents content from bleeding outside the shard [Source 95]
            boundsBehavior: Flickable.StopAtBounds

            // Custom Neon Scrollbar (v0.3 Fuchsia Aesthetic)
            ScrollBar.vertical: ScrollBar {
                parent: root
                anchors.right: parent.right
                anchors.rightMargin: 2
                policy: ScrollBar.AlwaysOn
                width: 0

                contentItem: Rectangle {
                    implicitWidth: 4
                    color: Constants.fuchsiaNeon // Fuchsia scrollbar as per Roadmap [Source 34, 188]
                    radius: 2
                }
            }

            Column {
                id: mainLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                leftPadding: 20
                rightPadding: 20
                topPadding: 10
                width: parent.width
                // anchors.fill: parent
                // anchors.top: header.bottom
                // anchors.left: parent.left
                // anchors.right: parent.right
                // anchors.bottom: parent.bottom
                // anchors.margins: 20
                spacing: 25

                // 1. Mission Title Section
                Column {
                    spacing: 5
                    Text {
                        text: "BRIEFING:"
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    Text {
                        text: "PROTOCOL_NAME"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 28
                        font.bold: true
                    }
                }

                Grid {
                    id: metadataGrid

                    // property real widthPercent: 0.47
                    width: parent.width - 40
                    columns: 2
                    spacing: 15
                    // anchors.leftMargin: 10
                    NeonMetadata {
                        keyLabel: "RANK"
                        valueLabel: "ADVANCED"
                        width: parent.width * 0.48
                    }
                    NeonMetadata {
                        keyLabel: "EST_CALORIES"
                        valueLabel: "000k"
                        width: parent.width * 0.48
                    }
                    NeonMetadata {
                        keyLabel: "MODULE_COUNT"
                        valueLabel: "0"
                        width: parent.width * 0.48
                    }
                    NeonMetadata {
                        keyLabel: "DURATION"
                        valueLabel: "00:00"
                        width: parent.width * 0.48
                    }
                }

                Column {
                    spacing: 5
                    width: parent.width - 40
                    Text {
                        text: "SUBSYSTEM 1:"
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    Text {
                        text: "40x Burpees"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "40x Situps"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "40x Jumping Jacks"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column {
                    spacing: 5
                    width: parent.width - 40
                    Text {
                        text: "SUBSYSTEM 2:"
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    Text {
                        text: "30x Burpees"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "30x Situps"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "30x Jumping Jacks"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column {
                    spacing: 5
                    width: parent.width - 40
                    Text {
                        text: "SUBSYSTEM 3:"
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    Text {
                        text: "20x Burpees"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "20x Situps"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "20x Jumping Jacks"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column {
                    spacing: 5
                    width: parent.width - 40
                    Text {
                        text: "SUBSYSTEM 4:"
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    Text {
                        text: "10x Burpees"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "10x Situps"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "10x Jumping Jacks"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column {
                    spacing: 5
                    width: parent.width - 40
                    Text {
                        text: "SUBSYSTEM 5:"
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    Text {
                        text: "5x Burpees"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "5x Situps"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "5x Jumping Jacks"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column {
                    // TODO: Improve spacer to prevent footer overlap last module
                    height: 30
                    width: 20
                }
            }
        }
    }
}
