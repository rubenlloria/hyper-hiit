
/****************************************************************************
** File: ConfigForm.ui.qml
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
    property alias exitConfirmSwitch: exitConfirmSwitch
    property alias languageSwitch: languageSwitch

    property alias architectButton: architectButton
    property alias architectMouseArea: architectMouseArea
    property alias restoreDBButton: restoreDBButton
    property alias githubArea: githubArea

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
            buttonLabel: qsTr("BACK     ")
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
                            text: qsTr("USER_BIO_DATA")
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
                                    label: qsTr("USER_NAME")
                                    placeholder: "AGENT"
                                    text: sessionManager.userName
                                }

                                NeonSpinBox {
                                    id: weightField
                                    width: 350
                                    label: qsTr("BIOMASS_KG")
                                    value: sessionManager.userWeight
                                    suffix: "KG"
                                }

                                NeonSpinBox {
                                    id: heightField
                                    width: 350
                                    label: qsTr("HEIGHT_CM")
                                    value: sessionManager.userHeight
                                    suffix: "CM"
                                }

                                NeonSelector {
                                    id: sexSelector
                                    width: 350
                                    label: qsTr("SEX")
                                    horizontal: true
                                    option1Label: qsTr("WOMAN")
                                    option2Label: qsTr("REPLICANT")
                                    option3Label: qsTr("MAN")
                                    selectedIndex: sessionManager.userSex
                                }

                                NeonSpinBox {
                                    id: ageField
                                    width: 350
                                    label: qsTr("AGE")
                                    value: sessionManager.userAge
                                }

                                NeonSelector {
                                    id: rankSelector
                                    width: 350
                                    label: qsTr("RANK_LEVEL")
                                    horizontal: true
                                    neonColor: Constants.primaryTextColor
                                    option1Label: qsTr("NEWBIE")
                                    option2Label: qsTr("ADVANCED")
                                    option3Label: qsTr("ROOT")
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
                            text: qsTr("SYSTEM_PARAMETERS")
                            color: Constants.secondaryTextColor
                            font.family: Constants.mainFont.family
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Rectangle {
                            id: systemContainer
                            width: parent.width
                            height: 600
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
                                    title: qsTr("SCANLINE_RENDER")
                                    description: qsTr("Enable/Disable horizontal terminal lines.")
                                    checked: systemManager.systemScanline
                                }

                                NeonSwitch {
                                    id: audioSwitch
                                    width: 350
                                    title: qsTr("AUDIO_UPLINK")
                                    description: qsTr("Link to Audio Uplink module.")
                                    checked: systemManager.systemAudio
                                }

                                NeonSwitch {
                                    id: exitConfirmSwitch
                                    width: 350
                                    title: qsTr("SHUTDOWN_CONFIRM")
                                    description: qsTr("Request authorization before exit.")
                                    checked: systemManager.exitConfirm
                                }

                                NeonSwitch {
                                    id: languageSwitch
                                    width: 350
                                    title: qsTr("SYSTEM_LANGUAGE")
                                    description: qsTr("Use system configured language.")
                                    checked: systemManager.systemLanguage
                                }

                                NeonSelector {
                                    id: themeSelector
                                    width: 350
                                    label: qsTr("NEON_THEME")
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
                            text: qsTr("ROOT_ACCESS")
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
                                        label: qsTr(" ACCESS_ARCHITECT_MODE ")
                                        labelColor: rootCol.sectionColor
                                        cornerWidth: 2
                                        font.family: Constants.mainFont.family
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: qsTr("PROTOCOL_DESIGN_SUITE // DIRECTIVE_EDITOR")
                                        color: Constants.primaryTextColor
                                        font.family: Constants.techFont.family
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
                                label: qsTr("RESTORE_DB")
                                Layout.alignment: Qt.AlignTop
                                themeColor: Constants.rootColor
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    NeonTitle {
                        width: parent.width
                        label: "About"
                        titleColor: Constants.descriptionColor
                    }

                    Column {
                        width: parent.width * .9
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            id: aboutText
                            text: qsTr("Terminal source and documentation available at:")
                            color: Constants.descriptionColor
                            font.pixelSize: 16
                            font.family: Constants.techFont.family
                            horizontalAlignment: Text.AlignLeft
                            width: parent.width
                            wrapMode: Text.WordWrap
                            opacity: 0.8
                        }
                        Text {
                            id: githubLinkText
                            text: "github.com/rubenlloria/hyper-hiit"
                            color: Constants.primaryTextColor
                            font.pixelSize: 16
                            font.family: Constants.techFont.family
                            horizontalAlignment: Text.AlignLeft
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.underline: true

                            // opacity: 0.8
                            MouseArea {
                                id: githubArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                // La lògica d'obertura la posarem al fitxer .qml companion
                            }
                        }
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
}
