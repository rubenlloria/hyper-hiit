
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
        topPadding: 10
        Rectangle {
            width: root.width
            height: 1
            color: mainWindow.currentDirectiveColor
            opacity: 0.2
        }

        NeonText {
            label: qsTr("SUBSYSTEM_0") + root.subsystemId + ":"
            labelColor: mainWindow.currentDirectiveColor
            font.family: Constants.mainFont.family
            font.pixelSize: 12
            cornerWidth: 1
        }
        Repeater {
            id: moduleRepeater
            model: root.modulesModel

            RowLayout {
                width: parent.width
                NeonText {
                    label: modelData.quantity + modelData.unit
                    labelColor: Constants.primaryTextColor
                    size: 18
                }
                NeonText {
                    // TODO: Add maxWidth
                    label: modelData.name
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
                NeonText {
                    label: modelData.time
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
                NeonText {
                    label: " " + modelData.delta
                    size: 14
                    labelColor: modelData.diff
                                > 0 ? Constants.secondaryTextColor : Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
            }
        }
    }
}
