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

    property bool isReady: false

    Component.onCompleted: {
        isReady = true;
        // syncDeleteButtons();
    }

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
    // protocolModel is a real ListModel, so real exchanges are done with
    // its native move()/remove()/insert() methods. ListView then animates
    // delegates to their new slot instead of just floating in absolute
    // screen coordinates.
    // ------------------------------------------------------------------

    // Live swap while a subsystem block is dragged over another one
    onSubsystemSwapRequested: function (sourceItem, targetIndex) {
        var fromIndex = sourceItem.subsystemIndex

        if (fromIndex === targetIndex || fromIndex < 0 || targetIndex < 0)
            return
        if (fromIndex >= protocolModel.count || targetIndex >= protocolModel.count)
            return

        protocolModel.move(fromIndex, targetIndex, 1)
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
        if (fromSubsystemIndex < 0 || fromSubsystemIndex >= protocolModel.count)
            return

        var modules = protocolModel.get(fromSubsystemIndex).modules

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
        if (fromSubsystemIndex >= protocolModel.count || targetSubsystemIndex >= protocolModel.count)
            return

        if (fromSubsystemIndex === targetSubsystemIndex) {
            var sameModules = protocolModel.get(fromSubsystemIndex).modules
            if (fromModuleIndex === targetModuleIndex || fromModuleIndex < 0 || fromModuleIndex >= sameModules.count)
                return
            var sameInsertIndex = Math.min(Math.max(targetModuleIndex, 0), sameModules.count - 1)
            sameModules.move(fromModuleIndex, sameInsertIndex, 1)
            isDirty = isReady ? true : null
            return
        }

        // Cross-subsystem transfer
        var sourceModules = protocolModel.get(fromSubsystemIndex).modules
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

        var targetModules = protocolModel.get(targetSubsystemIndex).modules
        var insertIndex = Math.min(Math.max(targetModuleIndex, 0), targetModules.count)
        targetModules.insert(insertIndex, snapshot)

        reindexSubsystems();
        isDirty = isReady ? true : null
    }

    // Helper to hook into dynamically created delegates
    // function syncDeleteButtons() {
    //     // This is necessary because ListView items are instantiated as needed
    //     // but since we disabled interaction/scroll, we can sync them reliably
    //     Constants.hDebug(debugName, "Syncing " + protocolEditor.protocolListView.count + " delete buttons");
    //     // for (let i = 0; i < protocolEditor.protocolListView.count; i++) {
    //     //     let item = protocolEditor.protocolListView.itemAtIndex(i);
    //     //     Constants.hDebug(debugName, "Syncing item " + i + " with id: " + item.id)
    //     //     if (item) {
    //     //         Constants.hDebug(debugName, "Syncing delete button" + item.id)
    //     //         item.buttonDelete.onClicked = () => {
    //     //             removeSubsystem(i);
    //     //         }
    //     //     }
    //     // }
    // }

    function addNewSubsystem() {
        // Create an empty structure following the DB schema
        let newPhase = {
            "subsystem_id": protocolEditor.protocolModel.count + 1,
            "modules": [] // Empty Level 4 list
        };

        protocolEditor.protocolModel.append(newPhase);
        // isDirty = true; //TODO
        Constants.hInfo(infoName, "New subsystem added to local buffer.");
    }

    addSubsystem.onClicked: {
        addNewSubsystem();
        Constants.hDebug(debugName, "Add subsystem")
    }

    onSubsystemDelete: function (targetSubsystemIndex) {
        removeSubsystem(targetSubsystemIndex);
    }

    function removeSubsystem(index) {
        if (index >= 0 && index < protocolEditor.protocolModel.count) {
            protocolEditor.protocolModel.remove(index);
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
        if (subsystemIndex >= 0 && subsystemIndex < protocolModel.count) {

            // 2. Access the subsystem element
            let subsystem = protocolModel.get(subsystemIndex);

            // 3. Access the nested 'modules' ListModel
            let modulesList = subsystem.modules;

            // 4. Validate and remove the specific module (Level 4)
            if (moduleIndex >= 0 && moduleIndex < modulesList.count) {
                modulesList.remove(moduleIndex);

                // 5. Update unsaved changes flag
                isDirty = true;

                Constants.hInfo(infoName, "Module removed from subsystem " + subsystemIndex + " at position " + moduleIndex);
            }
        }
    }

    function reindexSubsystems() {
        for (let i = 0; i < protocolEditor.protocolModel.count; i++) {
            protocolEditor.protocolModel.setProperty(i, "subsystem_id", i + 1);
        }
        protocolEditor.protocolListView.forceLayout();
    }
}
