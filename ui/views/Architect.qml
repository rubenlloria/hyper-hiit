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
import QtQuick.Controls
import "../components"
import ".."

ArchitectForm {
    id: architectForm

    readonly property string debugName: "Architect.qml"
    readonly property string infoName: "Architect.qml"

    property bool isReady: systemManager.systemReady
    property var rankNames: dbManager.getRankLabels()

    ListModel {
        id: localDirectivesBuffer
    }

    directiveRepeater.model: directiveModel

    Component.onCompleted: {
        protocolEditor.subsystemModel.clear();
        moduleEditor.loadModules();
        Constants.hDebug(debugName, "Context Check -> sessionManager status: " + (typeof sessionManager !== 'undefined'));
        Constants.hInfo(infoName, "Architect ready");
    }

    header.settingsMouseArea.onClicked: {
        Constants.hInfo(infoName, "Back to core-config");
        systemManager.systemReady = false;
        Constants.runDeferred(
                    () => {
                        mainStack.pop();
                    });
    }

    buttonAll.onClicked: {
        Constants.hDebug(debugName, "Button ALL Clicked");
        if ( architectForm.editingIndex === -2) {
            architectForm.editingIndex = -1;
            protocolAccordion.activeThemeColor = Constants.descriptionColor;
            protocolAccordion.headerMouseArea.visible = false;
            protocolAccordion.activeItemName = qsTr("DIRECTIVE_NOT_SELECTED");
            protocolAccordion.activeItemDesc = qsTr("Select directive first");
            protocolAccordion.isOpen = false;
        } else {
            architectProtocolModel.showAll();
            architectForm.editingIndex = -2;
            protocolEditor.currentDirectiveId = -2;
            protocolAccordion.activeThemeColor = Constants.primaryColor;
            // architectProtocolModel.filterByDirective(0);
            protocolAccordion.headerMouseArea.visible = true;
            protocolAccordion.activeItemName = qsTr("ASSOCIATED_PROTOCOLS");
            protocolAccordion.activeItemDesc = qsTr("Manage selected directive protocols");
            protocolId = -1;
        }
    }

    buttonOrphan.onClicked: {
        Constants.hDebug(debugName, "Button ORPHAN Clicked");
        if ( architectForm.editingIndex === -3) {
            architectForm.editingIndex = -1;
            protocolAccordion.activeThemeColor = Constants.descriptionColor;
            protocolAccordion.headerMouseArea.visible = false;
            protocolAccordion.activeItemName = qsTr("DIRECTIVE_NOT_SELECTED");
            protocolAccordion.activeItemDesc = qsTr("Select directive first");
            protocolAccordion.isOpen = false;
        } else {
            architectProtocolModel.showOrphans();
            architectForm.editingIndex = -3;
            protocolEditor.currentDirectiveId = -3;
            protocolAccordion.activeThemeColor = Constants.primaryColor;
            // architectProtocolModel.filterByDirective(0);
            protocolAccordion.headerMouseArea.visible = true;
            protocolAccordion.activeItemName = qsTr("ASSOCIATED_PROTOCOLS");
            protocolAccordion.activeItemDesc = qsTr("Manage selected directive protocols");
            protocolId = -1;
        }
    }

    buttonNewDirective.onClicked: {
        Constants.hDebug(debugName, "Button NEW Clicked");
        directiveModel.insertNewDraft();
        let index =  directiveModel.rowCount() -1;
        Constants.hDebug(debugName, "NEW index: " + index);
        architectForm.expandedIndex = index;
        architectForm.editingIndex =  index;
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
            systemManager.systemReady = false;
            Constants.hDebug(debugName, "System ready: " + systemManager.systemReady)
            Constants.runDeferred(() => {
                  if (architectForm.editingIndex === index) {
                      // Close edit mode if already editing
                      architectForm.editingIndex = -1;
                      protocolAccordion.activeThemeColor = Constants.descriptionColor;
                      protocolAccordion.headerMouseArea.visible = false;
                      protocolAccordion.activeItemName = qsTr("DIRECTIVE_NOT_SELECTED");
                      protocolAccordion.activeItemDesc = qsTr("Select directive first");
                      protocolAccordion.isOpen = false;
                  } else {
                      // Force expansion when editing is requested
                      // architectForm.expandedIndex = index;
                      architectForm.editingIndex = index;
                      protocolEditor.currentDirectiveId = directiveId;
                      protocolAccordion.activeThemeColor = accentColor;
                      architectProtocolModel.filterByDirective(model.id);
                      protocolAccordion.headerMouseArea.visible = true;
                      protocolAccordion.activeItemName = qsTr("ASSOCIATED_PROTOCOLS");
                      protocolAccordion.activeItemDesc = qsTr("Manage selected directive protocols");
                      protocolId = -1;
                  }
              });
            Constants.hDebug(debugName, "System ready: " + systemManager.systemReady)
            Constants.hDebug(debugName, "Neural Sync: Edit mode toggled for index " + index);
        }

        onSaveRequested: {
            systemManager.systemReady = false;
            Constants.runDeferred(() => {
                                      Constants.hDebug(debugName, "Persistence: Saving changes for "
                                                       + "dir_id: " + directiveId
                                                       + ", name: " + nameText
                                                       + ", description: " + descriptionText
                                                       + ", color: " + accentColor
                                                       + ", glyph: " + glyph
                                                       + ", on row: " + index
                                                       );

                                      // architectForm.editingIndex = -1;
                                      architectForm.expandedIndex = -1;
                                      dbManager.saveDirective(directiveId, nameText, descriptionText, glyph, accentColor);

                                      // We check if the directive being edited is the active one in the system
                                      Constants.hDebug(debugName, "directiveId: " + directiveId
                                                       + "sessionManager.activeDirectiveInfo.id: " + sessionManager.activeDirectiveInfo.id);
                                      if (directiveId === sessionManager.activeDirectiveInfo.id) {
                                          sessionManager.activeDirectiveInfo = {
                                              "id": directiveId,
                                              "name": nameText,
                                              "description": descriptionText,
                                              "icon": glyph,
                                              "color": accentColor
                                          };
                                          mainWindow.currentDirectiveColor = accentColor;
                                      }

                                      // Finalize interaction: collapse and sync
                                      isDirty = false;
                                      directiveModel.setDirectives(dbManager.getAllDirectives());
                                  });
        }

        onDeleteRequested: {
            Constants.hDebug(debugName, "Security: Deletion sequence for " + nameText);
            // logic to remove from DB and refresh list
        }
    }

    protocolAccordion.dropdownList.children: [
        Repeater {
            model: architectProtocolModel// Linked to filtered architectProtocolModel.cpp

            delegate: NeonProtocol {
                width: parent.width

                // Data Binding from Protocol roles
                protocolName: model.name
                estimatedDuration: Constants.formatTime(model.duration)
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
                                     + " | Current directive: " + protocolEditor.currentDirectiveId
                                     );
                    systemManager.systemReady  = false;
                    Constants.runDeferred(() => {
                          Constants.hDebug(debugName, "ProtocolEditor not ready") ;
                          protocolId = model.id;
                          protocolAccordion.activeItemName = model.name;
                          protocolAccordion.activeItemDesc = qsTr("DURATION: ") + Constants.formatTime(model.duration)
                          + qsTr("   MODULES: ") + model.moduleCount;
                          protocolAccordion.isOpen = false;
                          if (protocolId === 0) {
                              // NEW_PROTOCOL logic: Initialize empty buffer for fresh configuration
                              protocolEditor.directiveList = protocolEditor.currentDirectiveId > 0 ? [protocolEditor.currentDirectiveId] : [];
                              protocolAccordion.activeItemDesc = qsTr("DRAFT: PENDING STRUCTURE");
                              protocolEditor.subsystemModel.clear();
                              protocolEditor.selectedRank = 0; // Default to NEWBIE (rank 1 -> index 0)

                              Constants.hInfo(debugName, "Editor initialized for new protocol draft.");
                          } else if (protocolId > 0) {
                              protocolEditor.directiveList = dbManager.getDirectiveList(protocolId);
                              protocolDataModel = dbManager.getProtocolExecutionDetails(protocolId);
                              // protocolDataModel = dbManager.getProtocolStructure(protocolId, true);
                              protocolEditor.subsystemModel.clear();
                              protocolEditor.protocolName = model.name
                              protocolEditor.selectedRank = model.rank -1
                              for (let i = 0; i < protocolDataModel.length; i++) {
                                  protocolEditor.subsystemModel.append(protocolDataModel[i]);
                              }
                          }
                          Constants.hDebug(debugName, "ProtocolEditor ready") ;
                          Constants.hDebug(debugName, "Protocol buffer synchronized. Total items: " + protocolEditor.subsystemModel.count);
                      });
                    protocolEditor.isDirty = false;
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

    protocolEditor.onProtocolNameChanged: {
        protocolAccordion.activeItemName = protocolEditor.protocolName
        // protocolEditor.isDirty = true;
    }

    addProtocol.onClicked: {
        architectProtocolModel.insertNewDraft();
        // Scroll to the bottom or set focus to the new item if needed
        Constants.hDebug(debugName, "Adding new protocol draft to the current directive context");
    }

    protocolEditor.onProtocolDeleted: {
        architectProtocolModel.filterByDirective(protocolEditor.currentDirectiveId);
        protocolAccordion.headerMouseArea.visible = true;
        protocolAccordion.activeItemName = qsTr("ASSOCIATED_PROTOCOLS");
        protocolAccordion.activeItemDesc = qsTr("Manage selected directive protocols");
        protocolId = -1

        // Update protocolModel on Dashboard
        let activeId = sessionManager.getActiveDirectiveId();
        protocolModel.filterByDirective(activeId)
    }

    protocolEditor.onProtocolSaved: {
        Constants.hDebug(debugName, "Current directive id: " + protocolEditor.currentDirectiveId)
        architectProtocolModel.filterByDirective(protocolEditor.currentDirectiveId);
        Constants.hDebug(debugName, protocolAccordion.activeItemDesc);
        protocolAccordion.activeItemDesc = qsTr("Pending data calculation");

        // Update protocolModel on Dashboard
        let activeId = sessionManager.getActiveDirectiveId();
        protocolModel.filterByDirective(activeId)
    }

    moduleAccordion.headerMouseArea.onClicked: {
        if (architectForm.editingDirectiveId !== -1) {
            moduleAccordion.isOpen = !moduleAccordion.isOpen;
        }
    }

    ///////////// FUNCTIONS /////////////

    moduleEditor.onModuleInsertionRequested: (m_model) => {
                                                 Constants.hDebug(debugName, "Signal from module: " + m_model.module_name);
                                                 insertModule(m_model)
                                             }

    /**
     * Adds a module from the library to the last defined subsystem in the editor.
     * @param {var} model - model with module info
     */
    function insertModule(model) {
        // 1. Safety Check: Ensure the timeline has at least one phase
        if (protocolEditor.subsystemModel.count === 0) {
            Constants.hWarning(infoName, "No active subsystem found. Please add a subsystem first.");
            return;
        }

        // 2. Locate the target subsystem (the last one in the buffer)
        let lastIndex = protocolEditor.subsystemModel.count - 1;
        let targetSubsystem = protocolEditor.subsystemModel.get(lastIndex);

        // 3. Create the module object following the Level 4 schema
        // We use 'struct_id: 0' to indicate this is a new entry for the database
        Constants.hDebug(debugName, "Creating module object for " + model.module_name
                         + ", id: " + model.module_id
                         + ", s_order: " + targetSubsystem.modules.count + 1
                         + ", unit: " + model.unit
                         + ", unit_type: " + model.unit_type
                         + ", zone: " + model.zone
                         + ", met: " + model.met_factor
                         );
        let moduleDraft = {
            "module_id": model.module_id,
            "s_order": targetSubsystem.modules.count + 1,
            "module_name": model.module_name,
            "quantity": 10, // Default starting value
            "unit": model.unit,
            "unit_type": model.unit_type,
            "default_type": model.unit_type,
            "is_default": true,
            "met_factor": model.met_factor,
            "fatigue_rate": model.fatigue_rate,
            "rep_time": model.rep_time,
            "zone": model.zone
        };

        // 4. Update the nested list
        // As 'modules' is a JS array property within the ListModel item:
        targetSubsystem.modules.append(moduleDraft);

        // 5. System notification and UI sync
        protocolEditor.isDirty = true;
        protocolEditor.refreshRequest();

        Constants.hInfo("Architect", "Module [" + model.module_name + "] added to subsystem " + targetSubsystem.subsystem_id);
    }
}

