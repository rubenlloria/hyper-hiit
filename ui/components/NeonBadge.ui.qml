
/****************************************************************************
** File: NeonAchievement.ui.qml
** Date: 19/5/2026
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
import QtQuick.Controls
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

import "."
import ".."

Item {
    id: root
    property int size: 80
    property string glyph: "x"
    property bool unlocked: false
    property color color: Constants.primaryColor
    readonly property color accentColor: root.color

    width: size
    height: size

    Layout.alignment: Qt.AlignCenter
    opacity: unlocked ? 1 : 0.2

    // Dark background
    Rectangle {
        anchors.fill: parent
        color: Constants.secondaryDarkColor
        opacity: 0.85
        radius: 4
    }

    NeonIcon {
        id: badgeIcon
        anchors.centerIn: parent
        glyph: root.glyph
        size: root.size / 2
    }

    states: [
        State {
            name: "lockedState"
            when: !root.unlocked
            PropertyChanges {
                target: root
                color: root.accentColor
                opacity: 0.2
            }
        },
        State {
            name: "unlockedState"
            when: root.unlocked
            PropertyChanges {
                target: root
                color: root.accentColor
                opacity: 1
            }
        }
    ]

    // TACTICAL FEEDBACK: Sequential animation (Flash 3 times in white)
    transitions: [
        Transition {
            from: "lockedState"
            to: "unlockedState"
            SequentialAnimation {
                // Flash 1
                ColorAnimation {
                    target: root
                    property: "color"
                    to: Constants.descriptionColor
                    duration: 100
                }
                ColorAnimation {
                    target: root
                    property: "color"
                    to: root.accentColor
                    duration: 100
                }
                // Flash 2
                ColorAnimation {
                    target: root
                    property: "color"
                    to: Constants.descriptionColor
                    duration: 100
                }
                ColorAnimation {
                    target: root
                    property: "color"
                    to: root.accentColor
                    duration: 100
                }
                // Flash 3
                ColorAnimation {
                    target: root
                    property: "color"
                    to: Constants.descriptionColor
                    duration: 100
                }
                // Final settle with a slight pulse
                NumberAnimation {
                    target: badgeIcon
                    property: "scale"
                    from: 1.2
                    to: 1.0
                    duration: 1000
                    easing.type: Easing.OutBack
                }
                ColorAnimation {
                    target: root
                    property: "color"
                    to: root.accentColor
                    duration: 2000
                }
            }
        }
    ]

    Repeater {
        model: 4
        Item {
            id: cornerTemplate

            property int size: parent.size / 4

            width: size
            height: size

            // 1. Dynamic positioning based on the index (0 to 3)
            // Index mapping: 0 = Top-Left, 1 = Top-Right, 2 = Bottom-Right, 3 = Bottom-Left
            anchors.top: (index === 0 || index === 1) ? parent.top : undefined
            anchors.bottom: (index === 2
                             || index === 3) ? parent.bottom : undefined
            anchors.left: (index === 0 || index === 3) ? parent.left : undefined
            anchors.right: (index === 1
                            || index === 2) ? parent.right : undefined
            // 2. Dynamic rotation based on the index (0°, 90°, 180°, 270°)
            rotation: index * 90

            Shape {
                id: cornerShape

                property int size: parent.size
                property int cornerWidth: size / 2
                property int chamfer: size / 3

                width: size
                height: size

                ShapePath {
                    strokeColor: root.color
                    strokeWidth: cornerShape.size / 10
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap
                    joinStyle: ShapePath.MiterJoin

                    PathMove {
                        x: 0
                        y: cornerShape.chamfer
                    }
                    PathLine {
                        x: cornerShape.chamfer
                        y: 0
                    }
                    PathLine {
                        x: cornerShape.width
                        y: 0
                    }
                    PathLine {
                        x: cornerShape.width
                        y: cornerShape.cornerWidth
                    }
                    PathLine {
                        x: cornerShape.cornerWidth + cornerShape.size / 12
                        y: cornerShape.cornerWidth
                    }
                    PathLine {
                        x: cornerShape.cornerWidth
                        y: cornerShape.cornerWidth + cornerShape.size / 12
                    }
                    PathLine {
                        x: cornerShape.cornerWidth
                        y: cornerShape.height
                    }
                    PathLine {
                        x: 0
                        y: cornerShape.height
                    }
                    PathLine {
                        x: 0
                        y: cornerShape.chamfer
                    }
                }
            }
            Rectangle {
                color: root.color
                height: cornerShape.size / 10
                width: parent.size / 1.5
                anchors.left: cornerShape.right
                anchors.leftMargin: cornerShape.size / 4
            }
            Rectangle {
                color: root.color
                height: cornerShape.size / 10
                width: parent.size / 2.1
                anchors.left: cornerShape.right
                anchors.leftMargin: cornerShape.size / 4
                anchors.top: cornerShape.top
                anchors.topMargin: cornerShape.size / 5
            }
            Rectangle {
                color: root.color
                height: parent.size / 1.5
                width: cornerShape.size / 10
                anchors.top: cornerShape.bottom
                anchors.topMargin: cornerShape.size / 4
            }
            Rectangle {
                color: root.color
                height: parent.size / 2.1
                width: cornerShape.size / 10
                anchors.top: cornerShape.bottom
                anchors.topMargin: cornerShape.size / 4
                anchors.left: cornerShape.left
                anchors.leftMargin: cornerShape.size / 5
            }
        }
    }
}
