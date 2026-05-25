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

    property color listThemeColor: "#00fff9" // Cyan for list headers and scrollbar
    property alias protocolView: protocolView

    Column {
        anchors.fill: parent
        // spacing: 10

        // Header Title
        Text {
            id: listTitle
            text: "PROTOCOLS"
            color: Constants.cyanNeon
            font.family: "Share Tech Mono"
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
                    color: Constants.fuchsiaNeon
                    opacity: 0.8
                    radius: 3
                    // Glow effect for the scrollbar thumb [3]
                }
                DropShadow {
                    id: scrollbarShadow
                    source: customScrollBar
                    color: Constants.fuchsiaNeon
                    radius: 8
                    samples: 12
                }

                background: Rectangle {
                    implicitWidth: 8
                    color: "#0d0d10"
                    opacity: 0.3
                    border.color: Constants.fuchsiaNeon
                    border.width: 1
                }
            }
        }
    }
}
