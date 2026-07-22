
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
    width: subsystemColumn.implicitWidth
    height: subsystemColumn.implicitHeight
    property color color: Constants.secondaryTextColor
    property int subsystemId: 0
    property var modulesModel: []

    Column {
        id: subsystemColumn
        spacing: 5
        Rectangle {
            width: root.width
            height: 1
            color: root.color
            opacity: 0.2
        }

        Text {
            text: "SUBSYSTEM_0" + root.subsystemId + ":"
            color: Constants.primaryTextColor
            font.family: Constants.mainFont.family
            font.pixelSize: 12
        }
        Repeater {
            id: moduleRepeater
            model: root.modulesModel

            Text {
                text: modelData.quantity + modelData.unit + " " + modelData.name
                color: root.color
                font.family: Constants.techFont.family
                font.pixelSize: 20
                font.bold: true
            }
        }
    }
}
