

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
    height: 60

    property string label: "FIELD_NAME"
    property alias text: textInput.text
    property string placeholder: "ENTER_DATA..."
    property color neonColor: Constants.primaryTextColor
    property bool showSuccessPulse: false
    property alias textInput: textInput

    // Etiqueta superior (Tipografia Share Tech Mono)
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

    // Contenidor de l'entrada
    Rectangle {
        id: inputBackground
        width: parent.width
        height: 40
        color: Constants.deepColor
        border.color: root.neonColor
        border.width: 1
        anchors.bottom: parent.bottom

        TextInput {
            id: textInput
            text: ""
            anchors.fill: parent
            anchors.margins: 10
            color: Constants.descriptionColor
            font.family: Constants.techFont.family
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            clip: true

            Text {
                text: root.placeholder
                color: Constants.descriptionColor
                opacity: 0.4
                visible: !textInput.text && !textInput.activeFocus
                font: textInput.font
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Resplendor de la vora
    DropShadow {
        anchors.fill: inputBackground
        source: inputBackground
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
