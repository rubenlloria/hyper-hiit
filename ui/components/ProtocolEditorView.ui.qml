
/****************************************************************************
** File: ProtocolEditorView.ui.qml
** Date: 20/6/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/


/*
 * ProtocolEditorView.ui.qml
 * Modular item for protocol editing within a Directive.
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import Qt5Compat.GraphicalEffects
import ".."
import "."


/*
   Protocol Editor View
   Main construction interface for HIIT sequences (Architect Suite v0.9).
   Handles protocol metadata, directive mapping, and the subsystem timeline.
*/
Item {
    id: root
    width: Constants.designWidth * 0.95
    height: contentLayout.height + 40

    property bool isDirty: false // state for general unsaved changes
    property bool isStructureDirty: false // state for structure unsaved changes
    property bool isAllDirty: isDirty || isStructureDirty
    property bool isReady: systemManager.systemReady
    property color accentColor: Constants.primaryColor // Default Protocol Color
    property int currentDirectiveId: -1
    property var directiveList: []

    // Properties for data binding
    property alias protocolName: nameField.text
    property alias protocolRank: rankSelector.selectedIndex
    property int selectedRank: 1 // 0:NEWBIE, 1:ADVANCED, 2:ROOT
    property int layoutVersion: 0

    property alias protocolListView: subsystemListView

    // Data model exposed so the logic file (ProtocolEditor.qml) can manipulate it.
    // A real ListModel supports move()/remove()/insert() natively, which lets
    // ListView reposition delegates instead of destroying/recreating them.
    property alias subsystemModel: subsystemModel
    property alias addSubsystem: addSubsystem
    property alias cloneButton: cloneButton
    property alias saveButton: saveButton
    property alias deleteButton: deleteButton

    // Tracked drag position: ProtocolEditor.qml updates these after every swap so
    // the .ui.qml DropAreas always know the TRUE current index of the dragged
    // module (the delegate's own `index` binding may be stale mid-drag).
    property int trackedDragSubsystem: -1
    property int trackedDragModuleIndex: -1

    ListModel {
        id: subsystemModel
        ListElement {
            subsystem_id: 1
            modules: [
                ListElement {
                    module_id: 0
                    s_order: 0
                    module_name: "Burpees"
                    quantity: 15
                    unit: "Rep."
                    unit_type: 1
                    default_type: 1
                    is_default: true
                    met_factor: 0.1
                    fatigue_rate: 1.0
                    rep_time: 1.5
                    zone: "Full Body"
                },
                ListElement {
                    module_id: 0
                    s_order: 0
                    module_name: "Mountain Climbers"
                    quantity: 15
                    unit: "Rep."
                    unit_type: 0
                    default_type: 1
                    is_default: false
                    met_factor: 0.1
                    fatigue_rate: 1.0
                    rep_time: 1.5
                    zone: "Full Body"
                }
            ]
        }
        ListElement {
            subsystem_id: 2
            modules: [
                ListElement {
                    module_id: 0
                    s_order: 0
                    module_name: "Burpees"
                    quantity: 15
                    unit: "Rep."
                    unit_type: 1
                    default_type: 1
                    is_default: true
                    met_factor: 0.1
                    fatigue_rate: 1.0
                    rep_time: 1.5
                    zone: "Full Body"
                },
                ListElement {
                    module_id: 0
                    s_order: 0
                    module_name: "Mountain Climbers"
                    quantity: 15
                    unit: "Rep."
                    unit_type: 1
                    default_type: 1
                    is_default: true
                    met_factor: 0.1
                    fatigue_rate: 1.0
                    rep_time: 1.5
                    zone: "Full Body"
                }
            ]
        }
        ListElement {
            subsystem_id: 3
            modules: [
                ListElement {
                    module_id: 0
                    s_order: 0
                    module_name: "Burpees"
                    quantity: 15
                    unit: "Rep."
                    unit_type: 1
                    default_type: 1
                    is_default: true
                    met_factor: 0.1
                    fatigue_rate: 1.0
                    rep_time: 1.5
                    zone: "Full Body"
                },
                ListElement {
                    module_id: 0
                    s_order: 0
                    module_name: "Mountain Climbers"
                    quantity: 15
                    unit: "Rep."
                    unit_type: 1
                    default_type: 1
                    is_default: true
                    met_factor: 0.1
                    fatigue_rate: 1.0
                    rep_time: 1.5
                    zone: "Full Body"
                }
            ]
        }
    }

    // Drag & Drop signals: they ONLY carry the source item and the target position.
    // All decision-making (comparisons, model.move/remove/insert, etc.) lives in
    // ProtocolEditor.qml, never in this .ui.qml file.
    signal subsystemSwapRequested(var sourceItem, int targetIndex)
    signal subsystemRemove(int targetSubsystemIndex)
    signal subsystemClone(int targetSubsystemIndex)
    signal moduleRemove(int targetSubsystemIndex, int targetModuleIndex)
    signal moduleHoverSwapRequested(var sourceItem, int targetSubsystemIndex, int targetModuleIndex)
    signal moduleDropped(var sourceItem, int targetSubsystemIndex, int targetModuleIndex)
    signal refreshRequest

    Column {
        id: contentLayout
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 25

        // 1. SECTION HEADER
        RowLayout {
            width: parent.width
            NeonText {
                label: qsTr(" PROTOCOL ")
                labelColor: root.accentColor
                font.family: Constants.mainFont.family
                font.pixelSize: 14
                font.letterSpacing: 2
                cornerWidth: 2
            }
            // Action Buttons (Right Aligned)
            Item {
                width: 90
                height: 60
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Row {
                    // anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    // Edit Icon (Radio Select logic in Logic file)
                    Rectangle {
                        width: 35
                        height: 35
                        color: "transparent"
                        border.color: "transparent"
                        visible: !isAllDirty
                        Rectangle {
                            id: cloneItem
                            anchors.fill: parent
                            border.color: Constants.secondaryColor
                            opacity: cloneButton.pressed ? 0.2 : (cloneButton.containsMouse ? 1.0 : 0.5)
                            color: cloneButton.pressed ? Constants.primaryColor : "transparent"
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                            NeonIcon {
                                anchors.centerIn: parent
                                glyph: Constants.cloneIcon
                                size: 18
                                color: Constants.secondaryColor
                            }
                            MouseArea {
                                id: cloneButton
                                anchors.fill: parent
                                hoverEnabled: true
                                visible: !isAllDirty
                            }
                        }
                    }

                    // Edit Icon (Radio Select logic in Logic file)
                    Rectangle {
                        width: 35
                        height: 35
                        color: "transparent"
                        border.color: "transparent"
                        visible: isAllDirty
                        Rectangle {
                            id: saveItem
                            anchors.fill: parent
                            border.color: isAllDirty ? root.accentColor : Constants.descriptionColor
                            opacity: (saveButton.pressed
                                      && isAllDirty) ? 0.2 : ((saveButton.containsMouse
                                                               && isAllDirty) ? 1.0 : 0.5)
                            color: (saveButton.pressed
                                    && isAllDirty) ? Constants.primaryColor : "transparent"
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                            NeonIcon {
                                anchors.centerIn: parent
                                glyph: Constants.saveIcon
                                size: 18
                                color: isAllDirty ? root.accentColor : Constants.descriptionColor
                            }
                            MouseArea {
                                id: saveButton
                                anchors.fill: parent
                                hoverEnabled: true
                                visible: isAllDirty
                            }
                        }
                    }

                    Rectangle {
                        width: 35
                        height: 35
                        color: "transparent"
                        border.color: "transparent"
                        // Delete Icon (Neon Red)
                        Rectangle {
                            id: deleteItem
                            anchors.fill: parent
                            border.color: Constants.rootColor
                            opacity: deleteButton.pressed ? 0.2 : (deleteButton.containsMouse ? 1.0 : 0.5)
                            color: deleteButton.pressed ? Constants.primaryColor : "transparent"
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }
                            NeonIcon {
                                anchors.centerIn: parent
                                glyph: Constants.trashIcon
                                size: 18
                                color: Constants.rootColor
                            }
                            MouseArea {
                                id: deleteButton
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }

        // 3. CORE METADATA (Name & Rank)
        ColumnLayout {
            width: parent.width
            spacing: 20

            NeonTextField {
                id: nameField
                width: parent.width
                text: "INFERNO_SEQUENCE"
                label: qsTr("PROTOCOL_NAME")
                // isDirty: root.isDirty
            }

            NeonSelector {
                id: rankSelector
                width: parent.width
                option1Label: "NEWBIE"
                option2Label: "ADVANCED"
                option3Label: "ROOT"
                selectedIndex: root.selectedRank
                label: qsTr("RANK_CLASSIFICATION")
            }

            // 4. DIRECTIVE MAPPING GRID
            Column {
                width: parent.width
                spacing: 8
                Text {
                    text: qsTr("DIRECTIVE_MAPPING_GRID")
                    color: Constants.primaryTextColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }

                Flow {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: directiveModel
                        delegate: NeonBadge {
                            id: directiveBadge
                            size: 40
                            glyph: model.icon
                            color: model.color
                            unlocked: root.directiveList.indexOf(
                                          model.id) !== -1
                            MouseArea {
                                id: directiveBadgeButton
                                anchors.fill: parent
                            }
                            Connections {
                                target: directiveBadgeButton
                                function onClicked() {
                                    toggleDirective(model)
                                    directiveBadge.unlocked = !directiveBadge.unlocked
                                }
                            }
                        }
                    }
                }
            }
        }

        // 5. SEQUENCE EDITOR // TIMELINE
        Column {
            width: parent.width
            spacing: 15

            RowLayout {
                width: parent.width
                height: 15
                Text {
                    text: qsTr("SEQUENCE_EDITOR")
                    color: Constants.primaryTextColor
                    font.family: Constants.mainFont.family
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                Text {
                    text: subsystemModel.count + " ENTRIES"
                    // anchors.right: parent.right
                    color: Constants.descriptionColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    opacity: 0.7
                }
            }

            // Subsystem entry list
            ListView {
                id: subsystemListView
                width: parent.width
                height: contentHeight
                interactive: false // the page itself scrolls; this list only reorders
                clip: false
                spacing: 2
                model: subsystemModel

                move: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                delegate: Rectangle {
                    id: subsystemWrapper
                    width: ListView.view.width
                    // height: protocolLayout.height + 5
                    height: moduleListView.height + 60 + root.layoutVersion
                    color: "transparent"
                    border.color: Constants.primaryColor
                    border.width: 1

                    // --- DRAG & DROP: subsystem block ---
                    readonly property int subsystemIndex: index
                    property bool dragActive: subsystemDragArea.drag.active

                    property alias buttonDeleteSubsystem: buttonDeleteSubsystem

                    z: dragActive ? 99 : 1
                    opacity: dragActive ? 0.85 : 1.0
                    scale: dragActive ? 1.015 : 1.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }

                    Drag.active: subsystemDragArea.drag.active
                    Drag.source: subsystemWrapper
                    Drag.keys: ["subsystem"]
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: 20

                    // Live swap: as soon as the dragged block enters another
                    // subsystem's area, request an exchange (real move, not absolute drop)
                    DropArea {
                        id: subsystemDropArea
                        anchors.fill: parent
                        keys: ["subsystem"]
                    }

                    // Drop zone for a module coming from another subsystem
                    // (e.g. dropped on the header, when the target subsystem still has no visible modules)
                    DropArea {
                        id: subsystemHeaderModuleDropArea
                        anchors.fill: parent
                        keys: ["module"]
                    }

                    // Signal handling must go through Connections in a .ui.qml file
                    Connections {
                        target: subsystemDropArea
                        function onEntered(drag) {
                            root.subsystemSwapRequested(
                                        drag.source,
                                        subsystemWrapper.subsystemIndex)
                        }
                    }

                    Connections {
                        target: subsystemHeaderModuleDropArea
                        function onDropped(drop) {
                            root.moduleDropped(drop.source,
                                               subsystemWrapper.subsystemIndex,
                                               0)
                        }
                    }

                    ColumnLayout {
                        id: protocolLayout
                        width: parent.width
                        // Subsystem Header
                        Rectangle {
                            id: subsystemItem
                            width: parent.width
                            height: subsystemLayout.implicitHeight
                            color: Constants.primaryDarkColor // Dark
                            border.color: Constants.primaryColor
                            border.width: 1

                            RowLayout {
                                id: subsystemLayout
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                NeonIcon {
                                    glyph: Constants.gripIcon
                                    size: 14
                                    color: Constants.primaryColor
                                    Layout.alignment: Qt.AlignVCenter
                                    MouseArea {
                                        id: subsystemDragArea
                                        anchors.fill: parent
                                        anchors.margins: -6 // larger touch/hit area
                                        cursorShape: Qt.SizeAllCursor
                                        drag.target: subsystemWrapper
                                        drag.axis: Drag.YAxis
                                    }
                                } // Grip icon
                                Text {
                                    text: qsTr("SUBSYSTEM_") + subsystem_id
                                    color: Constants.primaryColor
                                    font.family: Constants.mainFont.family
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Rectangle {
                                    width: 30
                                    height: width
                                    color: Constants.surfaceColor
                                    border.color: Constants.primaryColor
                                    opacity: buttonCloneSubsystem.pressed ? 0.5 : 1
                                    NeonIcon {
                                        glyph: Constants.cloneIcon
                                        size: 14
                                        color: Constants.primaryColor
                                        anchors.centerIn: parent
                                        MouseArea {
                                            id: buttonCloneSubsystem
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    }
                                } // Clone icon
                                Rectangle {
                                    width: 30
                                    height: width
                                    color: Constants.surfaceColor
                                    border.color: Constants.primaryColor
                                    opacity: buttonDeleteSubsystem.pressed ? 0.5 : 1
                                    NeonIcon {
                                        glyph: Constants.cancelIcon
                                        size: 14
                                        color: Constants.primaryColor
                                        anchors.centerIn: parent
                                        MouseArea {
                                            id: buttonDeleteSubsystem
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    }
                                } // X icon
                            }
                        } // subsystemItem

                        Connections {
                            target: subsystemDragArea
                            function onReleased() {
                                subsystemWrapper.Drag.drop()
                                refreshRequest()
                            }
                        }

                        Connections {
                            target: buttonCloneSubsystem
                            function onClicked() {
                                root.subsystemClone(
                                            subsystemWrapper.subsystemIndex)
                                // root.protocolListView.forceLayout()
                            }
                        }

                        Connections {
                            target: buttonDeleteSubsystem
                            function onClicked() {
                                root.subsystemRemove(
                                            subsystemWrapper.subsystemIndex)
                                // root.protocolListView.forceLayout()
                            }
                        }

                        // Module list of this subsystem
                        ListView {
                            id: moduleListView
                            Layout.fillWidth: true
                            height: contentHeight
                            interactive: false
                            clip: false
                            spacing: 0
                            model: modules

                            move: Transition {
                                NumberAnimation {
                                    properties: "y"
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            displaced: Transition {
                                NumberAnimation {
                                    properties: "y"
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            delegate: Rectangle {
                                id: moduleItem
                                width: ListView.view.width * 0.98
                                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                                height: 60

                                // Visual state: border highlight replaces scale (scale causes
                                // layout recalculation in siblings → jitter)
                                color: Constants.deepColor
                                border.color: dragActive ? root.accentColor : Constants.secondaryColor
                                border.width: dragActive ? 2 : 1
                                Behavior on border.color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }

                                // --- DRAG & DROP: individual module ---
                                readonly property int subsystemIndex: subsystemWrapper.subsystemIndex
                                readonly property int moduleIndex: index
                                property bool dragActive: gripMouseArea.drag.active

                                z: dragActive ? 99 : 1
                                opacity: dragActive ? 0.80 : 1.0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                Drag.active: gripMouseArea.drag.active
                                Drag.source: moduleItem
                                Drag.keys: ["module"]
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2

                                // Threshold-based DropArea:
                                // Direction is determined by WHERE the hotspot physically enters
                                // the DropArea (not by model index comparison, which can be stale
                                // immediately after a ListModel.move() call).
                                // swapDone prevents re-triggering the same swap while still hovering.
                                DropArea {
                                    id: moduleDropArea
                                    anchors.fill: parent
                                    keys: ["module"]
                                    property bool swapDone: false
                                    property bool enteredFromAbove: true
                                }

                                Connections {
                                    target: moduleDropArea

                                    function onEntered(drag) {
                                        // Never react to the item dragging into itself
                                        if (drag.source === moduleItem)
                                            return
                                        moduleDropArea.swapDone = false
                                        // Record physical entry direction from the hotspot position
                                        moduleDropArea.enteredFromAbove = drag.y
                                                < moduleItem.height * 0.5
                                        // Fire immediately if entry point is already past the midpoint
                                        var mid = moduleItem.height * 0.5
                                        if (moduleDropArea.enteredFromAbove ? drag.y > mid : drag.y < mid) {
                                            moduleDropArea.swapDone = true
                                            root.moduleHoverSwapRequested(
                                                        drag.source,
                                                        moduleItem.subsystemIndex,
                                                        moduleItem.moduleIndex)
                                        }
                                    }

                                    // Catches the midpoint crossing when the drag moves slowly inside
                                    function onPositionChanged(drag) {
                                        if (drag.source === moduleItem)
                                            return
                                        if (moduleDropArea.swapDone)
                                            return
                                        var mid = moduleItem.height * 0.5
                                        if (moduleDropArea.enteredFromAbove ? drag.y > mid : drag.y < mid) {
                                            moduleDropArea.swapDone = true
                                            root.moduleHoverSwapRequested(
                                                        drag.source,
                                                        moduleItem.subsystemIndex,
                                                        moduleItem.moduleIndex)
                                        }
                                    }

                                    function onExited() {
                                        moduleDropArea.swapDone = false
                                    }

                                    // Cross-subsystem final resolution on release
                                    function onDropped(drop) {
                                        root.moduleDropped(
                                                    drop.source,
                                                    moduleItem.subsystemIndex,
                                                    moduleItem.moduleIndex)
                                        moduleDropArea.swapDone = false
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 5

                                    NeonIcon {
                                        glyph: Constants.gripIcon
                                        size: 14
                                        color: Constants.descriptionColor
                                        opacity: 0.5
                                        MouseArea {
                                            id: gripMouseArea
                                            anchors.fill: parent
                                            anchors.margins: -6
                                            cursorShape: Qt.SizeAllCursor
                                            drag.target: moduleItem
                                            drag.axis: Drag.YAxis
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        Text {
                                            text: model.module_name
                                            width: 140
                                            color: Constants.primaryTextColor
                                            font.family: Constants.techFont.family
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: model.zone + " · MET: " + model.met_factor
                                            color: Constants.descriptionColor
                                            opacity: 0.5
                                            font.family: Constants.techFont.family
                                            font.pixelSize: 12
                                            width: 140
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // Quantity Input
                                    Rectangle {
                                        width: 40
                                        height: 30
                                        color: Constants.surfaceColor
                                        border.color: Constants.primaryTextColor
                                        TextInput {
                                            id: quantityField
                                            text: quantity
                                            color: Constants.primaryTextColor
                                            anchors.centerIn: parent
                                            font.family: Constants.techFont.family
                                            font.pixelSize: 18
                                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                                            validator: IntValidator {
                                                bottom: 0
                                                top: 9999
                                            }
                                        }
                                    }
                                    // State Toggle
                                    Rectangle {
                                        width: 30
                                        height: 20
                                        color: Constants.primaryTextColor
                                        radius: 2
                                        Layout.alignment: Qt.AlignVCenter
                                        property bool isDefault: is_default
                                        Text {
                                            text: parent.isDefault ? unit : "Sec."
                                            color: Constants.deepColor
                                            anchors.centerIn: parent
                                            font.family: Constants.mainFont.family
                                            font.bold: false
                                            font.pixelSize: 12
                                        }
                                        MouseArea {
                                            id: unitType
                                            anchors.fill: parent
                                        }
                                    }

                                    Rectangle {
                                        width: 30
                                        height: width
                                        color: Constants.surfaceColor
                                        border.color: Constants.rootColor
                                        opacity: buttonDeleteModule.containsMouse ? 1 : 0.5
                                        NeonIcon {
                                            glyph: Constants.cancelIcon
                                            size: 16
                                            color: Constants.rootColor
                                            anchors.centerIn: parent
                                        }
                                        MouseArea {
                                            id: buttonDeleteModule
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    } // Delete
                                }

                                Connections {
                                    target: gripMouseArea
                                    function onReleased() {
                                        moduleItem.Drag.drop()
                                        refreshRequest()
                                    }
                                }

                                Connections {
                                    target: buttonDeleteModule
                                    function onClicked() {
                                        root.moduleRemove(
                                                    moduleItem.subsystemIndex,
                                                    moduleItem.moduleIndex)
                                    }
                                }

                                Connections {
                                    target: unitType
                                    function onClicked() {
                                        isStructureDirty = true
                                        is_default = !is_default
                                    }
                                }

                                Connections {
                                    target: quantityField
                                    function onTextChanged() {
                                        if (systemManager.systemReady) {
                                            isStructureDirty = true
                                            let val = parseInt(
                                                    quantityField.text)
                                            if (!isNaN(val)) {
                                                model.quantity = val
                                            }
                                        }
                                    }
                                }
                            } // moduleItem delegate
                        } // moduleListView

                        // Drop zone at the end of the subsystem list (append)
                        Item {
                            id: moduleDropFooter
                            Layout.fillWidth: true
                            height: 14
                            DropArea {
                                id: footerDropArea
                                anchors.fill: parent
                                anchors.margins: -6
                                keys: ["module"]
                            }
                            Connections {
                                target: footerDropArea
                                function onDropped(drop) {
                                    root.moduleDropped(
                                                drop.source,
                                                subsystemWrapper.subsystemIndex,
                                                moduleListView.count)
                                }
                            }
                        }
                    } // protocolLayout
                } // subsystemWrapper delegate
            } // subsystemListView

            // ADD SUBSYSTEM BUTTON
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                property real borderOpacity: addSubsystem.pressed ? 1 : 0.5

                // border.style: "Dashed" // Simplified for UI file representation
                Text {
                    text: qsTr("+ ADD_SUBSYSTEM")
                    color: Constants.primaryColor
                    anchors.centerIn: parent
                    font.family: Constants.techFont.family
                    font.pixelSize: 14
                }
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Constants.primaryColor
                    border.width: 1
                    opacity: parent.borderOpacity
                }

                MouseArea {
                    id: addSubsystem
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
