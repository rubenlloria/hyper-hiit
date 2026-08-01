/*
 * ProtocolEditor.qml
 * Functional companion for protocol structural changes.
 */
import QtQuick
import "."
import ".."

ProtocolEditorView {
    id: protocolEditor

    readonly property string debugName: "ProtocolEditor.qml"
    readonly property string infoName: "ProtocolEditor.qml"

    property bool isReady: systemManager.systemReady
    signal protocolDeleted()
    signal protocolSaved()

    Component.onCompleted: {
        Constants.hInfo(infoName, "ProtocolEditor Ready") ;
    }

    onProtocolNameChanged: { Constants.hDebug(debugName, "ProtocolNameChanged") ; if (isReady) isDirty = true }
    onProtocolRankChanged: { Constants.hDebug(debugName, "ProtocolRankChanged") ; if (isReady) isDirty = true }
    // onsubsystemModelChanged: { Constants.hDebug(debugName, "subsystemModelChanged") ; if (isReady) isDirty = true }


    // headerArea.onClicked: {
    //     // Request exclusive expansion from the parent (the DirectiveEditor)
    //     protocolEditor.expansionRequested(index);
    // }

    // Guards for the Dirty state (Magenta)
    // onDurationChanged: isDirty = isReady ? true : null
    // onRankChanged: isDirty = isReady ? true : null

    // signal expansionRequested(int index)

    // ------------------------------------------------------------------
    // DRAG & DROP — reordering logic
    // (not valid inside the .ui.qml; that's why it lives here)
    //
    // subsystemModel is a real ListModel, so real exchanges are done with
    // its native move()/remove()/insert() methods. ListView then animates
    // delegates to their new slot instead of just floating in absolute
    // screen coordinates.
    // ------------------------------------------------------------------

    // Live swap while a subsystem block is dragged over another one
    onSubsystemSwapRequested: function (sourceItem, targetIndex) {
        var fromIndex = sourceItem.subsystemIndex

        if (fromIndex === targetIndex || fromIndex < 0 || targetIndex < 0)
            return
        if (fromIndex >= subsystemModel.count || targetIndex >= subsystemModel.count)
            return

        subsystemModel.move(fromIndex, targetIndex, 1)
        reindexSubsystems();
        isStructureDirty = isReady ? true : null
    }

    // ------------------------------------------------------------------
    // Tracked drag state: the delegate's `index` binding (moduleItem.moduleIndex)
    // is a QML binding that re-evaluates asynchronously. When modules.move() fires
    // and a new DropArea.onEntered triggers before the next frame, sourceItem.moduleIndex
    // still returns the PRE-MOVE index, causing move() to operate on the wrong item.
    //
    // Fix: ProtocolEditor.qml owns the authoritative current position of the dragged
    // module and updates it synchronously after every swap. The .ui.qml exposes two
    // properties (trackedDragSubsystem / trackedDragModuleIndex) that mirror these
    // values so DropAreas can also read the correct position if needed.
    // ------------------------------------------------------------------
    property int _dragCurrentSubsystem: -1  // authoritative current subsystem
    property int _dragCurrentIndex: -1      // authoritative current list index
    property string _lastSwapKey: ""        // bounce-back guard

    // Live swap while a module is dragged over another module of the SAME subsystem.
    onModuleHoverSwapRequested: function (sourceItem, targetSubsystemIndex, targetModuleIndex) {
        // On first call (no swap yet), seed tracking from the delegate's index —
        // at this point it is still fresh because no move() has happened yet.
        if (_dragCurrentIndex < 0) {
            _dragCurrentIndex = sourceItem.moduleIndex
            _dragCurrentSubsystem = sourceItem.subsystemIndex
        }

        var fromSubsystemIndex = _dragCurrentSubsystem
        var fromModuleIndex = _dragCurrentIndex

        // Only handle same-subsystem swaps here
        if (fromSubsystemIndex !== targetSubsystemIndex) return
        if (fromSubsystemIndex < 0 || fromSubsystemIndex >= subsystemModel.count) return
        if (fromModuleIndex === targetModuleIndex) return

        // Bounce-back guard: reject the exact reverse of the last swap
        var reverseKey = targetSubsystemIndex + "," + targetModuleIndex
                         + "→" + fromSubsystemIndex + "," + fromModuleIndex
        if (reverseKey === _lastSwapKey) return

        var mods = subsystemModel.get(fromSubsystemIndex).modules
        if (fromModuleIndex < 0 || fromModuleIndex >= mods.count) return

        var insertIndex = Math.min(Math.max(targetModuleIndex, 0), mods.count - 1)

        // Record this swap as the "last" so its reverse is blocked next frame
        _lastSwapKey = fromSubsystemIndex + "," + fromModuleIndex
                       + "→" + targetSubsystemIndex + "," + insertIndex

        mods.move(fromModuleIndex, insertIndex, 1)

        // Update authoritative position SYNCHRONOUSLY so the next DropArea.onEntered
        // reads the correct index even before the QML binding re-evaluates
        _dragCurrentIndex = insertIndex
        _dragCurrentSubsystem = targetSubsystemIndex
        trackedDragSubsystem = targetSubsystemIndex
        trackedDragModuleIndex = insertIndex

        reindexSubsystems()
        isStructureDirty = isReady ? true : null
    }

    // Final resolution on drop.
    // For same-subsystem drops this is usually a no-op (hover swaps already placed the
    // item). For cross-subsystem drops: remove from source, insert into target.
    onModuleDropped: function (sourceItem, targetSubsystemIndex, targetModuleIndex) {
        // Use authoritative tracked position; fall back to delegate index only if
        // no hover swap happened during this drag (tracking was never seeded)
        var fromSubsystemIndex = _dragCurrentSubsystem >= 0 ? _dragCurrentSubsystem : sourceItem.subsystemIndex
        var fromModuleIndex = _dragCurrentIndex >= 0 ? _dragCurrentIndex : sourceItem.moduleIndex

        // Reset all tracking state unconditionally
        _dragCurrentIndex = -1
        _dragCurrentSubsystem = -1
        _lastSwapKey = ""
        trackedDragSubsystem = -1
        trackedDragModuleIndex = -1

        if (fromSubsystemIndex < 0 || targetSubsystemIndex < 0) return
        if (fromSubsystemIndex >= subsystemModel.count || targetSubsystemIndex >= subsystemModel.count) return

        if (fromSubsystemIndex === targetSubsystemIndex) {
            // Same-subsystem: hover swaps should have already settled the position;
            // this is a safety net for edge cases (e.g. drop on the same slot)
            var sameModules = subsystemModel.get(fromSubsystemIndex).modules
            if (fromModuleIndex === targetModuleIndex
                    || fromModuleIndex < 0
                    || fromModuleIndex >= sameModules.count) return
            var sameInsert = Math.min(Math.max(targetModuleIndex, 0), sameModules.count - 1)
            sameModules.move(fromModuleIndex, sameInsert, 1)
            isStructureDirty = isReady ? true : null
            return
        }

        // Cross-subsystem transfer: requires remove + insert (two different ListModels)
        var sourceModules = subsystemModel.get(fromSubsystemIndex).modules
        if (fromModuleIndex < 0 || fromModuleIndex >= sourceModules.count) return

        var original = sourceModules.get(fromModuleIndex)
        var snapshot = {
            "module_id":    original.module_id,
            "s_order":      0,
            "module_name":  original.module_name,
            "quantity":     original.quantity,
            "unit":         original.unit,
            "unit_type":    original.unit_type,
            "met_factor":   original.met_factor,
            "fatigue_rate": original.fatigue_rate,
            "rep_time":     original.rep_time,
            "zone":         original.zone
        }

        sourceModules.remove(fromModuleIndex, 1)

        var targetModules = subsystemModel.get(targetSubsystemIndex).modules
        var insertIndex = Math.min(Math.max(targetModuleIndex, 0), targetModules.count)
        targetModules.insert(insertIndex, snapshot)

        reindexSubsystems()
        isStructureDirty = isReady ? true : null
    }

    cloneButton.onClicked: {
        let originalName = protocolName;
        let id = protocolId;
        let rank = protocolRank + 1;
        Constants.hDebug(debugName, "cloing protocol " + originalName
                         + ", with id: " + id
                         + " and rank: " + rank
                         );

        // Sever the database link by resetting the ID to 0 (New Entry Sentry).
        // The DatabaseManager uses ID 0 to determine if it should perform an INSERT.
        protocolId = 0;

        // Update identifying metadata with the required suffix
        protocolName = originalName + "_clone";

        // Force the dirty flags to TRUE.
        // This enables the save workflow and ensures the structure is also persisted.
        isDirty = true;
        isStructureDirty = true;

    }

    saveButton.onClicked: {
        let name = protocolName;
        let id = protocolId;
        let rank = protocolRank + 1;
        let directives = directiveList;
        let protocolIsNew = (id === 0)

        Constants.hDebug(debugName, "Saving protocol " + name + ", with id: " + id + ", directive: " + directives[0] + " and rank: " + rank);
        Constants.hDebug(debugName, "Protocol dirty:" + isDirty + ", structure dirty: " + isStructureDirty );

        if (isDirty || protocolId === 0) {
            let finalId = dbManager.saveProtocol(id, name, rank, directives);
            if (protocolId === 0 && finalId > 0) {
                protocolId = finalId;
            }
        }

        if (isStructureDirty) {
            let protocolStructure = [];
            for (let i = 0; i < subsystemModel.count; i++) {
                let sub = subsystemModel.get(i);
                Constants.hDebug(debugName, "MODULE_STRUCTURE: " + JSON.stringify(sub, null, 2));
                // Create a plain object for each subsystem
                let plainSubsystem = {
                    "subsystem_id": sub.subsystem_id,
                    "modules": []
                };

                // Process nested modules to ensure plain objects and correct types
                for (let j = 0; j < sub.modules.count; j++) {
                    let mod = sub.modules.get(j);
                    plainSubsystem.modules.push({
                        "module_id": mod.module_id,
                        "quantity": parseInt(mod.quantity),
                        "unit_type": mod.is_default ? mod.default_type : 0 // Ensure this is the INTEGER (0-3), not the label
                    });
                }
                protocolStructure.push(plainSubsystem);
            }

            Constants.hDebug(debugName, "SERIALIZED_STRUCTURE: " + JSON.stringify(protocolStructure, null, 2));

            if (dbManager.hasProtocolHistory(protocolId)) {
                confirmPopup.target = "HISTORY // " + name;
                confirmPopup.message = "Structural changes will purge existing session history. Continue?"
                confirmPopup.onAccept = function() {
                    dbManager.clearProtocolHistory(protocolId);
                    dbManager.saveProtocolStructure(protocolId, protocolStructure);
                    Constants.hInfo(infoName, "Structure updated and history purged for: " + name);
                };
                confirmPopup.open();
            } else {
                dbManager.saveProtocolStructure(protocolId, protocolStructure);
                Constants.hInfo(infoName, "Structure synchronized for: " + name);
            }
        }

        isDirty = false;
        isStructureDirty = false;
        protocolSaved()
    }

    deleteButton.onClicked: {
        let name = protocolName;
        let id = protocolId;
        let rank = protocolRank + 1;
        Constants.hDebug(debugName, "Purging the protocol: " + name
                         + ", with id: " + id
                         );
        confirmPopup.target = qsTr("PROTOCOL // ") + name.toUpperCase();
        confirmPopup.message = qsTr("ARE YOU SURE YOU WANT TO DELETE ") +
                (name !== "" ? "[" + name + "]" : qsTr("THIS ENTITY")) +
                qsTr("? THIS ACTION WILL PERMANENTLY ERASE DATA FROM THE REGISTRY.")
        confirmPopup.onAccept = function() {
            dbManager.deleteProtocol(id);
            Constants.hInfo(infoName, "Data and history purged for protocol: " + name);
            protocolDeleted();
        };

        confirmPopup.onCancel = function() {
            Constants.hInfo(infoName, "Purge cancelled");
        };

        confirmPopup.open();
    }

    function addNewSubsystem() {
        // Create an empty structure following the DB schema
        let newPhase = {
            "subsystem_id": protocolEditor.subsystemModel.count + 1,
            "modules": [] // Empty Level 4 list
        };

        protocolEditor.subsystemModel.append(newPhase);
        Constants.hInfo(infoName, "New subsystem added to local buffer.");
        refreshRequest()
    }

    addSubsystem.onClicked: {
        addNewSubsystem();
        isStructureDirty = true;
        Constants.hDebug(debugName, "Add subsystem")
    }

    onSubsystemClone: function (index) {
        // Access the specific ListModel instance
        let model = protocolEditor.subsystemModel;

        // Validate index boundaries to prevent registry overflow
        if (index < 0 || index >= model.count) {
            Constants.hWarning(infoName, "Clone operation aborted: Invalid index context.");
            return;
        }

        let clonedData = JSON.parse(JSON.stringify(model.get(index)));

        model.insert(index + 1, clonedData);
        reindexSubsystems();
        isStructureDirty = true;
        Constants.hInfo(infoName, "Subsystem phase cloned at index: " + index);
    }

    onSubsystemRemove: function (targetSubsystemIndex) {
        if (targetSubsystemIndex >= 0 && targetSubsystemIndex < protocolEditor.subsystemModel.count) {
            protocolEditor.subsystemModel.remove(targetSubsystemIndex);
            isStructureDirty = true;

            // Re-index remaining Subsystems for visual consistency
            reindexSubsystems();
            Constants.hInfo(infoName, "Subsystem phase removed at index: " + targetSubsystemIndex);
        }
    }

    onModuleRemove: function (targetSubsystemIndex, targetModuleIndex) {
        if (targetSubsystemIndex >= 0 && targetSubsystemIndex < subsystemModel.count) {

            let subsystem = subsystemModel.get(targetSubsystemIndex);
            let modulesList = subsystem.modules;

            // Validate and remove the specific module
            if (targetModuleIndex >= 0 && targetModuleIndex < modulesList.count) {
                modulesList.remove(targetModuleIndex);

                // Update unsaved changes flag
                isStructureDirty = true;

                Constants.hInfo(infoName, "Module removed from subsystem " + targetSubsystemIndex + " at position " + targetModuleIndex);
            }
        }
    }

    function reindexSubsystems() {
        for (let i = 0; i < protocolEditor.subsystemModel.count; i++) {
            protocolEditor.subsystemModel.setProperty(i, "subsystem_id", i + 1);
        }
        protocolEditor.protocolListView.forceLayout();
    }

    onRefreshRequest: {
        Constants.hDebug(debugName, "refreshRequested")

        layoutVersion++;
        layoutVersion = 0;
        protocolListView.forceLayout()
    }

    function toggleDirective(model) {
        const dirId = model.id;
        const dirName = model.name;
        let currentList = protocolEditor.directiveList
        let index = currentList.indexOf(dirId);

        Constants.hDebug(debugName, dirName + " clicked on protocolId: " + protocolId);

        if (index !== -1) {
            // CASE: Deselect - Remove the ID from the local list
            currentList.splice(index, 1);
            Constants.hDebug(debugName, "Directive " + dirName + " (ID: " + dirId + ") removed from local mapping.");
        } else {
            // CASE: Select - Add the ID to the local list
            currentList.push(dirId);
            Constants.hDebug(debugName, "Directive " + dirName + " (ID: " + dirId + ") added to local mapping.");
        }

        // Atomic reassignment: This triggers 'unlocked' property re-evaluation in all Repeater delegates
        protocolEditor.directiveList = currentList;
        isDirty = true;
        Constants.hDebug(debugName, "Current Directive Matrix: " + JSON.stringify(protocolEditor.directiveList));
    }
}

