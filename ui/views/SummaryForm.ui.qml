
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
    color: Constants.darkNeon
    property alias header: header
    property alias totalsRepeater: totalsRepeater
    property alias analysisRepeater: analysisRepeater
    property alias rankMetadata: rankMetadata.valueLabel
    property alias countMetadata: countMetadata.valueLabel
    property alias durationMetadata: durationMetadata.valueLabel
    property alias caloriesMetadata: caloriesMetadata.valueLabel
    property alias improvementMetadata: improvementMetadata.valueLabel
    property alias efficiencyMetadata: efficiencyMetadata.valueLabel

    property int activeSessionId: 0
    property string protocolName: "PROTOCOL_NAME"
    property string sessionDate: "01/01/1970 00:00h"

    property int activeProtocolId: 0
    property string rank: "NEWBIE"
    property int calories: 123
    property int moduleCount: 0
    property bool hasGhost: true
    property string duration: "00:00"
    property int timeDiff: 0
    property string timeDiffString: "+hh:mm"
    property int efficiency: 96
    property int improvement: 46

    ColumnLayout {
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
            buttonLabel: "DASHBOARD"
            buttonGlyph: Constants.dashboardIcon
        }

        Flickable {
            id: summaryScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            contentHeight: mainLayout.implicitHeight - 20
            clip: true // Critical: prevents content from bleeding outside the shard [Source 95]
            boundsBehavior: Flickable.StopAtBounds

            // Custom Neon Scrollbar (v0.3 Fuchsia Aesthetic)
            ScrollBar.vertical: ScrollBar {
                parent: root
                policy: ScrollBar.AlwaysOn
                width: 0

                contentItem: Rectangle {
                    implicitWidth: 4
                    color: Constants.fuchsiaNeon // Fuchsia scrollbar as per Roadmap [Source 34, 188]
                    radius: 2
                }
            }

            Column {
                id: mainLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                leftPadding: 20
                rightPadding: 20
                topPadding: 10
                width: parent.width
                spacing: 25

                NeonText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: protocolName
                    size: 35
                    cornerWidth: 1
                }

                NeonText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    label: sessionDate //"01/01/1970 00:00h"
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
                        id: rankMetadata
                        keyLabel: "RANK"
                        valueLabel: root.rank
                        width: parent.width * 0.48
                        unitLabel: ""
                    }
                    NeonMetadata {
                        id: countMetadata
                        keyLabel: "MODULE_COUNT"
                        valueLabel: root.moduleCount
                        width: parent.width * 0.48
                        unitLabel: ""
                    }
                    NeonMetadata {
                        id: durationMetadata
                        keyLabel: "DURATION"
                        valueLabel: root.hasGhost ? root.duration + " "
                                                    + root.timeDiffString : root.duration
                        width: parent.width * 0.48
                        color: timeDiff
                               > 0 ? Constants.secondaryTextColor : Constants.primaryTextColor
                        unitLabel: "mm:ss"
                        valueSize: 22
                    }
                    NeonMetadata {
                        id: caloriesMetadata
                        keyLabel: "CALORIES"
                        valueLabel: root.calories
                        width: parent.width * 0.48
                        unitLabel: "kcal"
                    }
                    NeonMetadata {
                        id: improvementMetadata
                        keyLabel: "IMPROVEMENT"
                        valueLabel: root.improvement + "%"
                        width: parent.width * 0.48
                        color: improvement
                               < 0 ? Constants.secondaryTextColor : Constants.primaryTextColor
                        unitLabel: ""
                    }
                    NeonMetadata {
                        id: efficiencyMetadata
                        keyLabel: "EFFICIENCY"
                        valueLabel: root.efficiency + "%"
                        width: parent.width * 0.48
                        color: efficiency
                               < 0 ? Constants.secondaryTextColor : Constants.primaryTextColor
                        unitLabel: ""
                    }
                }

                Column {
                    width: parent.width * 0.9
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Layout.alignment: Qt.AlignHCenter
                    NeonTitle {
                        label: "TOTALS"
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: 14
                    }

                    Repeater {
                        id: totalsRepeater

                        RowLayout {
                            width: parent.width

                            NeonText {
                                // Combines quantity and unit (e.g., "150x")
                                label: modelData.quantity + modelData.unit
                                labelColor: Constants.primaryTextColor
                                size: 22
                            }

                            NeonText {
                                label: modelData.name
                                labelColor: Constants.primaryTextColor
                                size: 22
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignBottom
                            }
                        }
                    }
                }

                Column {
                    id: analysisContainer
                    width: parent.width * 0.9
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Layout.alignment: Qt.AlignHCenter
                    NeonTitle {
                        label: "ANALYSIS"
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: 14
                    }

                    Repeater {
                        id: analysisRepeater

                        // This is your SummaryList.ui.qml component
                        SummaryList {
                            width: analysisContainer.width

                            // Map the C++ VariantMap keys to your component properties
                            subsystemId: modelData.subsystemId
                            modulesModel: modelData.modulesModel

                            // Optional: The line color can be customized per directive theme
                            color: Constants.cyanNeon
                        }
                    }
                }

                Column {
                    width: parent.width * 0.9
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Layout.alignment: Qt.AlignHCenter
                    NeonTitle {
                        label: "ACHIEVMENTS"
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: 14
                    }

                    Flow {
                        id: achievementsFlow
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        leftPadding: 6.9
                        rightPadding: leftPadding
                        topPadding: 15
                        bottomPadding: topPadding

                        readonly property var iconMap: {
                            "activity": Constants.activityIcon,
                            "fire": Constants.fireIcon,
                            "shield": Constants.shieldIcon,
                            "ffwd": Constants.ffwIcon,
                            "timer": Constants.timerIcon,
                            "crown": Constants.crownIcon,
                            "cpu": Constants.cpuIcon,
                            "log-in": Constants.loginIcon,
                            "ghost": Constants.ghostIcon,
                            "layers": Constants.layersIcon
                        }

                        Repeater {
                            id: newBadgesRepeater
                            // NEURAL SYNC: Mapping the delta list
                            model: sessionNewAchievements

                            delegate: NeonBadge {
                                size: 55
                                // Direct binding to Badge.h properties [1, 3]
                                glyph: achievementsFlow.iconMap[modelData.icon]
                                       || "X"
                                unlocked: true

                                // Note: The white flash animation we built for NeonBadge.ui.qml
                                // will trigger automatically as 'unlocked' becomes true
                                // in this view [Source context: previous conversation].
                            }
                        }
                    }
                }

                // NeonEvolution {
                //     id: evolutionChart
                //     anchors.horizontalCenter: parent.horizontalCenter
                //     evolutionInfo: "LAST_SESSIONS"
                // }
                Column {
                    // TODO: Improve spacer to prevent footer overlap last module
                    height: Constants.bottomMargin
                    width: 20
                }
            }
        }
    }
}
