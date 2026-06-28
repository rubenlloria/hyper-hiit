import QtQuick
import "."
import ".."

ModuleEditorView {
    id: editor

    readonly property string debugName: "ModuleEditor.qml"
    readonly property string infoName: "ModuleEditor.qml"

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
            // Role mapping based on src/ModuleModel.h [Source 272]
            tempArray.push({
                "module_id": moduleModel.data(moduleModel.index(i, 0), 257),    // IdRole
                "name": moduleModel.data(moduleModel.index(i, 0), 258),         // NameRole
                "target_zone": moduleModel.data(moduleModel.index(i, 0), 259),  // TargetRole
                "difficulty": moduleModel.data(moduleModel.index(i, 0), 260),   // DifficultyRole
                "description": moduleModel.data(moduleModel.index(i, 0), 261),  // DescriptionRole
                "unit_type": moduleModel.data(moduleModel.index(i, 0), 262),    // UnitTypeRole
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
            let nameUpper = module.name.toUpperCase();
            Constants.hDebug(debugName, "Iterating module: " + module.name);

            // Match by name or target zone
            if (nameUpper === search) {
                foundExact = true;
            }

            if (search === "" ||
                module.name.toUpperCase().includes(search) ||
                module.target_zone.toUpperCase().includes(search)) {

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

    function addModuleToCurrentProtocol(moduleId) {
        // Trigger logic in Architect.qml to append this module
        // to the active buffer sequence.
    }

    function openMasterEditDialog(moduleId) {
        // Open overlay to modify MET_FACTOR or targetZone
    }

    function requestModuleDeletion(moduleId) {
        // Trigger Neon Red confirmation for database removal
    }
}
