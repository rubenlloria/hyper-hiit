import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

// Access to Constants.qml
Rectangle {
    id: architectRoot
    width: Constants.width
    height: Constants.height
    color: Constants.backgroundColor

    property alias header: header


    // --- VIEW CONTENT ---
    AppHeader {
        id: header
        titlePart1: "sys"
        titlePart2: "architect"
        buttonLabel: "BACK     "
        // buttonGlyph: Constants.backIcon
        buttonGlyph: Constants.backIcon
        anchors.top: parent.top
    }

    // Add your configuration components here
}
