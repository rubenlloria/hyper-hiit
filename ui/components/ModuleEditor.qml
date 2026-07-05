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
            let rawUnit = moduleModel.data(idx, 262);
            let rawRepTime= moduleModel.data(idx, 263);
            let rawMetFactor = moduleModel.data(idx, 264);
            let rawFatigue = moduleModel.data(idx, 265);

            // Conditional logging for first and last entry to avoid flooding
            if (i === 0 || i === count - 1) {
                Constants.hDebug(debugName, "Telemetry Shard [" + i + "]: NAME=" + rawName
                                 + " | ID=" + rawId
                                 + " | ZONE=" + rawZone
                                 + " | DESCRIPTION=" + rawDescription
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
                               "unit": systemManager.getUnitLabel(moduleModel.data(moduleModel.index(i, 0), 262), true),    // UnitTypeRole
                               "rep_time": moduleModel.data(moduleModel.index(i, 0), 263),     // RepTimeRole
                               "met_factor": moduleModel.data(moduleModel.index(i, 0), 264),   // MetFactorRole
                               "fatigue_rate": moduleModel.data(moduleModel.index(i, 0), 265)  // FatigueRateRole
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

    function editModule(moduleId, m_model) {
        // Open overlay to modify MET_FACTOR or targetZone
        Constants.hDebug(debugName, "Editing" + m_model.module_name);
    }

    function deleteModule(moduleId, m_model) {
        // Trigger Neon Red confirmation for database removal
        Constants.hDebug(debugName, "Deleting " + m_model.module_name + " from DB");
    }
    function saveModule(moduleId) {
        // Trigger Neon Red confirmation for database removal
        Constants.hDebug(debugName, "Saving module with id " + moduleId + " on DB");
    }
}
