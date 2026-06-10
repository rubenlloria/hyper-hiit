
/****************************************************************************
** File: NeonFooter.ui.qml
** Date: 15/3/2026
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
import Qt5Compat.GraphicalEffects

import ".."

Rectangle {
    id: root
    width: Constants.designWidth
    height: hudRow.implicitHeight + 5
    color: Constants.deepColor
    opacity: 0.9

    // --- Dynamic Properties ---
    // These variables can be controlled from C++ models or logic files
    property string syncValue: "100%"
    property string latencyValue: "<1ms"
    property string buildVersion: appVersion
    property color textColor: Constants.primaryTextColor
    property color separatorColor: Constants.primaryTextColor

    // Top border line with low opacity cyan glow
    Rectangle {
        width: parent.width
        height: 1
        color: root.separatorColor
        opacity: 0.2
        anchors.top: parent.top
    }

    // Main container for HUD metrics
    Row {
        id: hudRow
        anchors.centerIn: parent // Ensures the entire group is centered horizontally
        spacing: 35 // spacing between elements and separators

        // 1. NEURAL_SYNC (Digital Font)
        Text {
            id: syncText
            text: "NEURAL_SYNC: " + root.syncValue
            color: root.textColor
            opacity: 0.6
            font.family: "Share Tech Mono"
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        // Separator 1 (1px slim Rectangle)
        Rectangle {
            width: 1
            height: 12
            color: root.separatorColor
            opacity: 0.2
            anchors.verticalCenter: parent.verticalCenter
        }

        // 2. LATENCY
        Text {
            id: latencyText
            text: "LATENCY: " + root.latencyValue
            color: root.textColor
            opacity: 0.6
            font.family: "Share Tech Mono"
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        // Separator 2
        Rectangle {
            width: 1
            height: 12
            color: root.separatorColor
            opacity: 0.2
            anchors.verticalCenter: parent.verticalCenter
        }

        // 3. BUILD VERSION
        Text {
            id: buildText
            text: "BUILD: v" + root.buildVersion
            color: root.textColor
            opacity: 0.6
            font.family: "Share Tech Mono"
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
