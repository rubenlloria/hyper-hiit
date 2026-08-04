

/****************************************************************************
** File: BriefingForm.ui.qml
** Date: 13/4/2026
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
import QtQuick.Effects
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

// Access to Constants.qml
Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.surfaceColor

    property alias header: header
    property string protocolName: "PROTOCOL_NAME"
    property color themeColor: Constants.primaryColor
    property string rank: "NEWBIE"
    property int estimatedKcal: 123
    property int moduleCount: 0
    property string duration: "00:00"
    property int personalBest: 0
    property var protocolDataModel: []
    property alias subsystemRepeater: subsystemRepeater
    property alias executeButton: executeButton

    // --- VIEW CONTENT ---
    ColumnLayout {
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
            buttonLabel: qsTr("BACK     ")
            buttonGlyph: Constants.backIcon
        }

        Flickable {
            id: briefingScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            contentHeight: mainLayout.implicitHeight - 20
            clip: true // Critical: prevents content from bleeding outside the shard [Source 95]
            boundsBehavior: Flickable.StopAtBounds

            // Custom Neon Scrollbar (v0.3 Fuchsia Aesthetic)
            ScrollBar.vertical: ScrollBar {
                parent: root
                policy: ScrollBar.AlwaysOn
                width: 0

                contentItem: Rectangle {
                    implicitWidth: 4
                    color: Constants.primaryColor
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
                spacing: 25

                // 1. Mission Title Section
                Column {
                    spacing: 5
                    Text {
                        text: qsTr("BRIEFING:")
                        color: Constants.primaryTextColor
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                    }
                    NeonText {
                        id: protocolTitle
                        label: root.protocolName
                        labelColor: root.themeColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 28
                        font.bold: true
                        cornerWidth: 1
                    }
                }

                Grid {
                    id: metadataGrid

                    // property real widthPercent: 0.47
                    width: parent.width - 40
                    columns: 2
                    spacing: 15
                    NeonMetadata {
                        keyLabel: qsTr("RANK")
                        valueLabel: root.rank
                        width: parent.width * 0.48
                    }
                    NeonMetadata {
                        keyLabel: qsTr("MODULE_COUNT")
                        valueLabel: root.moduleCount
                        width: parent.width * 0.48
                    }
                    NeonMetadata {
                        keyLabel: qsTr("DURATION")
                        valueLabel: root.duration
                        unitLabel: "mm:ss"
                        width: parent.width * 0.48
                    }
                    NeonMetadata {
                        keyLabel: qsTr("EST_CALORIES")
                        valueLabel: root.estimatedKcal
                        unitLabel: "kcal"
                        width: parent.width * 0.48
                    }
                }

                Repeater {
                    id: subsystemRepeater
                    model: root.protocolDataModel // Structured array from C++ backend

                    NeonSubsystem {
                        subsystemId: modelData.subsystem_id
                        color: root.themeColor
                        // Injecting the nested module array for this specific subsystem
                        modulesModel: modelData.modules
                        width: metadataGrid.width
                    }
                }

                NeonButton {
                    id: executeButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: qsTr("EXECUTE")
                    iconGlyph: Constants.playIcon
                    themeColor: Constants.descriptionColor
                }

                Column {
                    // Safe area buffer to prevent content occlusion by fixed footer and audio player
                    height: 10 + mainWindow.footer.height
                            + (systemManager.systemAudio ? mainWindow.player.height : 0)
                    width: 1
                }
            }
        }
    }
}
