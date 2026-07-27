import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import ".."
import "."


/*
   ModuleEditorView.ui.qml
   Module Editor Component
   Modular item for the Module List (Architect Suite)
   It can search create and delete
*/
Item {
    id: root

    width: Constants.designWidth * 0.9
    height: mainLayout.implicitHeight

    // Data connection properties
    property alias searchInput: searchInput
    property alias moduleList: moduleList
    property alias moduleDataModel: moduleDataModel
    property int moduleCount: 0
    property bool searchMode: true

    // ModuleFactory aliases
    property alias moduleFactory: moduleFactory
    property alias moduleNameField: moduleNameField
    property alias unitCombo: unitCombo
    property alias targetZoneCombo: targetZoneCombo
    property alias difficultyCombo: difficultyCombo
    property alias repTimeField: repTimeField
    property alias metFactorField: metFactorField
    property alias fatigueRateField: fatigueRateField
    property alias moduleDescriptionField: moduleDescriptionField
    property alias instructionsField: instructionsField
    property alias safetyField: safetyField
    property alias equipmentField: equipmentField


    /*
     * Local buffer model for module management.
     * Roles are mapped to match the C++ ModuleModel structure.
     */
    ListModel {
        id: moduleDataModel

        // Sample entry based on system init data
        ListElement {
            module_id: 2
            module_name: "BURPEES"
            zone: "FULL_BODY"
            difficulty: 2
            description: "Plank, push-up and jump sequence."
            instructions: ""
            safety: ""
            equipment: ""
            unit: "Rep."
            unit_type: 1
            rep_time: 3.7
            met_factor: 11.0
            fatigue_rate: 6.5
        }

        ListElement {
            module_id: 1
            module_name: "REST"
            zone: "REST"
            difficulty: 0
            description: "Active or passive recovery period."
            instructions: ""
            safety: ""
            equipment: ""
            unit: "Sec."
            unit_type: 0
            rep_time: 1.0
            met_factor: 1.0
            fatigue_rate: 0.8
        }
    }

    Column {
        id: mainLayout
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        // SEARCH INTERFACE
        NeonTextField {
            id: searchInput
            width: parent.width
            placeholder: "> SEARCH_MODULE_REGISTRY"
            // icon glyph for search: \ue151
        }

        // 3. MASTER MODULE LIST
        Column {
            width: parent.width
            spacing: 0
            visible: searchMode

            Repeater {
                id: moduleList
                model: moduleDataModel

                delegate: Rectangle {
                    id: moduleRow
                    width: mainLayout.width
                    height: 60
                    color: Constants.deepColor
                    border.color: Constants.secondaryColor
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        // Module Primary Info
                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: model.module_name
                                color: Constants.primaryTextColor
                                font.family: Constants.mainFont.family
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                // Meta string: ZONE · MET · UNIT
                                text: model.zone + " · MET:" + model.met_factor + " · " + model.unit
                                color: Constants.descriptionColor
                                opacity: 0.6
                                font.family: Constants.techFont.family
                                font.pixelSize: 11
                            }
                        }

                        // CRUD Action Buttons
                        Row {
                            spacing: 5

                            // ADD TO SEQUENCE (+)
                            MouseArea {
                                id: insertModuleButton
                                width: 30
                                height: 30
                                hoverEnabled: true
                                NeonIcon {
                                    glyph: Constants.addIcon
                                    size: 18
                                    color: Constants.primaryTextColor
                                    anchors.centerIn: parent
                                    opacity: !parent.containsMouse ? 0.6 : (parent.pressed ? 0.3 : 1)
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    border.color: Constants.secondaryColor
                                    color: "transparent"
                                    opacity: 0.5
                                }
                            }

                            // EDIT MASTER DATA (Pencil)
                            MouseArea {
                                id: editModuleButton
                                width: 30
                                height: 30
                                hoverEnabled: true
                                NeonIcon {
                                    glyph: Constants.pencilIcon
                                    size: 18
                                    color: Constants.primaryTextColor
                                    anchors.centerIn: parent
                                    opacity: !parent.containsMouse ? 0.6 : (parent.pressed ? 0.3 : 1)
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    border.color: Constants.secondaryColor
                                    color: "transparent"
                                    opacity: 0.5
                                }
                            }

                            // DELETE FROM REGISTRY (Trash - Neon Red)
                            MouseArea {
                                id: deleteModuleButton
                                width: 30
                                height: 30
                                hoverEnabled: true
                                NeonIcon {
                                    glyph: Constants.trashIcon
                                    size: 18
                                    color: Constants.rootColor
                                    anchors.centerIn: parent
                                    opacity: !parent.containsMouse ? 0.6 : (parent.pressed ? 0.3 : 1)
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    border.color: Constants.rootColor
                                    color: "transparent"
                                    opacity: 0.5
                                }
                            }
                        }
                    }
                    Connections {
                        target: insertModuleButton
                        function onClicked() {
                            root.insertModule(index, model)
                        }
                    }
                    Connections {
                        target: editModuleButton
                        function onClicked() {
                            root.editModule(index, model)
                        }
                    }
                    Connections {
                        target: deleteModuleButton
                        function onClicked() {
                            root.requestDeleteModule(index, model)
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 10
            }

            Rectangle {
                id: addModuleBox
                width: parent.width
                height: 60
                color: Constants.surfaceColor
                border.color: Constants.secondaryColor
                border.width: 1

                // VISIBILITY_LOGIC: Text must not be empty AND no exact match found
                visible: searchInput.text !== "" && !root.exactMatchFound

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 12

                    Text {
                        text: "+"
                        color: Constants.secondaryTextColor
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            text: "REGISTER_NEW_MODULE"
                            color: Constants.secondaryTextColor
                            font.pixelSize: 12
                            font.family: Constants.mainFont.family
                        }

                        Text {
                            text: searchInput.text
                            color: Constants.secondaryTextColor
                            font.pixelSize: 16
                            font.family: Constants.mainFont.family
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: addModuleAction
                    anchors.fill: parent
                    onClicked: searchMode = false
                }
            }
        }

        Rectangle {
            id: moduleFactory
            width: parent.width
            height: factoryLayout.implicitHeight + 40
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !searchMode
            color: Constants.deepColor
            border.color: Constants.primaryColor
            border.width: 1
            property int moduleId: -1

            // Internal margins for the industrial frame
            Column {
                id: factoryLayout
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                // 1. HEADER: Warning Icon + Title
                Row {
                    height: 25
                    NeonIcon {
                        glyph: Constants.alertIcon
                        size: 16
                        color: Constants.secondaryTextColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "MODULE_FACTORY"
                        color: Constants.secondaryTextColor
                        font.family: Constants.mainFont.family
                        font.pixelSize: 11
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // 2. INPUT: MODULE_NAME
                Column {
                    width: parent.width
                    spacing: 8
                    NeonTextField {
                        id: moduleNameField
                        width: parent.width
                        placeholder: "> ENTER_NAME"
                        label: "MODULE_NAME"
                        neonColor: Constants.primaryColor
                        labelColor: Constants.primaryTextColor
                        text: searchInput.text
                    }
                }

                // 3. SELECTION ROW: UNIT_TYPE, MET_FACTOR, TARGET_ZONE
                RowLayout {
                    width: parent.width
                    spacing: 15

                    // UNIT_TYPE Selector
                    Column {
                        Layout.preferredWidth: 100
                        spacing: 8
                        Text {
                            text: "UNIT"
                            color: Constants.primaryTextColor
                            font.family: Constants.techFont.family
                            font.pixelSize: 11
                        }

                        NeonCombo {
                            id: unitCombo
                            width: parent.width
                            model: unitModel // Loads ["SECONDS", "REPS", "METERS"] [1]
                            currentIndex: 1 // Defaults to REPS as per mockup [2]
                        }
                    }

                    // DIFFICULTY Selector
                    Column {
                        Layout.preferredWidth: 60
                        spacing: 8
                        Text {
                            text: "DIFFICULTY"
                            color: Constants.primaryTextColor
                            font.family: Constants.techFont.family
                            font.pixelSize: 11
                        }
                        NeonCombo {
                            id: difficultyCombo
                            width: parent.width
                            model: ["1", "2", "3"]
                            currentIndex: 1 // Defaults to REPS as per mockup [2]
                        }
                    }

                    // TARGET_ZONE Selector
                    Column {
                        Layout.preferredWidth: 100
                        spacing: 8
                        Text {
                            text: "TARGET_ZONE"
                            color: Constants.primaryTextColor
                            font.family: Constants.techFont.family
                            font.pixelSize: 11
                        }
                        NeonCombo {
                            id: targetZoneCombo
                            width: parent.width
                            model: zoneModel
                            currentIndex: 1 // Defaults to REPS as per mockup [2]
                        }
                    }
                }

                // SELECTION ROW: REP_TIME, MET_FACTOR, FATIGUE_RATE
                RowLayout {
                    width: parent.width
                    spacing: 15

                    // REP_TIME Selector
                    Column {
                        Layout.preferredWidth: 100
                        NeonTextField {
                            id: repTimeField
                            width: parent.width
                            placeholder: "> VALUE"
                            label: "REP_TIME"
                            neonColor: Constants.primaryColor
                            labelColor: Constants.primaryTextColor
                            textInput.validator: DoubleValidator {
                                bottom: 0
                                top: 40
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                                locale: "C"
                            }
                        }
                    }

                    // MET_FACTOR
                    Column {
                        Layout.fillWidth: true
                        spacing: 8
                        NeonTextField {
                            id: metFactorField
                            width: 50
                            text: "3.2"
                            label: "MET"
                            anchors.horizontalCenter: parent.horizontalCenter
                            neonColor: Constants.primaryColor
                            // Uses fuchsiaNeon for the +/- buttons as per mockup [1]
                            textInput.validator: DoubleValidator {
                                bottom: -2.0
                                top: 20
                                decimals: 1
                                notation: DoubleValidator.StandardNotation
                                locale: "C"
                            }
                        }
                    }

                    // FATIGUE_RATE
                    Column {
                        Layout.preferredWidth: 100
                        NeonTextField {
                            id: fatigueRateField
                            width: parent.width
                            placeholder: "> VALUE"
                            label: "FATIGUE_RATE"
                            neonColor: Constants.primaryColor
                            labelColor: Constants.primaryTextColor
                            textInput.validator: DoubleValidator {
                                bottom: -2.0
                                top: 20
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                                locale: "C"
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 15
                    NeonTextField {
                        id: moduleDescriptionField
                        width: parent.width
                        placeholder: "> ENTER_DESCRIPTION"
                        label: "DESCRIPTION"
                        neonColor: Constants.primaryColor
                        labelColor: Constants.primaryTextColor
                    }
                    NeonTextField {
                        id: instructionsField
                        width: parent.width
                        placeholder: "> ENTER_INSTRUCTIONS"
                        label: "INSTRUCTIONS"
                        neonColor: Constants.primaryColor
                        labelColor: Constants.primaryTextColor
                    }
                    NeonTextField {
                        id: safetyField
                        width: parent.width
                        placeholder: "> ENTER_SAFETY"
                        label: "SAFETY"
                        neonColor: Constants.primaryColor
                        labelColor: Constants.primaryTextColor
                    }
                    NeonTextField {
                        id: equipmentField
                        width: parent.width
                        placeholder: "> ENTER_EQUIPMENT"
                        label: "EQUIPMENT"
                        neonColor: Constants.primaryColor
                        labelColor: Constants.primaryTextColor
                        text: "NONE"
                    }
                }

                // ACTION ROW: REGISTER & ABORT
                RowLayout {
                    width: parent.width
                    height: 45
                    spacing: 10

                    // MAIN ACTION: REGISTER_MODULE
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: Constants.primaryColor
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            // anchors.verticalCenter: parent.verticalCenter
                            spacing: 0
                            NeonIcon {
                                glyph: Constants.confirmIcon
                                size: 14
                                color: Constants.primaryColor
                            } // check glyph [7]
                            Text {
                                text: "REGISTER_MODULE"
                                color: Constants.primaryColor
                                font.family: Constants.mainFont.family
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: saveModuleButton
                            anchors.fill: parent
                            // onClicked: console.log("Committing module to master registry...")
                        }
                        Connections {
                            target: saveModuleButton
                            function onClicked() {
                                root.saveModule(moduleFactory.moduleId)
                            }
                        }
                    }

                    // CANCEL ACTION: ABORT
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.fillHeight: true
                        color: Constants.primaryDarkColor
                        border.color: Constants.primaryColor
                        opacity: 0.8

                        Text {
                            text: "ABORT"
                            anchors.centerIn: parent
                            color: Constants.primaryColor
                            font.family: Constants.mainFont.family
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: searchMode = true
                        }
                    }
                }
            }
        }
    }
}
