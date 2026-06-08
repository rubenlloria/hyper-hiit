

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: root

    // Configuration properties
    property string label: "SELECTOR_LABEL"
    property bool horizontal: true
    property color neonColor: Constants.primaryTextColor
    property int selectedIndex: 1

    property string option1Label: "OPTION_1"
    property color option1Color: Constants.primaryTextColor
    property string option2Label: "OPTION_2"
    property color option2Color: Constants.primaryTextColor
    property string option3Label: "OPTION_3"
    property color option3Color: Constants.primaryTextColor

    property alias mouseAreaH1: mouseAreaH1
    property alias mouseAreaH2: mouseAreaH2
    property alias mouseAreaH3: mouseAreaH3
    property alias mouseAreaV1: mouseAreaV1
    property alias mouseAreaV2: mouseAreaV2
    property alias mouseAreaV3: mouseAreaV3

    width: 350
    height: root.horizontal ? 65 : 145

    // 1. Field Label
    Text {
        id: fieldLabel
        text: root.label
        color: root.neonColor
        font.family: Constants.techFont.family
        font.pixelSize: 10
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 5
    }

    // 2. Horizontal Layout (3 Buttons with individual glow)
    Row {
        id: horizontalLayout
        anchors.bottom: parent.bottom
        width: 350
        height: 45
        spacing: 10
        visible: root.horizontal

        // Option 1
        Rectangle {
            id: optH1
            width: 110
            height: 40
            color: Constants.darkBlue
            border.color: root.option1Color
            opacity: root.selectedIndex === 0 ? 1 : 0.5
            border.width: root.selectedIndex === 0 ? 2 : 1
            Text {
                text: root.option1Label
                color: optH1.border.color
                font.family: Constants.techFont.family
                font.pixelSize: 11
                anchors.centerIn: parent
            }
            DropShadow {
                anchors.fill: parent
                source: parent
                color: root.neonColor
                radius: 12
                samples: 16
                opacity: 0.3
                spread: 0.1
                visible: root.selectedIndex === 0 && root.horizontal
            }
            MouseArea {
                id: mouseAreaH1
                anchors.fill: parent
                onClicked: root.selectedIndex = 0
            }
        }
        // Option 2
        Rectangle {
            id: optH2
            width: 110
            height: 40
            color: Constants.darkBlue
            border.color: root.option2Color
            opacity: root.selectedIndex === 1 ? 1 : 0.5
            border.width: root.selectedIndex === 1 ? 2 : 1
            Text {
                text: root.option2Label
                color: optH2.border.color
                font.family: Constants.techFont.family
                font.pixelSize: 11
                anchors.centerIn: parent
            }
            DropShadow {
                anchors.fill: parent
                source: parent
                color: root.neonColor
                radius: 12
                samples: 16
                opacity: 0.3
                visible: root.selectedIndex === 1 && root.horizontal
            }
            MouseArea {
                id: mouseAreaH2
                anchors.fill: parent
                onClicked: root.selectedIndex = 1
            }
        }
        // Option 3
        Rectangle {
            id: optH3
            width: 110
            height: 40
            color: Constants.darkBlue
            border.color: root.option3Color
            opacity: root.selectedIndex === 2 ? 1 : 0.5
            border.width: root.selectedIndex === 2 ? 2 : 1
            Text {
                text: root.option3Label
                color: optH3.border.color
                font.family: Constants.techFont.family
                font.pixelSize: 11
                anchors.centerIn: parent
            }
            DropShadow {
                anchors.fill: parent
                source: parent
                color: root.neonColor
                radius: 12
                samples: 16
                opacity: 0.3
                visible: root.selectedIndex === 2 && root.horizontal
            }
            MouseArea {
                id: mouseAreaH3
                anchors.fill: parent
                onClicked: root.selectedIndex = 2
            }
        }
    }

    // 3. Vertical Layout (3 Options with individual glow)
    Column {
        id: verticalLayout
        anchors.bottom: parent.bottom
        width: 350
        spacing: 6
        visible: !root.horizontal

        // Option V1
        Rectangle {
            id: optV1
            width: 350
            height: 38
            color: Constants.darkBlue
            border.color: root.option1Color
            opacity: root.selectedIndex === 0 ? 1 : 0.5
            border.width: root.selectedIndex === 0 ? 2 : 1
            Text {
                text: root.option1Label
                color: root.option1Color
                font.family: Constants.techFont.family
                font.pixelSize: 12
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
            }
            DropShadow {
                anchors.fill: parent
                source: parent
                color: root.neonColor
                radius: 12
                samples: 16
                opacity: 0.3
                visible: root.selectedIndex === 0 && !root.horizontal
            }
            MouseArea {
                id: mouseAreaV1
                anchors.fill: parent
                onClicked: root.selectedIndex = 0
            }
        }
        // Option V2
        Rectangle {
            id: optV2
            width: 350
            height: 38
            color: Constants.darkBlue
            border.color: root.option2Color
            opacity: root.selectedIndex === 1 ? 1 : 0.5
            border.width: root.selectedIndex === 1 ? 2 : 1
            Text {
                text: root.option2Label
                color: root.option2Color
                font.family: Constants.techFont.family
                font.pixelSize: 12
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
            }
            DropShadow {
                anchors.fill: parent
                source: parent
                color: root.neonColor
                radius: 12
                samples: 16
                opacity: 0.3
                visible: root.selectedIndex === 1 && !root.horizontal
            }
            MouseArea {
                id: mouseAreaV2
                anchors.fill: parent
                onClicked: root.selectedIndex = 1
            }
        }
        // Option V3
        Rectangle {
            id: optV3
            width: 350
            height: 38
            color: Constants.darkBlue
            border.color: root.option3Color
            opacity: root.selectedIndex === 2 ? 1 : 0.5
            border.width: root.selectedIndex === 2 ? 2 : 1
            Text {
                text: root.option3Label
                color: root.option3Color
                font.family: Constants.techFont.family
                font.pixelSize: 12
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
            }
            DropShadow {
                anchors.fill: parent
                source: parent
                color: root.neonColor
                radius: 12
                samples: 16
                opacity: 0.3
                visible: root.selectedIndex === 2 && !root.horizontal
            }
            MouseArea {
                id: mouseAreaV3
                anchors.fill: parent
                onClicked: root.selectedIndex = 2
            }
        }
    }

    // 4. States for configuration view
    states: [
        State {
            name: "vertical_mode"
            when: !root.horizontal
            PropertyChanges {
                target: root
                height: 160
            }
        }
    ]
}
