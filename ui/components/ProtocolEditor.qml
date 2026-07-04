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

    // property bool isReady: false

    Component.onCompleted: {
        systemManager.systemReady = true
        // isReady = true;
        Constants.hDebug(debugName, "ProtocolEditor Ready") ;
        // syncDeleteButtons();
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
        isDirty = isReady ? true : null
    }

    // Live swap while a module is dragged over another module of the SAME subsystem.
    // Cross-subsystem moves are intentionally ignored here: they are resolved
    // once, on drop, by onModuleDropped (see below).
    onModuleHoverSwapRequested: function (sourceItem, targetSubsystemIndex, targetModuleIndex) {
        var fromSubsystemIndex = sourceItem.subsystemIndex
        var fromModuleIndex = sourceItem.moduleIndex

        if (fromSubsystemIndex !== targetSubsystemIndex)
            return
        if (fromSubsystemIndex < 0 || fromSubsystemIndex >= subsystemModel.count)
            return

        var modules = subsystemModel.get(fromSubsystemIndex).modules

        if (fromModuleIndex === targetModuleIndex || fromModuleIndex < 0 || fromModuleIndex >= modules.count)
            return

        var insertIndex = Math.min(Math.max(targetModuleIndex, 0), modules.count - 1)
        modules.move(fromModuleIndex, insertIndex, 1)
        reindexSubsystems();
        isDirty = isReady ? true : null
    }

    // Final resolution on drop: handles same-subsystem leftovers (usually a
    // no-op, since onModuleHoverSwapRequested already settled the position)
    // and cross-subsystem moves (remove from source, insert into target).
    onModuleDropped: function (sourceItem, targetSubsystemIndex, targetModuleIndex) {
        var fromSubsystemIndex = sourceItem.subsystemIndex
        var fromModuleIndex = sourceItem.moduleIndex

        if (fromSubsystemIndex < 0 || targetSubsystemIndex < 0)
            return
        if (fromSubsystemIndex >= subsystemModel.count || targetSubsystemIndex >= subsystemModel.count)
            return

        if (fromSubsystemIndex === targetSubsystemIndex) {
            var sameModules = subsystemModel.get(fromSubsystemIndex).modules
            if (fromModuleIndex === targetModuleIndex || fromModuleIndex < 0 || fromModuleIndex >= sameModules.count)
                return
            var sameInsertIndex = Math.min(Math.max(targetModuleIndex, 0), sameModules.count - 1)
            sameModules.move(fromModuleIndex, sameInsertIndex, 1)
            isDirty = isReady ? true : null
            return
        }

        // Cross-subsystem transfer
        var sourceModules = subsystemModel.get(fromSubsystemIndex).modules
        if (fromModuleIndex < 0 || fromModuleIndex >= sourceModules.count)
            return

        var original = sourceModules.get(fromModuleIndex)
        var snapshot = {
            "name": original.name,
            "quantity": original.quantity,
            "unit": original.unit,
            "met": original.met,
            "zone": original.zone
        }

        sourceModules.remove(fromModuleIndex, 1)

        var targetModules = subsystemModel.get(targetSubsystemIndex).modules
        var insertIndex = Math.min(Math.max(targetModuleIndex, 0), targetModules.count)
        targetModules.insert(insertIndex, snapshot)

        reindexSubsystems();
        isDirty = isReady ? true : null
    }

    function addNewSubsystem() {
        // Create an empty structure following the DB schema
        let newPhase = {
            "subsystem_id": protocolEditor.subsystemModel.count + 1,
            "modules": [] // Empty Level 4 list
        };

        protocolEditor.subsystemModel.append(newPhase);
        // isDirty = true; //TODO
        Constants.hInfo(infoName, "New subsystem added to local buffer.");
        refreshRequest()
    }

    addSubsystem.onClicked: {
        addNewSubsystem();
        isDirty = true;
        Constants.hDebug(debugName, "Add subsystem")
    }

    onSubsystemDelete: function (targetSubsystemIndex) {
        removeSubsystem(targetSubsystemIndex);
    }

    function removeSubsystem(index) {
        if (index >= 0 && index < protocolEditor.subsystemModel.count) {
            protocolEditor.subsystemModel.remove(index);
            isDirty = true;

            // Optional: Re-index remaining Subsystems for visual consistency
            reindexSubsystems();
            Constants.hInfo(infoName, "Subsystem phase removed at index: " + index);
        }
    }

    onModuleDelete: function (targetSubsystemIndex, targetModuleIndex) {
        removeModule(targetSubsystemIndex, targetModuleIndex);
    }

    function removeModule(subsystemIndex, moduleIndex) {
        if (subsystemIndex >= 0 && subsystemIndex < subsystemModel.count) {

            let subsystem = subsystemModel.get(subsystemIndex);
            let modulesList = subsystem.modules;

            // Validate and remove the specific module
            if (moduleIndex >= 0 && moduleIndex < modulesList.count) {
                modulesList.remove(moduleIndex);

                // Update unsaved changes flag
                isDirty = true;

                Constants.hInfo(infoName, "Module removed from subsystem " + subsystemIndex + " at position " + moduleIndex);
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
}
