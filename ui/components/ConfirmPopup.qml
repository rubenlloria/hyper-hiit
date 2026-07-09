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
    id: popupRoot

    // Positioning at the absolute center of the viewport
    width: Constants.designWidth
    height: Constants.designHeight

    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    // --- CONTEXT PROPERTIES ---
    property string message: "ARE YOU SURE YOU WANT TO EXECUTE THIS DESTRUCTIVE OPERATION?"
    property string target: "TARGET ITEM"

    property alias view: view

    // --- NEURAL SYNC SIGNALS ---
    signal accepted()
    signal cancelled()

    // --- MAINTENANCE FUNCTIONS ---
    function reset() {
        message = "";
    }

    ConfirmPopupView {
        id: view
        width: parent.width * 0.8
        anchors.centerIn: parent

        // Dynamic message binding based on target data
        messageText: message
        targetText: target

        confirmButton.interactionArea.onClicked: {
            if (message === "")
                return;
            accepted();
            popupRoot.close();
            reset();
        }

        cancelButton.interactionArea.onClicked: {
            cancelled();
            popupRoot.close();
            reset();
        }
    }

    // Modal dimming overlay
    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.8)
    }
}
