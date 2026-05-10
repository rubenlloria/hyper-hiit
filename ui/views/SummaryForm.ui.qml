
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import ".."

import "../components"

Rectangle {
    id: root
    width: Constants.designWidth
    height: Constants.designHeight
    color: Constants.darkMagenta // Color de fondo del theme.css
    property alias header: header

    property int activeProtocolId: 0
    property string protocolName: "PROTOCOL_NAME"
    property string rank: "NEWBIE"
    property int calories: 123
    property int moduleCount: 0
    property string duration: "00:00"
    property string efficiency: "96%"
    property int improvement: 46

    Column {
        id: mainColumn
        width: parent.width
        height: parent.height
        spacing: 15
        AppHeader {
            id: header
            z: 60
            Layout.fillWidth: true
            Layout.preferredHeight: 100 // Match your AppHeader design
            titlePart1: "sys"
            titlePart2: "summary"
            buttonLabel: "BACK     "
            buttonGlyph: Constants.backIcon
        }

        NeonText {
            anchors.horizontalCenter: parent.horizontalCenter
            label: protocolName
            size: 35
            cornerWidth: 1
        }

        NeonText {
            anchors.horizontalCenter: parent.horizontalCenter
            label: "01/01/1970 00:00h"
            size: 20
            cornerWidth: 1
        }

        Grid {
            id: metadataGrid

            // property real widthPercent: 0.47
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 2
            spacing: 15
            NeonMetadata {
                keyLabel: "RANK"
                valueLabel: root.rank
                width: parent.width * 0.48
                unitLabel: ""
            }
            NeonMetadata {
                keyLabel: "MODULE_COUNT"
                valueLabel: root.moduleCount
                width: parent.width * 0.48
                unitLabel: ""
            }
            NeonMetadata {
                keyLabel: "DURATION"
                valueLabel: root.duration
                width: parent.width * 0.48
                unitLabel: "mm:ss"
            }
            NeonMetadata {
                keyLabel: "CALORIES"
                valueLabel: root.calories
                width: parent.width * 0.48
                unitLabel: "kcal"
            }
            NeonMetadata {
                keyLabel: "IMPROVEMENT"
                valueLabel: root.improvement
                width: parent.width * 0.48
                unitLabel: ""
            }
            NeonMetadata {
                keyLabel: "EFFICIENCY"
                valueLabel: root.efficiency
                width: parent.width * 0.48
                unitLabel: ""
            }
        }

        Column {
            width: parent.width * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            // Layout.alignment: Qt.AlignHCenter
            NeonText {
                label: "TOTALS"
                labelColor: Constants.secondaryTextColor
                size: 14
                cornerWidth: 1
            }
            RowLayout {
                width: parent.width
                NeonText {
                    label: "150x"
                    labelColor: Constants.primaryTextColor
                    size: 22
                }
                NeonText {
                    // TODO: Add maxWidth
                    label: "Burpees"
                    labelColor: Constants.primaryTextColor
                    size: 22
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
            }
            RowLayout {
                width: parent.width
                NeonText {
                    label: "150x"
                    labelColor: Constants.primaryTextColor
                    size: 22
                }
                NeonText {
                    label: "Bulgarian Split Squats"
                    size: 22
                    labelColor: Constants.primaryTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
            }
            RowLayout {
                width: parent.width
                NeonText {
                    label: "150x"
                    labelColor: Constants.primaryTextColor
                    size: 22
                }
                NeonText {
                    label: "Squats"
                    size: 22
                    labelColor: Constants.primaryTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
            }
        }

        Column {
            width: parent.width * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            // Layout.alignment: Qt.AlignHCenter
            NeonText {
                label: "ANALYSIS"
                labelColor: Constants.secondaryTextColor
                size: 14
                cornerWidth: 1
            }
            RowLayout {
                width: parent.width
                NeonText {
                    label: "150x"
                    labelColor: Constants.primaryTextColor
                    size: 18
                }
                NeonText {
                    // TODO: Add maxWidth
                    label: "Burpees"
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
                NeonText {
                    label: "15:23"
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
                NeonText {
                    label: " +1:02"
                    size: 14
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignBottom
                    Layout.alignment: Qt.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
            }
            RowLayout {
                width: parent.width
                NeonText {
                    label: "150x"
                    labelColor: Constants.primaryTextColor
                    size: 18
                }
                NeonText {
                    label: "Bulgarian Split Squats"
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
                NeonText {
                    label: "15:23"
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
                NeonText {
                    label: " -0:02"
                    size: 14
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
            }
            RowLayout {
                width: parent.width
                NeonText {
                    label: "150x"
                    labelColor: Constants.primaryTextColor
                    size: 18
                }
                NeonText {
                    label: "Squats"
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                }
                NeonText {
                    label: "15:23"
                    size: 16
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
                NeonText {
                    label: " +1:02"
                    size: 14
                    labelColor: Constants.primaryTextColor
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                }
            }
        }

        Column {
            width: parent.width * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            // Layout.alignment: Qt.AlignHCenter
            NeonText {
                label: "ACHIEVMENTS"
                labelColor: Constants.secondaryTextColor
                size: 14
                cornerWidth: 1
            }
        }

        NeonEvolution {
            id: evolutionChart
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
