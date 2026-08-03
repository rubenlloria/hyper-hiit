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
