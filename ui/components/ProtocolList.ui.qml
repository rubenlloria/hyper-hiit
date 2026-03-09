import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects


/*
    ProtocolList Component: Scrollable list for Mission Protocols.
    Displays exactly 3 items at a time with a custom neon scrollbar.
*/
Item {
    id: listRoot
    width: 380
    height: 300

    property color listThemeColor: "#00fff9" // Cyan for list headers and scrollbar

    Column {
        anchors.fill: parent
        spacing: 10

        // Header Title
        Text {
            id: listTitle
            text: "MISSION_PROTOCOLS"
            color: listRoot.listThemeColor
            font.family: "Share Tech Mono"
            font.pixelSize: 14
            leftPadding: 5
        }

        // ListView showing exactly 3 items
        ListView {
            id: protocolView
            width: parent.width
            height: 275 // (Item height 85 * 3) + spacing
            spacing: 5
            clip: true
            model: 10 // To be replaced by C++ Model

            delegate: NeonProtocol {
                // Properties injected here from C++ model in the future
                protocolName: "PROTOCOL_" + index
                currentProgress: 0.4 + (index * 0.1)
                personalBest: 0.6
            }

            // Custom Neon ScrollBar
            ScrollBar.vertical: ScrollBar {
                id: customScrollBar
                active: true
                width: 8

                contentItem: Rectangle {
                    implicitWidth: 6
                    color: listRoot.listThemeColor
                    opacity: 0.8
                    // Glow effect for the scrollbar thumb [3]
                }
                DropShadow {
                    id: scrollbarShadow
                    source: customScrollBar
                    color: listRoot.listThemeColor
                    radius: 8
                    samples: 12
                }

                background: Rectangle {
                    implicitWidth: 8
                    color: "#0d0d10"
                    opacity: 0.3
                    border.color: listRoot.listThemeColor
                    border.width: 1
                }
            }
        }
    }
}
