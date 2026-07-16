import QtQuick
import "."
import ".."

ModuleEditorView {
    id: editor

    readonly property string debugName: "ModuleEditor.qml"
    readonly property string infoName: "ModuleEditor.qml"

    signal moduleInsertionRequested(var model)

    // Link to the system's global module model
    // moduleRepeater.model: moduleModel

    property var masterModuleList: []
    moduleCount: moduleList.count
    property bool exactMatchFound: false

    // Signal to load data (called when the Architect suite opens)
    function loadModules() {
        Constants.hDebug(debugName, "Loading " + moduleModel.rowCount() + " modules");
        let count = moduleModel.rowCount();
        let tempArray = [];

        for (let i = 0; i < count; i++) {
            let idx = moduleModel.index(i, 0);

            // RAW INSPECTION: Identify if data exists in the model shard
            let rawId = moduleModel.data(idx, 257);
            let rawName = moduleModel.data(idx, 258);
            let rawZone = moduleModel.data(idx, 259);
            let rawDifficulty= moduleModel.data(idx, 260);
            let rawDescription = moduleModel.data(idx, 261);
            let rawInstructions = moduleModel.data(idx, 262);
            let rawSafety= moduleModel.data(idx, 263);
            let rawEquipment= moduleModel.data(idx, 264);
            let rawUnit = moduleModel.data(idx, 265);
            let rawRepTime= moduleModel.data(idx, 266);
            let rawMetFactor = moduleModel.data(idx, 267);
            let rawFatigue = moduleModel.data(idx, 268);

            // Conditional logging for first and last entry to avoid flooding
            if (i === 0 || i === count - 1) {
                Constants.hDebug(debugName, "Telemetry Shard [" + i + "]: NAME=" + rawName
                                 + " | ID=" + rawId
                                 + " | ZONE=" + rawZone
                                 + " | DESCRIPTION=" + rawDescription
                                 + " | INSTRUCTIONS=" + rawInstructions
                                 + " | SAFETY=" + rawSafety
                                 + " | EQUIPMENT=" + rawEquipment
                                 + " | DIFFICULTY=" + rawDifficulty
                                 + " | UNIT=" + rawUnit
                                 + " | REPTIME=" + rawRepTime
                                 + " | METFACTOR=" + rawMetFactor
                                 + " | FATIGUE=" + rawFatigue
                                 );
            }
            // Role mapping based on src/ModuleModel.h [Source 272]
            tempArray.push({
                               "module_id": moduleModel.data(moduleModel.index(i, 0), 257),    // IdRole
                               "module_name": moduleModel.data(moduleModel.index(i, 0), 258),         // NameRole
                               "zone": moduleModel.data(moduleModel.index(i, 0), 259),  // TargetRole
                               "difficulty": moduleModel.data(moduleModel.index(i, 0), 260),   // DifficultyRole
                               "description": moduleModel.data(moduleModel.index(i, 0), 261),  // DescriptionRole
                               "instructions": moduleModel.data(moduleModel.index(i, 0), 262),  // InstructionsRole
                               "safety": moduleModel.data(moduleModel.index(i, 0), 263),  // SafetyRole
                               "equipment": moduleModel.data(moduleModel.index(i, 0), 264),  // EquipmentRole
                               "unit": systemManager.getUnitLabel(moduleModel.data(moduleModel.index(i, 0), 265), true),    // UnitTypeRole
                               "unit_type": moduleModel.data(moduleModel.index(i, 0), 265),    // UnitTypeRole
                               "rep_time": moduleModel.data(moduleModel.index(i, 0), 266),     // RepTimeRole
                               "met_factor": moduleModel.data(moduleModel.index(i, 0), 267),   // MetFactorRole
                               "fatigue_rate": moduleModel.data(moduleModel.index(i, 0), 268)  // FatigueRateRole
                           });
        }

        masterModuleList = tempArray;
        applyFilter(""); // Show all modules by default
    }

    // Core filtering logic for <1ms responsiveness
    function applyFilter(searchText) {
        // Clear the visual buffer (moduleDataModel)
        moduleDataModel.clear();

        // Prepare search term for case-insensitive matching
        let search = searchText.toUpperCase().trim();
        let foundExact = false;

        // Iterate through master list and append matches to the buffer
        for (let i = 0; i < masterModuleList.length; i++) {
            let module = masterModuleList[i];
            let nameUpper = module.module_name.toUpperCase();
            Constants.hDebug(debugName, "Iterating module: " + module.module_name);

            // Match by name or target zone
            if (nameUpper === search) {
                foundExact = true;
            }

            if (search === "" ||
                module.module_name.toUpperCase().includes(search) ||
                module.zone.toUpperCase().includes(search)) {

                moduleDataModel.append(module);
            }
        }
        exactMatchFound = foundExact;
        // Force layout refresh if geometry issues occur
        // moduleListView.forceLayout();
    }

    searchInput.onTextChanged: {
        // Logic to trigger SQL LIKE filter in ModuleModel.cpp
        Constants.hDebug(debugName, "Filtering registry for: " + searchInput.text);
        applyFilter(searchInput.text)
    }



    function insertModule(moduleId, m_model) {
        // Trigger logic in Architect.qml to append this module
        // to the active buffer sequence.
        Constants.hDebug(debugName, "Inserting module " + moduleId);
        for (var property in m_model) {
            // Only print data roles, skipping internal functions and circular objects
            try {
                if (typeof m_model[property] !== "function") {
                    Constants.hDebug(debugName, "Field [" + property + "]: " + m_model[property]);
                }
            } catch (e) {
                // Some internal properties might throw access errors during iteration
                Constants.hDebug(debugName, "Skipping internal field [" + property + "]");
            }
        }
        editor.moduleInsertionRequested(m_model);
    }

    /**
     * Prepares the editor factory with data from an existing module.
     * @param index Position in the current list model.
     * @param m_model Data object containing module metadata.
     */
    function editModule(index, m_model) {
        // Open overlay to modify MET_FACTOR or targetZone
        Constants.hDebug(debugName, "Editing" + m_model.module_name + "with id: " + index);
        searchMode = false;
        moduleFactory.moduleId = m_model.module_id; // Store actual DB ID for saveModule

        // Data injection using existing aliases
        moduleNameField.text = m_model.module_name || "";
        moduleDescriptionField.text = m_model.description || "";
        instructionsField.text = m_model.instructions || "";
        safetyField.text = m_model.safety|| "";
        equipmentField.text = m_model.equipment || "NONE";

        // Syncing Numeric Telemetry
        repTimeField.text = m_model.rep_time || 1.1;
        metFactorField.text = m_model.met_factor || 1.1;
        fatigueRateField.text = m_model.fatigue_rate || 1.1;

        // Component Mapping (Combos)
        // Map Target Zone string to index
        let zoneIdx = targetZoneCombo.model.indexOf(m_model.zone);
        targetZoneCombo.currentIndex = (zoneIdx >= 0) ? zoneIdx : 0;

        // Map Difficulty (Database 1-3 to Index 0-2)
        difficultyCombo.currentIndex = Math.max(0, (m_model.difficulty || 1) - 1);

        // Map Unit Type (Direct integer assignment)
        unitCombo.currentIndex = m_model.unit_type || 0;

        Constants.hInfo(debugName, "Edit buffer synchronized for module ID: " + moduleFactory.moduleId);
    }

    /**
     * Triggers the asynchronous confirmation flow for module removal.
     * index: Position in the current UI list
     * m_model: Data object containing module_id and module_name
     */
    function requestDeleteModule(index, m_model) {
        if (index < 0 || !m_model) {
            Constants.hWarning(debugName, "Request aborted: Invalid parameters.");
            return;
        }

        // Populate the popup context for the UI agent
        let targetName = m_model.module_name;
        confirmPopup.target = "MODULE // " + targetName.toUpperCase()
        confirmPopup.message = "ARE YOU SURE YOU WANT TO DELETE " +
                (targetName !== "" ? "[" + targetName + "]" : "THIS ENTITY") +
                "? THIS ACTION WILL PERMANENTLY ERASE DATA FROM THE CORE REGISTRY."


        // Display the tactical confirmation overlay
        confirmPopup.onAccept = function() {
            Constants.hInfo(debugName, "User confirmed deletion for record: " + targetName);

            // Execute the persistence logic defined in the controller
            deleteModule(index, m_model);
        };
        confirmPopup.open();
    }

    function deleteModule(index, m_model) {
        // Trigger Neon Red confirmation for database removal
        Constants.hDebug(debugName, "Deleting " + m_model.module_name + " from DB");
        let moduleId = m_model.module_id;
        if (moduleId <= 0) {
            Constants.hWarning(debugName, "Invalid module ID for deletion.");
            return;
        }

        let success = dbManager.deleteModule(moduleId);

        if (success) {
            Constants.hInfo(debugName, "Module " + moduleId + " synchronized deletion.");

            // If we were editing this specific module, reset the factory
            if (moduleFactory.moduleId === moduleId) {
                moduleFactory.moduleId = -1;
            }
            // Refresh the master list to reflect changes in the UI
            searchMode = true;
            searchInput.text = "";
            moduleModel.setModules(dbManager.getAllModules());
            loadModules();

        } else {
            Constants.hCritical(debugName, "Database error: Could not remove module record.");
        }
    }

    function saveModule(moduleId) {
        // Trigger Neon Red confirmation for database removal
        Constants.hDebug(debugName, "Saving module with id " + moduleId + " on DB");
        let moduleShard = {
            "id": moduleFactory.moduleId,
            "name": moduleNameField.text,
            "targetZone": targetZoneCombo.currentText,
            "difficulty": difficultyCombo.currentIndex + 1,
            "description": moduleDescriptionField.text,
            "instructions": instructionsField.text,
            "safety": safetyField.text,
            "equipment": equipmentField.text,
            "unitType": unitCombo.currentIndex,
            "repTime": parseFloat(repTimeField.text || 1.0),
            "metFactor": parseFloat(metFactorField.text || 1.0),
            "fatigueRate": parseFloat(fatigueRateField.text || 1.0)
        };

        let resultId = dbManager.saveModule(moduleShard);

        if (resultId > 0) {
            Constants.hInfo(debugName, "Data saving successful for ID: " + resultId);
            searchMode = true;
            searchInput.text = "";
            moduleModel.setModules(dbManager.getAllModules());
            loadModules();
            searchInput.text = moduleNameField.text;
            // moduleEditor.refreshRequested();

            moduleFactory.moduleId = -1;
            moduleNameField.text = searchInput.text;
            targetZoneCombo.currentIndex = 0;
            difficultyCombo.currentIndex = 0;
            moduleDescriptionField.text = "";
            instructionsField.text = "";
            safetyField.text = "";
            equipmentField.text = "";
            unitCombo.currentIndex = 0;
            repTimeField.text = "";
            metFactorField.text = "";
            fatigueRateField.text = "";
        }
    }
}
