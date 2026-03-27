

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
    width: indicatorRow.implicitWidth
    height: indicatorRow.implicitHeight

    property bool active: false
    property string label_on: "label_on"
    property string label_off: "label_off"
    property alias labelColor: indicatorLabel.color
    // property alias ledColor: indicatorLed.color

    // FontLoader {
    //     id: internalShareTecFont
    //     source: "fonts/ShareTechMono-Regular.ttf"
    // }
    Row {
        id: indicatorRow
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter

        Item {
            width: 20
            height: 20
            Rectangle {
                id: indicatorLed
                width: 10
                height: 10
                radius: 5
                color: root.active ? Constants.onColor : Constants.offColor
                anchors.centerIn: parent
            }
            DropShadow {
                id: ledGlow
                anchors.fill: indicatorLed
                source: indicatorLed
                color: indicatorLed.color
                radius: 12
                samples: 25
                spread: 0.3
                transparentBorder: true
            }
        }

        Text {
            id: indicatorLabel
            text: root.active ? root.label_on : root.label_off
            color: "#00fff9"
            font.family: Constants.techFont.family
            font.letterSpacing: 1
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
            renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
        }
    }
}
