import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

// Access to Constants.qml
Rectangle {
    id: protocolRoot
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.backgroundColor

    // --- VIEW CONTENT ---
    AppHeader {
        id: header
        titlePart1: "sys"
        titlePart2: "protocol"
        anchors.top: parent.top
    }

    // Add your configuration components here
}
