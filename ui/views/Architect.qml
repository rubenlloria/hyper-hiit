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

    property bool isReady: false
    property var rankNames: dbManager.getRankLabels()

    directiveRepeater.model: directiveModel

    Component.onCompleted: {
        isReady = true;
        protocolEditor.protocolModel.clear();
        // protocolEditor.protocolListView.model = protocolDataModel;
        // protocolEditor.protocolRepeater.model = protocolDataModel;
    }

    header.settingsMouseArea.onClicked: {
        Constants.hInfo(infoName, "Back to core-config");
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
        onAccentColorChanged: {
            if (isReady) {
                isDirty = true;
                protocolAccordion.activeThemeColor = accentColor;
            }
        }
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
                protocolAccordion.activeThemeColor = Constants.descriptionColor;
                protocolAccordion.headerMouseArea.visible = false;
                protocolAccordion.activeDirectiveName = "DIRECTIVE_NOT_SELECTED";
                protocolAccordion.activeDirectiveDesc = "Select directive first";
                protocolAccordion.isOpen = false;
            } else {
                // Force expansion when editing is requested
                // architectForm.expandedIndex = index;
                architectForm.editingIndex = index;
                protocolAccordion.activeThemeColor = accentColor;
                architectProtocolModel.filterByDirective(model.id);
                protocolAccordion.headerMouseArea.visible = true;
                protocolAccordion.activeDirectiveName = "ASSOCIATED_PROTOCOLS";
                protocolAccordion.activeDirectiveDesc = "Manage selected directive protocols";
                protocolId = -1;
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

    function formatTime(totalSeconds) { // TODO: move to Constants.qml
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;

        // Returns formatted string with zero-padding (e.g., "05:08")
        return minutes.toString().padStart(2, '0') + ":" +
               seconds.toString().padStart(2, '0');
    }

    protocolAccordion.dropdownList.children: [
        Repeater {
            model: architectProtocolModel// Linked to filtered architectProtocolModel.cpp

            delegate: NeonProtocol {
                width: parent.width

                // Data Binding from Protocol roles
                protocolName: model.name
                estimatedDuration: formatTime(model.duration)
                moduleCount: model.moduleCount
                rankLabel: rankNames[model.rank]
                personalBest: (model.personalBest === 0)
                              ? model.duration / architectProtocolModel.maxDuration
                              : model.personalBest / architectProtocolModel.maxDuration
                primaryColor:protocolAccordion.activeThemeColor
                currentProgress: model.duration / architectProtocolModel.maxDuration

                itemMouseArea.onClicked: {
                    // Logic to open ProtocolEditor could go here
                    Constants.hDebug(debugName, "Selected protocol: " + model.name
                                     + " with id: " + model.id
                                     + " and rank : " + model.rank
                                     );
                    protocolId = model.id;
                    protocolAccordion.activeDirectiveName = model.name;
                    protocolAccordion.activeDirectiveDesc = "DURATION: " + formatTime(model.duration)
                            + "   MODULES: " + model.moduleCount;
                    protocolAccordion.isOpen = false;
                    protocolDataModel = dbManager.getProtocolStructure(protocolId);
                    protocolEditor.protocolModel.clear();
                    // protocolEditor.protocolName = model.name
                    protocolEditor.selectedRank = model.rank -1
                    for (let i = 0; i < protocolDataModel.length; i++) {
                        // protocolDataModel[i] contains { "subsystem": int, "modules": [...] }
                        protocolEditor.protocolModel.append(protocolDataModel[i]);
                    }

                    Constants.hDebug(debugName, "Protocol buffer synchronized. Total items: " + protocolEditor.protocolModel.count);


                    // protocolEditor.protocolListView.model = protocolDataModel;
                    // protocolEditor.protocolRepeater.model = protocolDataModel;
                }
            }
        }
    ]

    // Accordion Toggle handler
    protocolAccordion.headerMouseArea.onClicked: {
        if (architectForm.editingDirectiveId !== -1) {
            protocolAccordion.isOpen = !protocolAccordion.isOpen;
        }
    }
}

