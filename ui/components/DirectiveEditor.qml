import QtQuick
import QtQuick.Controls
import "."
import ".."

DirectiveEditorView {
    id: editor

    // Signals to coordinate "radio" behavior with the parent
    signal expansionRequested()
    signal editRequested()
    signal deleteRequested()
    signal saveRequested()

    // 1. Header Interaction (Expand/Collapse)
    headerArea.onClicked: {
        Constants.hDebug(debugName, "Header clicked for directive: " + editor.nameText);
        // Notify parent to handle exclusive expansion
        editor.expansionRequested();
        // isExpanded = !isExpanded;
    }

    // 2. Edit Mode Interaction
    editButton.onClicked: {
        Constants.hDebug(debugName, "Edit mode toggled for: " + editor.nameText);
        // Notify parent to handle exclusive editing
        editor.editRequested();
        // isEditing = !isEditing;
    }

    // 3. Delete Interaction
    deleteButton.onClicked: {
        Constants.hDebug(debugName, "Delete sequence initiated for: " + editor.nameText + " (" + editor.directiveId + ")");
        // editor.deleteRequested();
        // Populate the popup context for the UI agent

        let targetName = editor.nameText;
        confirmPopup.target = qsTr("DIRECTIVE // ") + targetName.toUpperCase()
        confirmPopup.message = qsTr("ARE YOU SURE YOU WANT TO DELETE ") +
                             (targetName !== "" ? "[" + targetName + "]" : qsTr("THIS ENTITY")) +
                             qsTr("? THIS ACTION WILL PERMANENTLY ERASE DATA FROM THE CORE REGISTRY.")


        // Display the tactical confirmation overlay
        confirmPopup.onAccept = function() {
            Constants.hInfo(debugName, "User confirmed deletion for record: " + targetName);

            // Execute the persistence logic defined in the controller
            deleteDirective(editor.directiveId, targetName);
        };
        confirmPopup.open();
        Constants.hInfo(debugName, "Popup screen size" + confirmPopup.width + "x" + confirmPopup.height );
        Constants.hInfo(debugName, "Popup size" + confirmPopup.view.width + "x" + confirmPopup.view.height );
    }

    // New button logic: Finalizes the edit mode and persists data
    saveButton.onClicked: {
        Constants.hDebug(debugName, "Data persistence requested for: " + editor.nameText);
        editor.saveRequested();
    }

    onAccentColorChanged: {
        // Convert color object to string and update the TextField
        hexInput.text = editor.accentColor.toString().toUpperCase();

        // Debug log for terminal telemetry
        Constants.hDebug(debugName, "Color selected: " + hexInput.text);
    }

    // Handle manual HEX entry from the text field
    hexInput.textInput.onEditingFinished: {
        let entry = hexInput.text.trim();

        // Strict HEX validation pattern (#RRGGBB)
        let hexRegex = /^#([A-Fa-f0-9]{6})$/;

        if (hexRegex.test(entry)) {
            editor.accentColor = entry;
            // Visual feedback via success pulse property
            hexInput.showSuccessPulse = true;
            Constants.hDebug(debugName, "Manual entry validated: " + entry);
        } else {
            // Revert on invalid format
            hexInput.text = editor.accentColor.toString().toUpperCase();
            Constants.hWarning(debugName, "Invalid HEX format rejected: " + entry);
        }
    }

    function deleteDirective(dirId, dirName) {
        Constants.hDebug(debugName, "Deleting directive" + dirName + " with id: " + dirId);
        // Call C++ backend with the provided directive ID
        let success = dbManager.deleteDirective(dirId);

        if (success) {
            Constants.hInfo(debugName, "Directive synchronized deletion completed.");

            if (dirId === sessionManager.getActiveDirectiveId()) {
                sessionManager.setActiveDirectiveId(-4);
                sessionManager.activeDirectiveInfo = {
                    "id": -4,
                    "name": qsTr("SELECT_DIRECTIVE"),
                    "description": qsTr("No data"),
                    "icon": Constants.zapIcon,
                    "color": Constants.primaryColor
                };
            }

            // Refresh the directive list to reflect changes in the UI
            // DirectiveModel uses setDirectives for full synchronization
            directiveModel.setDirectives(dbManager.getAllDirectives());

        } else {
            // Backend returned false (likely due to integrity constraints)
            Constants.hCritical(debugName, "Registry error: Directive cannot be removed");
        }
    }

}
