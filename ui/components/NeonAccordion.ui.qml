
/****************************************************************************
** File: NeonAcordion.ui.qml
** Date: 2/2/2026
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
import QtQuick.Layouts

import ".."


/*
    NeonAccordion Component: Manages the items selection interface.
*/
Item {
    id: root
    width: 380
    // height: isOpen ? layoutContainer.height : 100
    height: isOpen ? layoutContainer.implicitHeight : (mainHeader.height + sectionLabel.height)

    // Public properties for state and theme
    property bool isOpen: false
    property string title: qsTr("ACTIVE_DIRECTIVE")
    property color activeThemeColor: Constants.primaryColor
    property string activeItemName: "STRENGTH_MATRIX"
    property string activeIconGlyph: Constants.zapIcon
    property string activeItemDesc: "Muscular fortification sequence"
    property bool showSwitchLabel: true

    // Exposed alias for interaction
    property alias dropdownList: dropdownList // Afegeix això! [2]
    property alias headerMouseArea: interactionToggle

    Column {
        id: layoutContainer
        width: parent.width
        // anchors.fill: parent
        spacing: 0

        // Section label (always cyan per source screenshot [5])
        Text {
            id: sectionLabel
            text: root.title
            color: Constants.primaryTextColor
            font.family: Constants.techFont.family
            font.pixelSize: 12
            bottomPadding: 8
            topPadding: 8
        }

        // Active Item Header [6]
        Rectangle {
            id: mainHeader
            width: parent.width
            height: 70
            color: Constants.deepColor
            opacity: 0.9
            border.color: root.activeThemeColor
            border.width: 1

            // MouseArea for toggling the accordion
            MouseArea {
                id: interactionToggle
                anchors.fill: parent
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Icon Background with low opacity [3]
                Rectangle {
                    id: iconBackground
                    width: 40
                    height: 40
                    color: "transparent"

                    // Icon placeholder
                    NeonIcon {
                        id: activeIcon
                        anchors.centerIn: parent
                        glyph: root.activeIconGlyph
                        color: root.activeThemeColor
                        size: 24
                        glowRadius: 20
                    }
                }

                // Text Information [3]
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        id: nameDisplay
                        text: root.activeItemName
                        color: root.activeThemeColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 15
                        font.bold: true
                        width: 200
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    Text {
                        id: descDisplay
                        text: root.activeItemDesc
                        color: Constants.descriptionColor
                        opacity: 0.7
                        font.family: Constants.techFont.family
                        font.pixelSize: 12
                        width: 200
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                // Chevron indicator [3]
                Text {
                    id: chevron
                    text: Constants.chevronRight
                    color: root.activeThemeColor
                    font.family: Constants.iconFont.family
                    font.pixelSize: 20
                    rotation: root.isOpen ? 90 : 0
                }
            }
        }

        // Dropdown container for other Items [7]
        Column {
            id: dropdownList
            width: parent.width
            visible: root.isOpen
            clip: true

            // SWITCH_TO: Label [7]
            Rectangle {
                id: switchLabelContainer
                width: parent.width
                height: 25
                color: "transparent"
                visible: showSwitchLabel
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: qsTr("SWITCH_TO:")
                    color: Constants.primaryTextColor
                    opacity: 0.7
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }
            }

            // Placeholder for other Items (to be populated in functional QML)
        }
    }

    // States defined at root to comply with M225 [ui.qml restriction]
    states: [
        State {
            name: "expanded"
            when: root.isOpen
            PropertyChanges {
                target: root
                height: layoutContainer.implicitHeight
            }

            PropertyChanges {
                target: mainHeader
                border.width: 2
            }
            PropertyChanges {
                target: chevron
                rotation: 90
            }
        },
        State {
            name: "collapsed"
            when: !root.isOpen
            PropertyChanges {
                target: root
                height: (mainHeader.height + sectionLabel.height)
            }
            PropertyChanges {
                target: mainHeader
                opacity: 0.8
            }
            PropertyChanges {
                target: chevron
                rotation: 0
            }
        }
    ]

    // Smooth transitions for rotation and height
    transitions: [
        Transition {
            from: "*"
            to: "*"
            RotationAnimation {
                target: chevron
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
