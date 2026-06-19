/****************************************************************************
** File: Architect.qml
** Date: 18/06/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License version 2 as
** published by the Free Software Foundation.
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
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
import QtQuick
import "../components"
import ".."

ArchitectForm {
    id: architectForm

    readonly property string debugName: "Architect.qml"
    readonly property string infoName: "Architect.qml"

    property int expandedIndex: -1
    property int editingIndex: -1
    property bool isReady: false

    directiveRepeater.model: directiveModel

    Component.onCompleted: isReady = true;

    header.settingsMouseArea.onClicked: {
        console.log("Back to core-config");
        mainStack.pop();
    }

    buttonAll.onClicked: {
        Constants.hDebug(debugName, "Button ALL Clicked");
    }

    buttonOrphan.onClicked: {
        Constants.hDebug(debugName, "Button ORPHAN Clicked");
    }

    directiveRepeater.delegate: DirectiveEditor {
        // Property Bindings: Logic flows from parent to child
        // This ensures exclusive behavior (<1ms latency)
        isExpanded: architectForm.expandedIndex === index
        isEditing: architectForm.editingIndex === index

        // Directive Data Injection
        directiveId: model.id
        nameText: model.name
        descriptionText: model.description
        accentColor: model.color
        glyph: model.icon
        isDirty: false;

        onNameTextChanged: { if (isReady) isDirty = true; }
        onDescriptionTextChanged: { if (isReady) isDirty = true; }
        onAccentColorChanged: { if (isReady) isDirty = true; }
        onGlyphChanged: { if (isReady) isDirty = true; }

        // Signal Handling
        onExpansionRequested: {
            if (architectForm.expandedIndex === index) {
                // Toggle off if clicking the already active one
                architectForm.expandedIndex = -1;
                // architectForm.editingIndex = -1;
            } else {
                // Exclusive activation: deactivates any other active item
                architectForm.expandedIndex = index;
                // architectForm.editingIndex = -1;
            }
            Constants.hDebug(debugName, "Neural Sync: Active index set to " + architectForm.expandedIndex);
        }

        onEditRequested: {
            if (architectForm.editingIndex === index) {
                // Close edit mode if already editing
                architectForm.editingIndex = -1;
            } else {
                // Force expansion when editing is requested
                // architectForm.expandedIndex = index;
                architectForm.editingIndex = index;
            }
            Constants.hDebug(debugName, "Neural Sync: Edit mode toggled for index " + index);
        }

        onSaveRequested: {
            Constants.hDebug(debugName, "Persistence: Saving changes for "
                             + "dir_id: " + directiveId
                             + ", name: " + nameText
                             + ", description: " + descriptionText
                             + ", color: " + accentColor
                             + ", glyph: " + glyph
                             );

            // Finalize interaction: collapse and sync
            architectForm.editingIndex = -1;
            architectForm.expandedIndex = -1;
            isDirty = false;

            // Refresh model to reflect DB changes (Neural Sync)
            // dbManager.updateDirective(...) logic here
        }

        onDeleteRequested: {
            Constants.hDebug(debugName, "Security: Deletion sequence for " + nameText);
            // logic to remove from DB and refresh list
        }
    }
}
