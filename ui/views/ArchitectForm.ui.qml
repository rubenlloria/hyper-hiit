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
    color: Constants.surfaceColor

    property alias header: header
    property alias restoreDBButton: restoreDBButton
    property alias summaryButton: summaryButton
    property alias configButton: configButton

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent // Ensures the layout covers the view
        spacing: 10
        // --- VIEW CONTENT ---
        AppHeader {
            id: header
            Layout.fillWidth: true
            titlePart1: "sys"
            titlePart2: "architect"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }

        ColumnLayout {
            spacing: 40
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            NeonButton {
                id: restoreDBButton
                label: "RESTORE_DB"
                Layout.alignment: Qt.AlignTop
                // Layout.topMargin: Constants.px(20)
            }

            NeonButton {
                id: summaryButton
                label: "Summary"
                Layout.alignment: Qt.AlignTop
                // Layout.topMargin: Constants.px(20)
            }

            NeonButton {
                id: configButton
                label: "CORE_CONFIG"
                Layout.alignment: Qt.AlignTop
                // Layout.topMargin: Constants.px(20)
            }

            // [BUFFER]: Flexible item to push content up
            Item {
                Layout.fillHeight: true
            }
        }

        // Add your configuration components here
    }
}
