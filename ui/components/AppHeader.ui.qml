/****************************************************************************
** File: AppHeader.ui.qml
** Date: 18/2/2026
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

import ".."

import Qt5Compat.GraphicalEffects

Rectangle {
    id: headerRoot
    width: Constants.width
    height: 100
    color: Constants.blackNeon

    // --- VIEWMODEL PROPERTIES ---
    property string titlePart1: "hyper"
    property string titlePart2: "hiit"
    property string statusLabel: "SYSTEM_ONLINE"
    property string buttonLabel: "ARCHITECT"
    property string buttonGlyph: "\uE154"
    property string buttonLink: "ArchitectForm.qml"
    property alias settingsMouseArea: settingsMouseArea

    // FontLoader {
    //     id: lucideFont
    //     source: "fonts/lucide.ttf"
    //     // font.family: "lucide"
    // }

    // LEFT BRACKET (Top-Left corner facing DOWN)
    Item {
        id: bracketLeft
        width: 15
        height: 15
        anchors.left: parent.left
        anchors.leftMargin: 20
        x: 20
        Rectangle {
            id: bracketLeftV
            width: 2
            height: 15
            color: Constants.secondaryColor
            anchors.top: parent.top
            anchors.left: parent.left
        }
        Rectangle {
            id: bracketLeftH
            width: 15
            height: 2
            color: Constants.secondaryColor
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }

    // RIGHT BRACKET (Top-Right corner facing DOWN)
    Item {
        id: bracketRight
        x: 225
        y: 0
        width: 15
        height: 15
        anchors.right: titleArea.right
        anchors.rightMargin: 20
        Rectangle {
            id: bracketRightV
            width: 2
            height: 15
            color: Constants.secondaryColor
            anchors.top: parent.top
            anchors.right: parent.right
        }
        Rectangle {
            id: bracketRightH
            width: 15
            height: 2
            color: Constants.secondaryColor
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
    }

    // 1. TITLE CONTAINER (Stable Positioning)
    Item {
        id: titleArea
        // We give it a fixed or well-buffered size so the glow doesn't push neighbors
        width: 250
        height: 60
        anchors.left: parent.left
        // anchors.leftMargin: 00
        anchors.verticalCenter: parent.verticalCenter

        // 2. GLOW LAYER (Invisible source)
        Row {
            id: titleTextRowSource
            anchors.centerIn: parent
            spacing: 2
            visible: false // Hidden source for the shadow

            Text {
                text: headerRoot.titlePart1
                font: Constants.titleFont
            }
            Text {
                text: "//"
                font: Constants.titleFont
            }
            Text {
                text: headerRoot.titlePart2
                font: Constants.titleFont
            }
        }

        // 3. THE ACTUAL SHADOW (Anchored to the source)
        DropShadow {
            anchors.fill: titleTextRowSource
            source: titleTextRowSource
            color: Constants.primaryTextColor
            radius: 20
            samples: 25
            spread: 0.2
            transparentBorder: true
        }

        // 4. THE VISIBLE CONTENT (Sharp and centered)
        Row {
            id: titleTextRowVisible
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: headerRoot.titlePart1
                color: Constants.primaryTextColor
                font: Constants.titleFont
            }
            Text {
                text: "//"
                color: Constants.secondaryTextColor
                font: Constants.titleFont
            }
            Text {
                text: headerRoot.titlePart2
                color: Constants.primaryTextColor
                font: Constants.titleFont
            }
        }
    }

    Item {
        id: settingsActionGroup
        width: settingsIcon.width + neonText.width + neonText.anchors.leftMargin
        height: Math.max(settingsIcon.height, neonText.height)

        // Position the whole group relative to the title
        anchors.left: titleArea.right
        anchors.top: bracketRight.bottom

        // Single MouseArea for both elements
        MouseArea {
            id: settingsMouseArea
            anchors.fill: parent
        }
        // Settings Gear
        NeonIcon {
            id: settingsIcon
            glyph: headerRoot.buttonGlyph
            color: Constants.primaryColor
            size: 40
            glowRadius: 15
        }

        NeonText {
            id: neonText
            anchors.left: settingsIcon.right
            anchors.leftMargin: 5
            anchors.verticalCenter: settingsIcon.verticalCenter
            label: headerRoot.buttonLabel
            labelColor: Constants.secondaryTextColor
            size: 20
        }
    }

    // 2. STATUS INDICATOR (Aligned to the right)
    NeonIndicator {
        anchors.left: settingsActionGroup.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        label_on: "SYSTEM_ONLINE"
        label_off: "SYSTEM_OFFLINE"
        active: systemManager.isSystemReady
        labelColor: Constants.primaryTextColor
    }

    // 3. DECORATIVE BOTTOM LINE
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Constants.cyanNeon
        opacity: 0.2
    }
}
