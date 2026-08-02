
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls

import ".."


/*
    Individual item for the protocol metadata.
    Compliant with .ui.qml strict formatting.
*/
Item {
    id: root
    width: 150
    height: 65
    // anchors.leftMargin: 45

    // Public properties for data binding
    property string keyLabel: "METADATA"
    property string valueLabel: "Value"
    property int valueSize: 25
    property string unitLabel: ""
    property color color: Constants.primaryTextColor
    property color borderColor: root.color

    // Main background layer
    Rectangle {
        id: backgroundBase
        anchors.fill: parent
        color: Constants.deepColor
        opacity: 0.8
        border.color: root.borderColor
        border.width: 1
    }
    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        Text {
            id: labelTitle
            text: root.keyLabel
            color: Constants.secondaryColor
            opacity: 0.7
            font.family: Constants.techFont.family
            font.pixelSize: 10
        }

        NeonText {
            id: labelDescription
            label: root.valueLabel
            labelColor: root.color
            size: root.valueSize
        }
        Text {
            id: labelUnit
            text: root.unitLabel
            color: Constants.descriptionColor
            opacity: 0.7
            font.family: Constants.techFont.family
            font.pixelSize: 10
        }
    }
}
