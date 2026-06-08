
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
    color: Constants.darkNeon // Color de fondo del theme.css

    property alias header: header
    property alias userNameField: userNameField
    property alias biomassField: biomassField
    property alias heightField: heightField
    property alias sexSelector: sexSelector
    property alias ageField: ageField
    property alias rankSelector: rankSelector
    property alias themeSelector: themeSelector
    property alias scanlineSwitch: scanlineSwitch
    property alias audioSwitch: audioSwitch

    property alias restoreDBButton: restoreDBButton
    property alias summaryButton: summaryButton

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
                color: Constants.darkNeon
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
                            color: Constants.darkNeon
                            border.color: Constants.primaryTextColor
                            border.width: 1

                            // TODO: add glow
                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 18

                                NeonTextField {
                                    id: userNameField
                                    width: 350
                                    label: "USER_NAME"
                                    placeholder: "AGENT_PRIME"
                                }

                                NeonSpinBox {
                                    id: biomassField
                                    width: 350
                                    label: "BIOMASS_KG"
                                    value: 75
                                }

                                NeonSpinBox {
                                    id: heightField
                                    width: 350
                                    label: "HEIGHT_CM"
                                    value: 175
                                    suffix: "CM"
                                }

                                NeonSelector {
                                    id: sexSelector
                                    width: 350
                                    label: "SEX"
                                    horizontal: true
                                    option1Label: "MAN"
                                    option2Label: "WOMAN"
                                    option3Label: "REPLICANT"
                                    selectedIndex: 2
                                }

                                NeonSpinBox {
                                    id: ageField
                                    width: 350
                                    label: "AGE"
                                    value: 28
                                    suffix: ""
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
                            height: 470
                            color: Constants.darkNeon
                            border.color: Constants.secondaryTextColor
                            border.width: 1

                            // TODO: add glow
                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 20

                                NeonSwitch {
                                    id: scanlineSwitch
                                    width: 350
                                    title: "SCANLINE_RENDER"
                                    description: "Enable/Disable horizontal terminal lines"
                                }

                                NeonSwitch {
                                    id: audioSwitch
                                    width: 350
                                    title: "AUDIO_AUTO_SYNC"
                                    description: "Link to Audio Uplink module"
                                    checked: true
                                }

                                NeonSelector {
                                    id: themeSelector
                                    width: 350
                                    label: "NEON_THEME"
                                    horizontal: false
                                    neonColor: Constants.secondaryTextColor
                                    option1Label: "DEFAULT_CYAN"
                                    option2Label: "MAGENTA_CORE"
                                    option3Label: "AMBER_NET"
                                }

                                NeonButton {
                                    id: summaryButton
                                    label: "Summary"
                                    Layout.alignment: Qt.AlignTop
                                    // Layout.topMargin: Constants.px(20)
                                }
                            }
                        }
                    }

                    // 3. SECTION: ROOT_ACCESS
                    Column {
                        id: rootCol
                        width: parent.width
                        spacing: 12
                        property color sectionColor: Constants.redNeon

                        Text {
                            text: "ROOT_ACCESS"
                            color: rootCol.sectionColor
                            font.family: Constants.mainFont.family
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Rectangle {
                            id: rootContainer
                            width: parent.width
                            height: 160
                            color: Constants.blackNeon
                            border.color: rootCol.sectionColor
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "[ ACCESS_ARCHITECT_MODE ]"
                                    color: rootCol.sectionColor
                                    font.family: Constants.mainFont.family
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "PROTOCOL_DESIGN_SUITE // DIRECTIVE_EDITOR"
                                    color: Constants.primaryTextColor
                                    font.family: "Share Tech Mono"
                                    font.pixelSize: 8
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            DropShadow {
                                anchors.fill: parent
                                source: parent
                                color: rootCol.sectionColor
                                radius: 20
                                samples: 25
                                opacity: 0.4
                            }
                        }
                        Column {
                            // DELETEME
                            height: 10
                            width: 20
                        }

                        NeonButton {
                            id: restoreDBButton
                            label: "RESTORE_DB"
                            Layout.alignment: Qt.AlignTop
                            themeColor: Constants.redNeon
                            // Layout.topMargin: Constants.px(20)
                        }
                    }
                    Column {
                        // TODO: Improve spacer to prevent footer overlap last module
                        height: Constants.bottomMargin
                        width: 20
                    }
                }
            }
        }
    }
}
