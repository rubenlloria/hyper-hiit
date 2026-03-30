import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

// Access to Constants.qml
Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.backgroundColor

    property alias header: header

    // --- VIEW CONTENT ---

    Column {
        width: parent.width
        height: parent.height
        spacing: 10
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
            titlePart1: "sys"
            titlePart2: "protocol"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }
    }
}
