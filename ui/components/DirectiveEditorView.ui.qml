import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import ".."
import "../components"


/*
   DirectiveEditorView.ui.qml
   Directive Editor Component
   Modular item for the Directive List (Architect Suite)
*/
Item {
    id: root
    readonly property int editHeight: 580
    readonly property int viewHeight: 120
    width: Constants.designWidth * 0.9
    height: !isExpanded ? 60 : (isEditing ? editHeight : viewHeight)

    // Configuration Properties
    property bool isExpanded: false
    property color accentColor: Constants.secondaryColor
    property bool isDirty: false
    property bool isEditing: false
    property int directiveId: -1

    // Aliases for data binding in the Repeater
    property alias nameText: nameInput.text
    property alias descriptionText: descInput.text
    property alias glyph: directiveIcon.glyph
    property alias hexCode: hexInput.text
    property alias headerArea: headerArea
    property alias editButton: editButton
    property alias deleteButton: deleteButton
    property alias deleteItem: deleteItem
    property alias saveButton: saveButton
    property alias saveItem: saveItem
    property alias hexInput: hexInput

    // Main Container
    Rectangle {
        id: container
        anchors.fill: parent
        color: Constants.backgroundColor
        border.color: root.accentColor
        border.width: 1

        // 1. HEADER (Always visible)
        RowLayout {
            id: headerRow
            width: parent.width
            height: 60
            spacing: 0

            // leftPadding: 15
            // rightPadding: 15
            // Chevron indicator [3]
            Text {
                // FIXME first click not animated
                id: chevron
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignVCenter
                text: Constants.chevronRight
                color: container.border.color
                font.family: Constants.iconFont.family
                font.pixelSize: 20
                rotation: root.isExpanded ? 90 : 0
            }

            NeonIcon {
                id: directiveIcon
                Layout.alignment: Qt.AlignVCenter
                glyph: Constants.flameIcon
                color: root.accentColor
                size: 24
            }

            Text {
                text: root.nameText
                color: root.accentColor
                font.family: Constants.mainFont.family
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
                width: 200
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // Action Buttons (Right Aligned)
            Item {
                width: 90
                height: 60
                Layout.alignment: Qt.AlignVCenter
                // anchors.right: parent.right
                Row {
                    // anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    // Edit Icon (Radio Select logic in Logic file)
                    Rectangle {
                        id: editItem
                        width: 35
                        height: 35
                        color: editButton.pressed ? Constants.primaryColor : "transparent"
                        opacity: editButton.pressed ? 0.2 : 1.0
                        border.color: "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        Rectangle {
                            id: editOverlay
                            anchors.fill: parent
                            color: "transparent"
                            border.color: root.accentColor
                            opacity: editButton.pressed ? 0.2 : (editButton.containsMouse ? 1.0 : 0.5)
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }

                        NeonIcon {
                            anchors.centerIn: parent
                            glyph: Constants.pencilIcon
                            size: 18
                            color: root.accentColor
                            opacity: isEditing ? 1 : 0.4
                        }
                        MouseArea {
                            id: editButton
                            anchors.fill: parent
                            hoverEnabled: true
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
                            visible: isEditing ? false : true
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
                        Rectangle {
                            id: saveItem
                            anchors.fill: parent
                            visible: isEditing ? true : false
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
                }
            }
        }

        MouseArea {
            id: headerArea
            anchors.fill: headerRow
            anchors.rightMargin: 100
        }

        // SUMMARY PANEL ("Saved Info" box)
        Column {
            id: summaryPanel
            anchors.top: headerRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            spacing: 8
            visible: root.height === viewHeight
            Row {
                spacing: 10
                Text {
                    text: "NAME:"
                    color: root.accentColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }
                Text {
                    text: root.nameText
                    color: Constants.descriptionColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    width: parent.width * 0.58
                }
                Text {
                    text: "COLOR:"
                    color: root.accentColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    leftPadding: 10
                }
                Text {
                    text: root.accentColor
                    color: Constants.descriptionColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }
            }
            Row {
                spacing: 10
                Text {
                    text: "DESC:"
                    color: root.accentColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }
                Text {
                    text: root.descriptionText
                    width: parent.width * 0.89
                    color: Constants.descriptionColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
            }
        }

        // EDITING PANEL (Visible when expanded)
        Column {
            id: editPanel
            anchors.top: headerRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            spacing: 15
            visible: root.height === editHeight

            // Text Fields
            NeonTextField {
                id: nameInput
                width: parent.width - 30
                label: "NAME"
                text: "DIRECTIVE_NAME"
            }

            NeonTextField {
                id: descInput
                width: parent.width - 30
                label: "DESCRIPTION"
            }

            // GLOW_SELECTOR Section
            // TODO: Add second row with material variations from selected color
            Column {
                spacing: 8
                Text {
                    text: "GLOW_SELECTOR"
                    color: Constants.primaryTextColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }

                Row {
                    spacing: 8
                    Repeater {
                        // "#ff00ff",
                        // "#ff5e00",
                        // "#00ff00",
                        // "#ffff00",
                        // "#ff0000",
                        // "#5b84ff"
                        model: [Constants.primaryColor, Constants.secondaryColor, Constants.greenNeon, Constants.yellowNeon, Constants.redNeon, Constants.tangerine, Constants.spaceBlue, Constants.charcoal, Constants.whiteNeon]
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 5
                            color: modelData
                            border.color: Constants.descriptionColor
                            border.width: root.accentColor == modelData ? 2 : 0
                            MouseArea {
                                anchors.fill: parent
                                // Updates the root property directly for <1ms response
                                onClicked: root.accentColor = modelData
                            }
                        }
                    }
                }

                Row {
                    spacing: 10
                    NeonTextField {
                        id: hexInput
                        width: 200
                        label: "HEX_CODE"
                        placeholder: root.accentColor
                    }
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 5
                        color: root.accentColor
                        border.color: Constants.descriptionColor
                        border.width: 1
                        anchors.bottom: parent.bottom
                    }
                }
            }

            // ICON_IDENTIFIER Section (Grid)
            Column {
                spacing: 8
                Text {
                    text: "ICON_IDENTIFIER"
                    color: Constants.primaryTextColor
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                }

                Grid {
                    columns: 7
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Mock icon grid - in logic this would be a full library
                    Repeater {
                        model: [Constants.flameIcon, Constants.heartIcon, Constants.targetIcon, Constants.zapIcon, Constants.brainIcon, Constants.kineticIcon, Constants.weightIcon, Constants.recoveryIcon, Constants.dnaIcon, Constants.swordsIcon, Constants.crosshairIcon, Constants.terminalIcon, Constants.atomIcon, Constants.radarIcon, Constants.anvilIcon, Constants.starIcon, Constants.muscleIcon, Constants.zenIcon, Constants.runIcon, Constants.swimIcon, Constants.dumbbellIcon, Constants.bikeIcon, Constants.combatIcon, Constants.mountainIcon, Constants.agilityIcon, Constants.stretchIcon, Constants.medalIcon, Constants.trophyIcon]
                        NeonIcon {
                            glyph: modelData
                            color: root.glyph
                                   == glyph ? root.accentColor : Constants.descriptionColor
                            opacity: root.glyph == glyph ? 1 : 0.5
                            size: 20
                            MouseArea {
                                anchors.fill: parent
                                // Updates the root property directly for <1ms response
                                onClicked: root.glyph = modelData
                            }
                        }
                    }
                }
            }
        }
    }

    // States for animation and expansion
    states: [
        State {
            name: "expandedEditig"
            when: root.isExpanded && root.isEditing
            PropertyChanges {
                target: root
                height: editHeight
            }
            PropertyChanges {
                target: chevron
                rotation: 90
            }
        },
        State {
            name: "expandedSummary"
            when: root.isExpanded && !root.isEditing
            PropertyChanges {
                target: root
                height: viewHeight
            }
            PropertyChanges {
                target: chevron
                rotation: 90
            }
        },
        State {
            name: "collapsed"
            when: !root.isExpanded
            PropertyChanges {
                target: root
                height: 60
            }
            PropertyChanges {
                target: chevron
                rotation: 0
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                properties: "height, opacity"
                duration: 400
                easing.type: Easing.InOutQuad
            }
            RotationAnimation {
                target: chevron
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
