import QtQuick
import QtQuick.Layouts
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
    property alias restoreDBButton: restoreDBButton
    ColumnLayout {
        spacing: 10
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

        NeonButton {
            id: restoreDBButton
            x: 24
            y: 121
            label: "RESTORE_DB"
        }

        // Add your configuration components here
    }
}
