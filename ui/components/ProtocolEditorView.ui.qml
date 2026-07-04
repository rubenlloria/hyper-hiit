
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

    property bool isDirty: false // state for unsaved changes
    property bool isReady: systemManager.systemReady
    property color accentColor: Constants.primaryColor // Default Protocol Color

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

    ListModel {
        id: subsystemModel
        ListElement {
            subsystem_id: 1
            modules: [
                ListElement {
                    module_name: "Burpees"
                    quantity: 15
                    unit: "Rep."
                    met_factor: 0.1
                    zone: "Full Body"
                },
                ListElement {
                    module_name: "Mountain Climbers"
                    quantity: 15
                    unit: "Rep."
                    met_factor: 0.1
                    zone: "Full Body"
                }
            ]
        }
        ListElement {
            subsystem_id: 2
            modules: [
                ListElement {
                    module_name: "Burpees"
                    quantity: 15
                    unit: "Rep."
                    met_factor: 0.1
                    zone: "Full Body"
                },
                ListElement {
                    module_name: "Mountain Climbers"
                    quantity: 15
                    unit: "Rep."
                    met_factor: 0.1
                    zone: "Full Body"
                }
            ]
        }
        ListElement {
            subsystem_id: 3
            modules: [
                ListElement {
                    module_name: "Burpees"
                    quantity: 15
                    unit: "Rep."
                    met_factor: 0.1
                    zone: "Full Body"
                },
                ListElement {
                    module_name: "Mountain Climbers"
                    quantity: 15
                    unit: "Rep."
                    met_factor: 0.1
                    zone: "Full Body"
                }
            ]
        }
    }

    // Drag & Drop signals: they ONLY carry the source item and the target position.
    // All decision-making (comparisons, model.move/remove/insert, etc.) lives in
    // ProtocolEditor.qml, never in this .ui.qml file.
    signal subsystemSwapRequested(var sourceItem, int targetIndex)
    signal subsystemDelete(int targetSubsystemIndex)
    signal moduleDelete(int targetSubsystemIndex, int targetModuleIndex)
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
                label: " PROTOCOL_BUILDER "
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
                        Rectangle {
                            id: saveItem
                            anchors.fill: parent
                            border.color: isDirty ? root.accentColor : Constants.descriptionColor
                            opacity: (saveButton.pressed
                                      && isDirty) ? 0.2 : ((saveButton.containsMouse
                                                            && isDirty) ? 1.0 : 0.5)
                            color: (saveButton.pressed
                                    && isDirty) ? Constants.primaryColor : "transparent"
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                            NeonIcon {
                                anchors.centerIn: parent
                                glyph: Constants.saveIcon
                                size: 18
                                color: isDirty ? root.accentColor : Constants.descriptionColor
                            }
                            MouseArea {
                                id: saveButton
                                anchors.fill: parent
                                hoverEnabled: true
                                visible: isDirty
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
                                    duration: 150
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
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
                label: "PROTOCOL_NAME"
                // isDirty: root.isDirty
            }

            NeonSelector {
                id: rankSelector
                width: parent.width
                option1Label: "NEWBIE"
                option2Label: "ADVANCED"
                option3Label: "ROOT"
                selectedIndex: root.selectedRank
                label: "RANK_CLASSIFICATION"
            }

            // 4. DIRECTIVE MAPPING GRID
            Column {
                width: parent.width
                spacing: 8
                Text {
                    text: "DIRECTIVE_MAPPING_GRID (Not implemented)"
                    color: Constants.primaryTextColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }

                Flow {
                    width: parent.width
                    spacing: 10
                    // Example of multi-selection tags
                    NeonBadge {
                        size: 40
                        glyph: Constants.flameIcon
                        color: Constants.primaryColor
                        unlocked: false
                    }
                    NeonBadge {
                        size: 40
                        glyph: Constants.heartIcon
                        color: Constants.primaryColor
                        unlocked: false
                    } // CARDIO
                    NeonBadge {
                        size: 40
                        glyph: Constants.zapIcon
                        color: Constants.primaryColor
                        unlocked: false
                    } // STRENGTH
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
                    text: "SEQUENCE_EDITOR // TIMELINE"
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
                                    text: "SUBSYSTEM_" + subsystem_id
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
                                    opacity: buttonDeleteSubsystem.pressed ? 0.5 : 1
                                    NeonIcon {
                                        glyph: "\ue1b2"
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
                            target: buttonDeleteSubsystem
                            function onClicked() {
                                root.subsystemDelete(
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
                                // Layout.alignment: Qt.AlignHCenter
                                height: 60
                                color: Constants.deepColor
                                border.color: Constants.secondaryColor
                                border.width: 1

                                // --- DRAG & DROP: individual module ---
                                readonly property int subsystemIndex: subsystemWrapper.subsystemIndex
                                readonly property int moduleIndex: index
                                property bool dragActive: gripMouseArea.drag.active

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

                                Drag.active: gripMouseArea.drag.active
                                Drag.source: moduleItem
                                Drag.keys: ["module"]
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2

                                // Live swap while hovering another module of the SAME subsystem,
                                // final move/transfer resolved on drop (covers cross-subsystem moves)
                                DropArea {
                                    id: moduleDropArea
                                    anchors.fill: parent
                                    keys: ["module"]
                                }

                                Connections {
                                    target: moduleDropArea
                                    function onEntered(drag) {
                                        root.moduleHoverSwapRequested(
                                                    drag.source,
                                                    moduleItem.subsystemIndex,
                                                    moduleItem.moduleIndex)
                                    }
                                    function onDropped(drop) {
                                        root.moduleDropped(
                                                    drop.source,
                                                    moduleItem.subsystemIndex,
                                                    moduleItem.moduleIndex)
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
                                            id: quantityInput
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
                                        property bool isDefault: true
                                        Text {
                                            text: parent.isDefault ? unit : "Sec."
                                            color: Constants.deepColor
                                            anchors.centerIn: parent
                                            font.family: Constants.mainFont.family
                                            font.bold: true
                                            font.pixelSize: 9
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: parent.isDefault = !parent.isDefault
                                        }
                                    }

                                    Rectangle {
                                        width: 30
                                        height: width
                                        color: Constants.surfaceColor
                                        border.color: Constants.rootColor
                                        opacity: buttonDeleteModule.containsMouse ? 1 : 0.5
                                        NeonIcon {
                                            glyph: "\ue18e"
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
                                        root.moduleDelete(
                                                    moduleItem.subsystemIndex,
                                                    moduleItem.moduleIndex)
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
                    text: "+ ADD_SUBSYSTEM"
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
