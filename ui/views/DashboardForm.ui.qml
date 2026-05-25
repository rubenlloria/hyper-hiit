
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
    property alias protocols: protocols
    property alias header: header
    property alias evolutionChart: evolutionChart

    ColumnLayout {
        width: parent.width
        height: parent.height
        spacing: 10
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
        }

        Flickable {
            id: dashboardScroll
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
                width: parent.width
                spacing: 10

                NeonAccordion {
                    id: neonAccordion
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                ProtocolList {
                    id: protocols
                    anchors.horizontalCenter: parent.horizontalCenter
                    listThemeColor: neonAccordion.activeThemeColor
                }
                NeonEvolution {
                    id: evolutionChart
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                NeonAchievement {
                    id: achievement
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Column {
                    // TODO: Improve spacer to prevent footer overlap last module
                    height: 30
                    width: 20
                }

                // GridLayout {
                //     id: achievementMatrix
                //     width: parent.width * 0.9
                //     anchors.horizontalCenter: parent.horizontalCenter
                //     columns: 5
                //     rowSpacing: 15
                //     columnSpacing: 10
                //     readonly property var iconMap: {
                //         "activity": Constants.activityIcon,
                //         "fire": Constants.fireIcon,
                //         "shield": Constants.shieldIcon,
                //         "ffwd": Constants.ffwIcon,
                //         "timer": Constants.timerIcon,
                //         "crown": Constants.crownIcon,
                //         "cpu": Constants.cpuIcon,
                //         "log-in": Constants.loginIcon,
                //         "ghost": Constants.ghostIcon,
                //         "layers": Constants.layersIcon
                //     }

                //     // NEURAL SYNC: Dynamic generation based on C++ model
                //     Repeater {
                //         id: achievementRepeater
                //         // Accessing the QList<QObject*> achievements property from C++
                //         model: achievementManager.achievements

                //         delegate: NeonBadge {
                //             // Layout scale fixed at 60px per requirement
                //             size: 60

                //             // Mapping C++ properties to UI components
                //             // modelData is the Achievement object from the QList
                //             glyph: achievementMatrix.iconMap[modelData.icon]
                //                    || "x"
                //             unlocked: modelData.unlocked

                //             // Optional: The name/description can be used for tooltips
                //         }
                //     }
                // }
            }
        }
    }
}
