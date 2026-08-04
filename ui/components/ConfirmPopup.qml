
/****************************************************************************
** File: ConfirmPopup.qml
** Date: 9/7/2026
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
import Qt5Compat.GraphicalEffects
import "."
import ".."

/*
   ConfirmPopup.qml
   Logic controller for critical confirmation modals.
   Interfaces with ModuleEditor for SQL registry operations.
*/

Popup {
    id: root

    // Positioning at the absolute center of the viewport
    width: Constants.designWidth
    height: Constants.designHeight

    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    // --- CONTEXT PROPERTIES ---
    property string message: qsTr("ARE YOU SURE YOU WANT TO EXECUTE THIS DESTRUCTIVE OPERATION?")
    property string target: qsTr("TARGET ITEM")

    property alias view: view

    // --- NEURAL SYNC SIGNALS ---
    property var onAccept: null
    property var onCancel: null
    property bool enableCancel: true

    // --- MAINTENANCE FUNCTIONS ---
    function reset() {
        message = "";
        onAccept = null;
        onCancel = null;
        enableCancel = true;
    }

    ConfirmPopupView {
        id: view
        width: parent.width * 0.8
        anchors.centerIn: parent

        // Dynamic message binding based on target data
        messageText: message
        targetText: target
        enableCancelButton: root.enableCancel

        confirmButton.interactionArea.onClicked: {
            if (message === "")
                return;

            if (typeof onAccept === "function") {
                onAccept();
            }

            root.close();
            reset();
        }

        cancelButton.interactionArea.onClicked: {
            if (typeof onCancel === "function") {
                onCancel();
            }

            root.close();
            reset();
        }
    }

    // Modal dimming overlay
    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.8)
    }
}
