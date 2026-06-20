import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import "../components"
import ".."

Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.surfaceColor

    property int expandedIndex: -1
    property int editingIndex: -1
    property int protocolId: -1

    property alias header: header
    property alias directiveLayout: directiveLayout
    property alias directiveRepeater: directiveRepeater
    property alias buttonAll: buttonAll
    property alias buttonOrphan: buttonOrphan
    property alias protocolAccordion: protocolAccordion

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
            id: mainScroll
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
                spacing: 30

                Column {
                    id: directiveLayout
                    width: parent.width * 0.9
                    spacing: 5
                    NeonTitle {
                        label: "DIRECTIVE_EDITOR"
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: 14
                        titleColor: Constants.secondaryColor
                    }

                    Row {
                        spacing: 15
                        Rectangle {
                            width: buttonAllLayout.implicitWidth * 1.15
                            height: 34
                            color: "transparent"
                            border.color: Constants.secondaryColor
                            opacity: buttonAll.selected ? 1 : 0.5
                            RowLayout {
                                id: buttonAllLayout
                                anchors.verticalCenter: parent.verticalCenter
                                // anchors.fill: parent
                                spacing: 0
                                NeonIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    glyph: Constants.activityIcon
                                    size: 12
                                    color: parent.parent.border.color
                                }
                                NeonText {
                                    Layout.alignment: Qt.AlignVCenter
                                    label: "ALL"
                                    labelColor: parent.parent.border.color
                                }
                            }
                            MouseArea {
                                id: buttonAll
                                property bool selected: false
                                anchors.fill: parent
                            }
                        }
                        Rectangle {
                            width: buttonOrphanLayout.implicitWidth * 1.15
                            height: 34
                            color: "transparent"
                            border.color: Constants.secondaryColor
                            opacity: buttonOrphan.selected ? 1 : 0.5
                            RowLayout {
                                id: buttonOrphanLayout
                                anchors.verticalCenter: parent.verticalCenter
                                // anchors.fill: parent
                                spacing: 0
                                NeonIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    glyph: Constants.activityIcon
                                    size: 12
                                    color: parent.parent.border.color
                                }
                                NeonText {
                                    Layout.alignment: Qt.AlignVCenter
                                    label: "ORPHAN"
                                    labelColor: parent.parent.border.color
                                }
                            }
                            MouseArea {
                                id: buttonOrphan
                                property bool selected: false
                                anchors.fill: parent
                            }
                        }
                    }
                    Repeater {
                        id: directiveRepeater
                        model: 5

                        delegate: DirectiveEditor {
                            isExpanded: architectForm.expandedIndex === index
                            isEditing: architectForm.editingIndex === index

                            // Directive Data Injection
                            nameText: model.name || "DIRECTIVE_NAME"
                            descriptionText: model.description
                            accentColor: model.color
                                         || Constants.primaryTextColor
                            glyph: model.icon
                        }
                    }
                }
                Column {
                    id: protocolLayout
                    width: parent.width * 0.9
                    spacing: 5
                    NeonTitle {
                        label: "PROTOCOL_BUILDER"
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: 14
                        titleColor: Constants.secondaryColor
                    }

                    NeonAccordion {
                        id: protocolAccordion
                        title: "SELECT_PROTOCOL"
                        anchors.horizontalCenter: parent.horizontalCenter
                        activeThemeColor: Constants.primaryColor
                        activeDirectiveName: editingIndex === -1 ? "DIRECTIVE_NOT_SELECTED" : "ASSOCIATED_PROTOCOLS"
                        activeIconGlyph: ""
                        activeDirectiveDesc: editingIndex === -1 ? "Select directive first." : "Manage selected directive protocols"
                        width: parent.width
                        headerMouseArea.visible: false
                        // activeThemeColor: sessionManager.activeDirectiveInfo.color
                        //                   || Constants.primaryColor
                        // activeDirectiveName: sessionManager.activeDirectiveInfo.name
                        //                      || "LOADING..."
                        // activeIconGlyph: sessionManager.activeDirectiveInfo.icon
                        //                  || Constants.zapIcon
                        // activeDirectiveDesc: sessionManager.activeDirectiveInfo.description
                        //                      || "No data"
                    }

                    // ProtocolEditor {
                    //     id: protocolEditor
                    // }
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
