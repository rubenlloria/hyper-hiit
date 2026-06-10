
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
    height: 80

    property string title: "SCANLINE_RENDER"
    property string description: "Enable/Disable horizontal terminal line"
    property bool checked: true
    property color neonColor: Constants.secondaryColor
    property color borderColor: Constants.secondaryColor

    Rectangle {
        id: background
        anchors.fill: parent
        color: Constants.surfaceColor
        border.color: root.borderColor
        border.width: 1

        // Title amd description
        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 15
            spacing: 4

            Text {
                text: root.title
                color: Constants.primaryTextColor
                font.family: Constants.mainFont.family
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                text: root.description
                color: Constants.whiteNeon
                font.family: Constants.techFont.family
                font.pixelSize: 10
                opacity: 0.4
            }
        }

        Item {
            id: switchRoot
            width: 60
            height: 30

            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter

            // Switch Track
            Rectangle {
                id: track
                anchors.fill: parent
                radius: 15
                color: Constants.deepColor
                border.color: root.neonColor
                border.width: 1

                // swipe button
                Rectangle {
                    id: knob
                    width: 24
                    height: 24
                    radius: 12
                    color: root.neonColor
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.checked ? parent.width - width - 4 : 4

                    // Movement animation
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                        }
                    }
                }
            }

            // Glow when active
            DropShadow {
                anchors.fill: track
                source: track
                color: root.neonColor
                radius: 10
                samples: 5
                visible: root.checked
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.checked = !root.checked
            }
        }
    }
}
