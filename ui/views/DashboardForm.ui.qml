
/****************************************************************************
** File: Dashboard.ui.qml
** Date: 25/2/2026
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

import ".."

import "../components"

Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: "#030213" // Color de fondo del theme.css
    property alias neonAccordion: neonAccordion
    property alias header: header


    Column {
        width: parent.width
        height: parent.height
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
        }

        NeonAccordion {
            id: neonAccordion
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ProtocolList {
            id: prolocols
            anchors.horizontalCenter: parent.horizontalCenter
            listThemeColor: neonAccordion.activeThemeColor
        }
    }

    // --- FOOTER DATA ---  TODO: Create Component
    Text {
        id: footer
        text: "NEURAL_SYNC: 100%       |       LATENCY: <1ms       |       BUILD: v2.026.2"
        font.family: Constants.techFont.family
        font.pixelSize: 10
        color: Constants.cyanNeon
        opacity: 0.5
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        // Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
    }

    // --- SCANLINES EFFECT (.scanlines de cyberpunk.css) ---
    Rectangle {
        id: scanlines
        width: parent.width
        height: 10
        // anchors.fill: parent
        // anchors.fill
        opacity: 0.2
        z: 50
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 0.5
                color: "#00fff9"
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
        PropertyAnimation on y {
            from: -10
            to: root.height
            duration: 3000
            loops: Animation.Infinite
        }
    }
} // ColumnLayout {//     anchors.fill: parent//     anchors.margins: 20//     spacing: 15//     // --- HEADER ---//     // Text {//     //     text: "hyper//hiit"//     //     font.family: "Orbitron"//     //     font.pixelSize: 28//     //     color: "#00fff9"//     //     Layout.alignment: Qt.AlignHCenter//     //     // Neon Glow
//     //     layer.enabled: true
//     //     layer.effect: MultiEffect {
//     //         blurEnabled: true
//     //         blur: 0.5
//     //         brightness: 1.5
//     //     }
//     // }

//     // --- EVOLUTION METRICS PANEL (neon-border-cyan) ---
//     Rectangle {
//         Layout.fillWidth: true
//         Layout.preferredHeight: 150
//         color: "#0d0d10"
//         opacity: 0.8
//         border.color: "#00fff9"
//         border.width: 1
//         radius: 4

//         Text {
//             text: "EVOLUTION_METRICS"
//             font.family: "Share Tech Mono"
//             color: "#00fff9"
//             anchors.top: parent.top
//             anchors.left: parent.left
//             anchors.margins: 10
//         }
//     }

//     // --- DIRECTIVES LIST (Basado en dashboard.tsx) ---
//     Repeater {
//         model: [{
//                 "name": "FAT_BURN",
//                 "color": "#bf00ff",
//                 "desc": "Metabolic acceleration"
//             }, {
//                 "name": "CARDIO_ENHANCEMENT",
//                 "color": "#00fff9",
//                 "desc": "Cardiovascular optimization"
//             }]

//         delegate: Rectangle {
//             Layout.fillWidth: true
//             Layout.preferredHeight: 80
//             color: "#0d0d10"
//             border.color: modelData.color
//             border.width: 1

//             // Tech Corners (.tech-corners de cyberpunk.css)
//             Rectangle {
//                 width: 10
//                 height: 10
//                 color: "transparent"
//                 border.color: modelData.color
//                 border.width: 2
//                 anchors.top: parent.top
//                 anchors.left: parent.left
//             }

//             Column {
//                 anchors.centerIn: parent
//                 Text {
//                     text: modelData.name
//                     color: modelData.color
//                     font.family: "Orbitron"
//                     font.pixelSize: 16
//                 }
//                 Text {
//                     text: modelData.desc
//                     color: "#717182"
//                     font.family: "Share Tech Mono"
//                     font.pixelSize: 10
//                     anchors.horizontalCenter: parent.horizontalCenter
//                 }
//             }
//         }
//     }

//     // --- FOOTER DATA ---
//     Text {
//         text: "BUILD: v2.026.2  |  NEURAL_SYNC: 100%"
//         font.family: "Share Tech Mono"
//         font.pixelSize: 10
//         color: "#00fff9"
//         opacity: 0.5
//         Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
//     }
// }

