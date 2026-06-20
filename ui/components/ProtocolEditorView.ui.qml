
/*
 * ProtocolEditorView.ui.qml
 * Modular item for protocol editing within a Directive.
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

    property bool isDirty: false // Magenta state for unsaved changes
    property color accentColor: Constants.primaryColor // Default Protocol Color

    // Properties for data binding
    property string protocolName: "INFERNO_SEQUENCE"
    property int selectedRank: 1 // 0:NEWBIE, 1:ADVANCED, 2:ROOT

    property alias protocolRepeater: protocolRepeater

    Column {
        id: contentLayout
        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 25

        // 1. SECTION HEADER
        NeonText {
            label: " PROTOCOL_BUILDER "
            labelColor: root.accentColor
            font.family: Constants.mainFont.family
            font.pixelSize: 14
            font.letterSpacing: 2
            cornerWidth: 2
        }

        // 2. PROTOCOL SELECTION TABS
        // Row {
        //     spacing: 10
        //     Repeater {
        //         model: ["INFERNO_SEQUENCE", "PULSE_DRIVER", "GHOST_PROTOCOL"]
        //         Rectangle {
        //             width: 140
        //             height: 35
        //             color: modelData === root.protocolName ? "#20bf00ff" : Constants.deepColor
        //             border.color: modelData === root.protocolName ? Constants.primaryColor : "#40ffffff"
        //             border.width: 1

        //             Text {
        //                 text: modelData
        //                 anchors.centerIn: parent
        //                 color: parent.border.color
        //                 font.family: Constants.techFont.family
        //                 font.pixelSize: 11
        //             }
        //         }
        //     }

        //     // Add New Button
        //     Rectangle {
        //         width: 60
        //         height: 35
        //         color: Constants.deepColor
        //         border.color: "#40ffffff"
        //         border.width: 1
        //         Text {
        //             text: "+ NEW"
        //             color: "#80ffffff"
        //             anchors.centerIn: parent
        //             font.family: Constants.techFont.family
        //             font.pixelSize: 10
        //         }
        //     }
        // }

        // 3. CORE METADATA (Name & Rank)
        ColumnLayout {
            width: parent.width
            spacing: 20

            NeonTextField {
                id: nameField
                width: parent.width
                text: root.protocolName
                label: "PROTOCOL_NAME"
                // isDirty: root.isDirty
            }

            NeonSelector {
                id: rankSelector
                width: 200
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
                    text: "DIRECTIVE_MAPPING_GRID"
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
                        glyph: "\ue0d2"
                        color: Constants.primaryColor
                        unlocked: true
                    }
                    NeonBadge {
                        size: 40
                        glyph: "\ue0f2"
                        color: "#4000fff9"
                        unlocked: false
                    } // CARDIO
                    NeonBadge {
                        size: 40
                        glyph: "\ue1b4"
                        color: "#40bf00ff"
                        unlocked: false
                    } // STRENGTH
                }
            }
        }

        // 5. SEQUENCE EDITOR // TIMELINE
        Column {
            width: parent.width
            spacing: 15

            Row {
                width: parent.width
                height: 15
                Text {
                    text: "SEQUENCE_EDITOR // TIMELINE"
                    color: Constants.primaryTextColor
                    font.family: Constants.mainFont.family
                    font.pixelSize: 12
                }
                Text {
                    text: "5 ENTRIES"
                    anchors.right: parent.right
                    color: Constants.descriptionColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    opacity: 0.7
                }
            }

            // Subsystem entry
            ColumnLayout {
                width: parent.width
                spacing: 2

                Repeater {
                    id: protocolRepeater
                    model: [{
                            "subsystem_id": 1,
                            "modules": [{
                                    "name": "Burpees",
                                    "quantity": 15,
                                    "unit": "x",
                                    "met": "N/A",
                                    "zone": "Full Body"
                                }, {
                                    "name": "Mountain Climbers",
                                    "quantity": 15,
                                    "unit": "x",
                                    "met": "N/A",
                                    "zone": "Full Body"
                                }]
                        }, // Subsystem 1 with 3 dummy modules
                        {
                            "subsystem_id": 2,
                            "modules": [{
                                    "name": "Burpees",
                                    "quantity": 15,
                                    "unit": "x",
                                    "met": "N/A",
                                    "zone": "Full Body"
                                }, {
                                    "name": "Mountain Climbers",
                                    "quantity": 15,
                                    "unit": "x",
                                    "met": "N/A",
                                    "zone": "Full Body"
                                }]
                        }, // Subsystem 2 with 5 dummy modules
                        {
                            "subsystem_id": 3,
                            "modules": [{
                                    "name": "Burpees",
                                    "quantity": 15,
                                    "unit": "x",
                                    "met": "N/A",
                                    "zone": "Full Body"
                                }, {
                                    "name": "Mountain Climbers",
                                    "quantity": 15,
                                    "unit": "x",
                                    "met": "N/A",
                                    "zone": "Full Body"
                                }]
                        } // Subsystem 3 with 3 dummy modules
                    ]

                    // model: [
                    //     { "subsystem_id": 1, "moduleData": 3 }, // Subsystem 1 with 3 dummy modules
                    //     { "subsystem_id": 2, "moduleData": 5 }, // Subsystem 2 with 5 dummy modules
                    //     { "subsystem_id": 3, "moduleData": 3 }  // Subsystem 3 with 3 dummy modules
                    // ]

                    // model: 3
                    Rectangle {
                        id: subsystemWrapper
                        width: parent.width
                        height: protocolLayout.implicitHeight + 5
                        color: "transparent"
                        border.color: Constants.primaryColor
                        border.width: 1
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
                                    } // Grip icon
                                    Text {
                                        text: "SUBSYSTEM_" + modelData.subsystem_id
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
                                        NeonIcon {
                                            glyph: "\ue1b2"
                                            size: 14
                                            color: Constants.primaryColor
                                            anchors.centerIn: parent
                                            MouseArea {
                                                id: buttonDelete
                                                anchors.fill: parent
                                                hoverEnabled: true
                                            }
                                        }
                                    } // X icon
                                }
                            } // subsystemItem
                            Repeater {
                                id: moduleRepeater
                                model: modelData.modules

                                // Module Entry
                                Rectangle {
                                    id: moduleItem
                                    width: parent.width * 0.98
                                    Layout.alignment: Qt.AlignHCenter
                                    height: 60
                                    color: Constants.deepColor
                                    border.color: Constants.secondaryColor
                                    border.width: 1

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
                                                cursorShape: Qt.OpenHandCursor
                                            }
                                        }

                                        Column {
                                            Layout.fillWidth: true
                                            Text {
                                                text: modelData.name
                                                width: 140
                                                color: Constants.primaryTextColor
                                                font.family: Constants.techFont.family
                                                font.pixelSize: 14
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                text: modelData.zone + " · MET:" + modelData.met
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
                                                text: modelData.quantity
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
                                                text: parent.isDefault ? (modelData.unit === "x" ? "Rep." : modelData.unit) : "sec."
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
                                            NeonIcon {
                                                glyph: "\ue18e"
                                                size: 16
                                                color: Constants.rootColor
                                                anchors.centerIn: parent
                                            }
                                        } // Delete
                                    }
                                } // moduleItem
                            }
                        } // protocolLayout
                    }
                }
            }

            // ADD SUBSYSTEM BUTTON
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                border.color: "#40bf00ff"
                border.width: 1

                // border.style: "Dashed" // Simplified for UI file representation
                Text {
                    text: "+ ADD_SUBSYSTEM"
                    color: Constants.primaryColor
                    anchors.centerIn: parent
                    font.family: Constants.techFont.family
                    font.pixelSize: 11
                }
            }
        }
    }
}
