
/****************************************************************************
** File: ConfigForm.ui.qml
** Date: 3/6/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
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
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import ".."
import "../components"


/*
   Main Configuration Form
   This file organizes user settings into industrial-style containers
*/
Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.backgroundColor

    property alias header: header
    property alias userNameField: userNameField
    property alias weightField: weightField
    property alias heightField: heightField
    property alias sexSelector: sexSelector
    property alias ageField: ageField
    property alias rankSelector: rankSelector
    property alias themeSelector: themeSelector
    property alias scanlineSwitch: scanlineSwitch
    property alias audioSwitch: audioSwitch

    property alias architectButton: architectButton
    property alias architectMouseArea: architectMouseArea
    property alias restoreDBButton: restoreDBButton

    ColumnLayout {
        width: parent.width
        height: parent.height

        // spacing: 10
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
            titlePart1: "core"
            titlePart2: "config"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }

        Flickable {
            id: configScroll
            // anchors.fill: parent
            // anchors.topMargin: 100
            // contentHeight: contentLayout.height + 100
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            contentHeight: mainLayout.implicitHeight

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            Rectangle {
                color: Constants.surfaceColor
                anchors.fill: parent
                Column {
                    id: mainLayout
                    width: 380
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    spacing: 30

                    // 1. SECTION: USER_BIO_DATA
                    Column {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "USER_BIO_DATA"
                            color: Constants.primaryTextColor
                            font.family: Constants.mainFont.family
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Rectangle {
                            id: bioContainer
                            width: parent.width
                            height: 560
                            color: Constants.backgroundColor
                            border.color: Constants.primaryTextColor
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 18

                                NeonTextField {
                                    id: userNameField
                                    width: 350
                                    label: "USER_NAME"
                                    placeholder: "AGENT_PRIME"
                                    text: sessionManager.userName
                                }

                                NeonSpinBox {
                                    id: weightField
                                    width: 350
                                    label: "BIOMASS_KG"
                                    value: sessionManager.userWeight
                                    suffix: "KG"
                                }

                                NeonSpinBox {
                                    id: heightField
                                    width: 350
                                    label: "HEIGHT_CM"
                                    value: sessionManager.userHeight
                                    suffix: "CM"
                                }

                                NeonSelector {
                                    id: sexSelector
                                    width: 350
                                    label: "SEX"
                                    horizontal: true
                                    option1Label: "WOMAN"
                                    option2Label: "REPLICANT"
                                    option3Label: "MAN"
                                    selectedIndex: sessionManager.userSex
                                }

                                NeonSpinBox {
                                    id: ageField
                                    width: 350
                                    label: "AGE"
                                    value: sessionManager.userAge
                                }

                                NeonSelector {
                                    id: rankSelector
                                    width: 350
                                    label: "RANK_LEVEL"
                                    horizontal: true
                                    neonColor: Constants.primaryTextColor
                                    option1Label: "NEWBIE"
                                    option2Label: "ADVANCED"
                                    option3Label: "ROOT"
                                    selectedIndex: sessionManager.userRank
                                }
                            }
                        }
                    }

                    // 2. SECTION: SYSTEM_PARAMETERS
                    Column {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "SYSTEM_PARAMETERS"
                            color: Constants.secondaryTextColor
                            font.family: Constants.mainFont.family
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Rectangle {
                            id: systemContainer
                            width: parent.width
                            height: 400
                            color: Constants.backgroundColor
                            border.color: Constants.secondaryTextColor
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 20

                                NeonSwitch {
                                    id: scanlineSwitch
                                    width: 350
                                    title: "SCANLINE_RENDER"
                                    description: "Enable/Disable horizontal terminal lines"
                                    checked: systemManager.systemScanline
                                }

                                NeonSwitch {
                                    id: audioSwitch
                                    width: 350
                                    title: "AUDIO_UPLINK"
                                    description: "Link to Audio Uplink module"
                                    checked: systemManager.systemAudio
                                }

                                NeonSelector {
                                    id: themeSelector
                                    width: 350
                                    label: "NEON_THEME"
                                    horizontal: false
                                    neonColor: Constants.secondaryTextColor
                                    option1Label: "CYBERPUNK"
                                    option2Label: "GHOST_SHELL"
                                    option3Label: "LIGHT_REPORT"
                                    selectedIndex: systemManager.systemTheme
                                }
                            }
                        }
                    }

                    // 3. SECTION: ROOT_ACCESS
                    Column {
                        id: rootCol
                        width: parent.width
                        height: 250
                        spacing: 12
                        property color sectionColor: Constants.rootColor

                        Text {
                            text: "ROOT_ACCESS"
                            color: rootCol.sectionColor
                            font.family: Constants.mainFont.family
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Column {
                            width: parent.width
                            spacing: 20
                            Rectangle {
                                id: architectButton
                                width: parent.width
                                height: 160
                                color: Constants.backgroundColor
                                border.color: rootCol.sectionColor
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    NeonText {
                                        label: " ACCESS_ARCHITECT_MODE "
                                        labelColor: rootCol.sectionColor
                                        cornerWidth: 2
                                        font.family: Constants.mainFont.family
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: "PROTOCOL_DESIGN_SUITE // DIRECTIVE_EDITOR"
                                        color: Constants.primaryTextColor
                                        font.family: "Share Tech Mono"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                DropShadow {
                                    anchors.fill: parent
                                    source: parent
                                    color: rootCol.sectionColor
                                    radius: 20
                                    samples: 25
                                    opacity: 0.3
                                }

                                MouseArea {
                                    id: architectMouseArea
                                    anchors.fill: parent
                                }
                            }

                            NeonButton {
                                id: restoreDBButton
                                width: parent.width * 0.9
                                label: "RESTORE_DB"
                                Layout.alignment: Qt.AlignTop
                                themeColor: Constants.rootColor
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Column {
                        // Safe area buffer to prevent content occlusion by fixed footer and audio player
                        height: 10 + mainWindow.footer.height + (systemManager.systemAudio ? mainWindow.player.height: 0)
                        width: 1
                    }
                }
            }
        }
    }
}
