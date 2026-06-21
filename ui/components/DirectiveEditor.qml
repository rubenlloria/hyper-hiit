import QtQuick
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
        Constants.hDebug("DirectiveEditor", "Header clicked for directive: " + editor.nameText);
        // Notify parent to handle exclusive expansion
        editor.expansionRequested();
        // isExpanded = !isExpanded;
    }

    // 2. Edit Mode Interaction
    editButton.onClicked: {
        Constants.hDebug("DirectiveEditor", "Edit mode toggled for: " + editor.nameText);
        // Notify parent to handle exclusive editing
        editor.editRequested();
        // isEditing = !isEditing;
    }

    // 3. Delete Interaction
    deleteButton.onClicked: {
        Constants.hDebug("DirectiveEditor", "Delete sequence initiated for: " + editor.nameText);
        editor.deleteRequested();
    }

    // New button logic: Finalizes the edit mode and persists data
    saveButton.onClicked: {
        Constants.hDebug("DirectiveEditor", "Data persistence requested for: " + editor.nameText);
        editor.saveRequested();
    }

    onAccentColorChanged: {
        // Convert color object to string and update the TextField
        hexInput.text = editor.accentColor.toString().toUpperCase();

        // Debug log for terminal telemetry
        Constants.hDebug("DirectiveEditor", "Color selected: " + hexInput.text);
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
            Constants.hDebug("DirectiveEditor", "Manual entry validated: " + entry);
        } else {
            // Revert on invalid format
            hexInput.text = editor.accentColor.toString().toUpperCase();
            Constants.hWarning("DirectiveEditor", "Invalid HEX format rejected: " + entry);
        }
    }

}
