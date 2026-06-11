import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

// Access to Constants.qml
Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.surfaceColor

    property alias header: header
    property alias neonAccordion: neonAccordion
    property alias protocols: protocols

    ColumnLayout {
        width: parent.width
        height: parent.height
        spacing: 10
        AppHeader {
            id: header
            Layout.fillWidth: true
            titlePart1: "sys"
            titlePart2: "architect"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }

        Flickable {
            id: dashboardScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Layout.bottomMargin: 60
            contentWidth: parent.width
            contentHeight: mainLayout.implicitHeight
            clip: true // Critical: prevents content from bleeding outside the shard [Source 95]
            boundsBehavior: Flickable.StopAtBounds

            // Custom Neon Scrollbar (v0.3 Fuchsia Aesthetic)
            ScrollBar.vertical: ScrollBar {
                parent: root
                policy: ScrollBar.AlwaysOn
                width: 0

                contentItem: Rectangle {
                    implicitWidth: 4
                    color: Constants.primaryColor
                    radius: 2
                }
            }

            Column {
                id: mainLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                leftPadding: 20
                rightPadding: 20
                width: parent.width
                spacing: 10

                NeonAccordion {
                    id: neonAccordion
                    anchors.horizontalCenter: parent.horizontalCenter
                    activeThemeColor: sessionManager.activeDirectiveInfo.color
                                      || Constants.primaryColor
                    activeDirectiveName: sessionManager.activeDirectiveInfo.name
                                         || "LOADING..."
                    activeIconGlyph: sessionManager.activeDirectiveInfo.icon
                                     || Constants.zapIcon
                    activeDirectiveDesc: sessionManager.activeDirectiveInfo.description
                                         || "No data"
                }

                ProtocolList {
                    id: protocols
                    anchors.horizontalCenter: parent.horizontalCenter
                    listThemeColor: neonAccordion.activeThemeColor
                }

                Column {
                    // TODO: Improve spacer to prevent footer overlap last module
                    height: Constants.bottomMargin
                    width: 20
                }
            }
        }
    }
}
