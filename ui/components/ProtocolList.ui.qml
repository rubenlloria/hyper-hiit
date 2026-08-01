import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import ".."


/*
    ProtocolList Component: Scrollable list for Mission Protocols.
    Displays exactly 3 items at a time with a custom neon scrollbar.
*/
Item {
    id: listRoot
    width: 380
    height: 255

    property color listThemeColor: Constants.primaryTextColor
    property alias protocolView: protocolView

    Column {
        anchors.fill: parent
        // spacing: 10

        // Header Title
        Text {
            id: listTitle
            text: qsTr("PROTOCOLS")
            color: Constants.primaryTextColor
            font.family: Constants.techFont.family
            font.pixelSize: 12
            topPadding: 8
            bottomPadding: 8
        }

        // ListView showing exactly 3 items
        ListView {
            id: protocolView
            width: parent.width
            height: listRoot.height - 30 // (Item height 85 * 3) + spacing
            spacing: 10
            clip: true

            // Custom Neon ScrollBar
            ScrollBar.vertical: ScrollBar {
                id: customScrollBar
                active: true
                width: 8

                contentItem: Rectangle {
                    implicitWidth: 6
                    color: Constants.primaryColor
                    opacity: 0.8
                    radius: 3
                    // Glow effect for the scrollbar thumb [3]
                }
                DropShadow {
                    id: scrollbarShadow
                    source: customScrollBar
                    color: Constants.primaryColor
                    radius: 8
                    samples: 12
                }

                background: Rectangle {
                    implicitWidth: 8
                    color: Constants.deepColor
                    opacity: 0.3
                    border.color: Constants.primaryColor
                    border.width: 1
                }
            }
        }
    }
}
