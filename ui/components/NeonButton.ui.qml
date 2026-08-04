
/****************************************************************************
** File: NeonButton.ui.qml
** Date: 13/3/2026
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
import Qt5Compat.GraphicalEffects
import ".."


/*
    NeonButton Component: High-tech cyberpunk terminal button.
    Coherent with the hyper//hiit ecosystem.
*/
Item {
    id: buttonRoot
    width: content.implicitWidth + 20
    height: 22 + buttonRoot.fontSize

    // Properties for customization and C++ integration
    property string label: "EXECUTE_COMMAND"
    property int fontSize: 14
    property string iconGlyph: Constants.targetIcon
    property color themeColor: Constants.primaryTextColor
    property bool isHovered: interactionArea.containsMouse
    property bool isPressed: interactionArea.pressed
    property bool enabled: true
    property alias interactionArea: interactionArea

    opacity: enabled ? 1 : 0.4

    // 1. Matte Black Background
    Rectangle {
        id: backgroundBase
        anchors.fill: parent
        color: Constants.surfaceColor
        opacity: 0.95
        border.color: buttonRoot.themeColor
        border.width: 1

        // --- Scanlines Texture ---
        // Mimics the horizontal repeating linear gradient from CSS [5]
        Rectangle {
            anchors.fill: parent
            opacity: 0.1
            gradient: Gradient {
                // fillMode: Gradient.Repeat
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: Constants.backgroundColor
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }
    }

    // 2. Neon Glow (Bloom) Effect
    // Reuses the shadow logic from NeonIcon and NeonText [1, 6]
    DropShadow {
        id: borderGlow
        anchors.fill: backgroundBase
        source: backgroundBase
        color: buttonRoot.themeColor
        radius: buttonRoot.isHovered ? 25 : 15
        samples: 30
        spread: 0.2
        transparentBorder: true
        opacity: 0.8
    }

    // 3. Tech Corners (Terminal Brackets)
    // Replicates the .tech-corners logic from cyberpunk.css [2, 7]
    // Item {
    //     anchors.fill: parent

    //     // Top-Left Bracket
    //     Rectangle {
    //         width: 12
    //         height: 2
    //         color: buttonRoot.themeColor
    //         x: 10
    //         y: 12
    //     }
    //     Rectangle {
    //         width: 2
    //         height: 12
    //         color: buttonRoot.themeColor
    //         x: 10
    //         y: 2
    //     }

    //     // Top-Right Bracket
    //     Rectangle {
    //         width: 12
    //         height: 2
    //         color: buttonRoot.themeColor
    //         x: parent.width - 22
    //         y: 12
    //     }
    //     Rectangle {
    //         width: 2
    //         height: 12
    //         color: buttonRoot.themeColor
    //         x: parent.width - 12
    //         y: 2
    //     }
    // }

    // 4. Content Row (Icon + Text)
    RowLayout {
        id: content
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -5
        spacing: 5

        // Icon component using Lucide font [3]
        NeonIcon {
            id: iconDisplay
            glyph: buttonRoot.iconGlyph
            color: buttonRoot.themeColor
            size: 20
            // anchors.verticalCenter: parent.verticalCenter
            Layout.alignment: Qt.AlignVCenter
        }

        NeonText {
            id: labelDisplay
            label: buttonRoot.label
            labelColor: buttonRoot.themeColor
            size: 14
            // anchors.verticalCenter: parent.verticalCenter
            Layout.alignment: Qt.AlignVCenter
            cornerWidth: 1
        }
    }

    // 5. Visual Feedback Overlay (Flash on Click)
    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        color: Constants.descriptionColor
        opacity: 0
    }

    // Interaction Handling
    MouseArea {
        id: interactionArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // States for IDLE, HOVER, and PRESSED
    states: [
        State {
            name: "hover"
            when: buttonRoot.isHovered && !buttonRoot.isPressed
            PropertyChanges {
                target: borderGlow
                radius: 30
                opacity: 1.0
            }
        },
        State {
            name: "pressed"
            when: buttonRoot.isPressed
            PropertyChanges {
                target: backgroundBase
                border.color: Constants.primaryColor
            } // Magenta flip [4]
            PropertyChanges {
                target: borderGlow
                color: Constants.primaryColor
                radius: 40
            }
            PropertyChanges {
                target: flashOverlay
                opacity: 0.2
            }
        }
    ]
}
