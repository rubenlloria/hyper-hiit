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


    /*
     * Local buffer model for module management.
     * Roles are mapped to match the C++ ModuleModel structure.
     */
    ListModel {
        id: moduleDataModel

        // Sample entry based on system init data
        ListElement {
            module_id: 2
            name: "BURPEES"
            target_zone: "FULL_BODY"
            difficulty: 2
            description: "Plank, push-up and jump sequence."
            unit_type: 1 // 1: REPS
            rep_time: 3.7
            met_factor: 11.0
            fatigue_rate: 6.5
        }

        ListElement {
            module_id: 1
            name: "REST"
            target_zone: "REST"
            difficulty: 0
            description: "Active or passive recovery period."
            unit_type: 0 // 0: SECONDS
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
                    color: "#0d0d10"
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
                                text: model.name
                                color: Constants.primaryTextColor
                                font.family: Constants.mainFont.family
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                // Meta string: ZONE · MET · UNIT_TYPE
                                text: model.targetZone + " · MET:" + model.metFactor + " · "
                                      + (model.unitType === 0 ? "SECONDS" : model.unitType
                                                                === 1 ? "REPETITIONS" : "METERS")
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
                                width: 30
                                height: 30
                                hoverEnabled: true
                                NeonIcon {
                                    glyph: "\ue13d" // TODO: add icon
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
                                id: deleteButton
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
                            text: searchInput.text.toUpperCase()
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

            // Internal margins for the industrial frame
            Column {
                id: factoryLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // 1. HEADER: Warning Icon + Title
                Row {
                    NeonIcon {
                        glyph: "\ue193" // triangle-alert glyph [4]
                        size: 16
                        color: "#bf00ff"
                    }
                    Text {
                        text: "MODULE_FACTORY"
                        color: "#bf00ff"
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
                        id: moduleNameInput
                        width: parent.width
                        placeholder: "> ENTER_NAME"
                        label: "MODULE_NAME"
                        neonColor: Constants.primaryColor
                        text: searchInput.text
                        // The text here would be "burpees" as shown in the mockup [1]
                    }
                }

                // 3. SELECTION ROW: UNIT_TYPE, MET_FACTOR, TARGET_ZONE
                RowLayout {
                    width: parent.width
                    spacing: 15

                    // UNIT_TYPE Selector
                    Column {
                        Layout.preferredWidth: 120
                        spacing: 8
                        Text {
                            text: "UNIT_TYPE"
                            color: Constants.primaryColor
                            font.family: Constants.techFont.family
                            font.pixelSize: 11
                        }

                        NeonCombo {
                            id: unitCombo
                            width: parent.width
                            model: unitModel // Loads ["SECONDS", "REPS", "METERS"] [1]
                            currentIndex: 1 // Defaults to REPS as per mockup [2]
                        }

                        // NeonSelector {
                        //     width: parent.width
                        //     // model: ["SECONDS", "REPS", "METERS"] // Based on technical manual [5]
                        //     selectedIndex: 1 // REPS selected in mockup
                        // }
                    }

                    // MET_FACTOR Stepper
                    Column {
                        Layout.fillWidth: true
                        spacing: 8
                        NeonTextField {
                            id: metField
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
                            }
                        }
                    }

                    // TARGET_ZONE Selector
                    Column {
                        Layout.preferredWidth: 120
                        spacing: 8
                        Text {
                            text: "TARGET_ZONE"
                            color: Constants.primaryColor
                            font.family: Constants.techFont.family
                            font.pixelSize: 11
                        }
                        NeonCombo {
                            width: parent.width
                            model: zoneModel
                            currentIndex: 1 // Defaults to REPS as per mockup [2]
                        }
                    }
                }

                // 4. ACTION ROW: REGISTER & ABORT
                RowLayout {
                    width: parent.width
                    height: 45
                    spacing: 10

                    // MAIN ACTION: REGISTER_MODULE
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: "#bf00ff"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            // anchors.verticalCenter: parent.verticalCenter
                            spacing: 0
                            NeonIcon {
                                glyph: "\ue06c"
                                size: 14
                                color: Constants.primaryColor
                            } // check glyph [7]
                            Text {
                                text: "REGISTER_MODULE"
                                color: "#bf00ff"
                                font.family: Constants.mainFont.family
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            // onClicked: console.log("Committing module to master registry...")
                        }
                    }

                    // CANCEL ACTION: ABORT
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.fillHeight: true
                        color: "#1a0b1a" // primaryDarkColor/darkMagenta [3]
                        border.color: "#bf00ff"
                        opacity: 0.8

                        Text {
                            text: "ABORT"
                            anchors.centerIn: parent
                            color: "#bf00ff"
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
