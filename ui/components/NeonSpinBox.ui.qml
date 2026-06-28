

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: root
    width: 350
    height: 70

    // Propietats de configuració
    property string label: "TITLE"
    property int value: 0
    property string suffix: ""
    property color neonColor: Constants.primaryTextColor
    property color textColor: Constants.descriptionColor
    property bool showSuccessPulse: false

    // 1. Etiqueta superior (Tipografia Share Tech Mono) [4]
    Text {
        id: fieldLabel
        text: root.label
        color: root.neonColor
        font.family: Constants.techFont.family
        font.pixelSize: 12
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 5
    }

    // 2. Contenidor principal
    Rectangle {
        id: controlBackground
        width: root.width
        height: 45
        color: Constants.deepColor
        border.color: root.neonColor
        border.width: 1
        anchors.bottom: parent.bottom

        // Botó de decrementar (-)
        Rectangle {
            id: downButton
            width: 45
            height: 43
            color: Constants.surfaceColor
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 1

            Text {
                text: "-"
                color: root.neonColor
                font.family: Constants.mainFont.family
                font.pixelSize: 24
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.value--
            }
        }

        // Valor central
        Text {
            id: valueText
            text: root.value + (root.suffix === "" ? "" : " " + root.suffix)
            color: root.textColor
            font.family: Constants.techFont.family
            font.pixelSize: 18
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
        }

        // Botó d'incrementar (+)
        Rectangle {
            id: upButton
            width: 45
            height: 43
            color: Constants.surfaceColor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 1

            Text {
                text: "+"
                color: root.neonColor
                font.family: Constants.mainFont.family
                font.pixelSize: 24
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.value++
            }
        }
    }

    // 3. Efecte de resplendor neó [5]
    DropShadow {
        anchors.fill: controlBackground
        source: controlBackground
        color: root.neonColor
        radius: root.showSuccessPulse ? 12 : 8
        samples: 12
        spread: root.showSuccessPulse ? 0.5 : 0.1

        Behavior on radius {
            NumberAnimation {
                duration: 300
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }
    }
}
