import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import ".."


/*
    NeonEvolution Component: Evolution Metrics dashboard widget.
    Based on Screenshot_20260301_175637.png [1].
    Strictly declarative .ui.qml format.
*/
Rectangle {
    id: root
    width: 380
    height: 200
    color: Constants.backgroundColor
    border.color: Constants.secondaryColor
    border.width: 1
    opacity: 0.9

    // --- Technical Properties for Data Binding ---
    property string ghostSessions: "3"
    property string ghostCalories: "300"
    property string avgSessions: "2.1"
    property string avgCalories: "514"
    property string improvement: "+23"
    property string efficiency: "+48"
    property color cornerColor: Constants.secondaryColor
    property int day1Value: 10
    property int day2Value: 0
    property int day3Value: 40
    property int day4Value: 75
    property int day5Value: 70
    property int day6Value: 20
    property int day7Value: 60
    property var telemetry: []
    property var lastTelemetry: []
    property alias evolutionShape: evolutionShape
    property alias topLabel: topLabel.text
    property alias centerLabel: centerLabel.text
    property alias evolutionTitle: evoTitle.label
    property alias evolutionInfo: evoInfo.text

    // 1. Neon Glow Effect (Bloom)
    // DropShadow {
    //     anchors.fill: root
    //     source: root
    //     color: Constants.secondaryColor
    //     radius: 15
    //     samples: 25
    //     spread: 0.15
    //     transparentBorder: true
    // }

    // 2. Tech Corners (Brackets)
    Item {
        id: techCorners
        anchors.fill: parent
        // Top-Left
        Rectangle {
            width: 12
            height: 2
            color: root.cornerColor
            x: -1
            y: -1
        }
        Rectangle {
            width: 2
            height: 12
            color: root.cornerColor
            x: -1
            y: -1
        }
        // Top-Right
        Rectangle {
            width: 12
            height: 2
            color: root.cornerColor
            x: parent.width - 11
            y: -1
        }
        Rectangle {
            width: 2
            height: 12
            color: root.cornerColor
            x: parent.width - 1
            y: -1
        }
        // Bottom-Left
        Rectangle {
            width: 12
            height: 2
            color: root.cornerColor
            x: -1
            y: parent.height - 1
            anchors.bottom: parent.bottom
        }
        Rectangle {
            width: 2
            height: 12
            color: root.cornerColor
            x: -1
            y: parent.height - 11
            anchors.bottom: parent.bottom
        }
        // Bottom-Right
        Rectangle {
            width: 12
            height: 2
            color: root.cornerColor
            x: parent.width - 11
            y: parent.height - 1
            anchors.bottom: parent.bottom
        }
        Rectangle {
            width: 2
            height: 12
            color: root.cornerColor
            x: parent.width - 1
            y: parent.height - 11
            anchors.bottom: parent.bottom
        }
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: anchors.leftMargin
        spacing: 10

        // 3. Header Section
        RowLayout {
            width: parent.width
            spacing: 5

            NeonIcon {
                glyph: Constants.evolutionIcon // TrendingUp icon from Lucide
                size: 20
                color: Constants.secondaryColor
                Layout.alignment: Qt.AlignVCenter
            }

            NeonText {
                id: evoTitle
                label: "EVOLUTION_METRICS"
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                labelColor: Constants.primaryTextColor
                cornerWidth: 1
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    id: evoInfo
                    text: "LAST_7_DAYS"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    color: Constants.primaryTextColor
                    opacity: 0.6
                }
            }
        }

        // 4. Chart Visualization Area [6, 7]
        Item {
            id: graphView
            width: parent.width - 30
            height: 100
            anchors.right: parent.right
            Item {
                id: chartArea
                // Layout.fillWidth: true
                // Layout.fillHeight: true
                width: parent.width - 30
                height: 80
                anchors.right: parent.right

                // Grid Lines (Simulating the chart axes)
                Rectangle {
                    width: 1
                    height: parent.height
                    color: Constants.secondaryColor
                    opacity: 0.3
                    y: -5 //-parent.height
                }
                Rectangle {
                    id: bottomLine
                    width: parent.width + 5
                    height: 1
                    color: Constants.secondaryColor
                    opacity: 0.3
                    anchors.top: parent.bottom
                    anchors.topMargin: -5
                    x: -5
                }

                Rectangle {
                    id: centerLine
                    width: parent.width + 5
                    height: 1
                    color: Constants.secondaryColor
                    opacity: 0.2
                    anchors.top: parent.top
                    anchors.topMargin: parent.height / 2 - 5
                    x: -5
                    z: 0
                }

                Rectangle {
                    id: topLine
                    width: parent.width + 5
                    height: 1
                    color: Constants.secondaryColor
                    opacity: 0.2
                    anchors.top: parent.top
                    anchors.topMargin: -5
                    x: -5
                    z: 0
                }

                Text {
                    id: topLabel
                    text: "100%"
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    color: Constants.secondaryColor
                    opacity: 0.6
                    anchors.verticalCenter: topLine.verticalCenter
                    anchors.topMargin: -50
                    anchors.right: parent.left
                    anchors.rightMargin: 10
                }

                Text {
                    id: centerLabel
                    text: "50%"
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    color: Constants.secondaryColor
                    opacity: 0.6
                    anchors.verticalCenter: centerLine.verticalCenter
                    anchors.right: parent.left
                    anchors.rightMargin: 10
                }

                Text {
                    text: "0"
                    font.family: Constants.techFont.family
                    font.pixelSize: 10
                    color: Constants.secondaryColor
                    opacity: 0.6
                    anchors.verticalCenter: bottomLine.verticalCenter
                    anchors.bottomMargin: 0
                    anchors.right: parent.left
                    anchors.rightMargin: 10
                }

                Shape {
                    id: lastShape
                    anchors.fill: parent
                    layer.enabled: true
                    opacity: 0.5
                    // width: 300
                    // height: 100

                    // layer.effect: DropShadow {
                    //     color: Constants.secondaryColor
                    //     radius: 8
                    //     samples: 15
                    // }
                    ShapePath {
                        strokeColor: Constants.primaryColor
                        strokeWidth: 2
                        fillColor: "transparent"
                        startX: 10
                        startY: chartArea.height - root.lastTelemetry[0].barHeight - 5
                        strokeStyle: ShapePath.SolidLine
                        pathHints: ShapePath.PathQuadratic
                        joinStyle: ShapePath.MiterJoin
                        capStyle: ShapePath.RoundCap

                        PathCurve {
                            x: 10 + 1 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.lastTelemetry[1].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 2 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.lastTelemetry[2].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 3 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.lastTelemetry[3].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 4 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.lastTelemetry[4].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 5 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.lastTelemetry[5].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 6 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.lastTelemetry[6].barHeight - 5
                        }
                    }
                }

                // TODO: Interactive Points and Hover Logic
                Repeater {
                    // model: [root.day1Value, root.day2Value, root.day3Value, root.day4Value, root.day5Value, root.day6Value, root.day7Value]
                    model: root.lastTelemetry
                    delegate: Item {
                        // Position calculations following your formula [3]
                        x: 6 + index * ((chartArea.width - 20) / 6)
                        y: chartArea.height - modelData.barHeight - 9
                        width: 8
                        height: 8

                        // The Neon Dot
                        Rectangle {
                            id: lastDotPoint
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: Constants.primaryColor
                            opacity: 0.6
                            border.color: Constants.descriptionColor
                            border.width: 0
                        }
                    }
                }

                // Simulated Line Chart (Sessions - Cyan)
                Shape {
                    id: evolutionShape
                    anchors.fill: parent
                    layer.enabled: true
                    // width: 300
                    // height: 100

                    // layer.effect: DropShadow {
                    //     color: Constants.secondaryColor
                    //     radius: 8
                    //     samples: 15
                    // }
                    ShapePath {
                        strokeColor: Constants.secondaryColor
                        strokeWidth: 2
                        fillColor: "transparent"
                        startX: 10
                        startY: chartArea.height - root.telemetry[0].barHeight - 5
                        strokeStyle: ShapePath.SolidLine
                        pathHints: ShapePath.PathQuadratic
                        joinStyle: ShapePath.MiterJoin
                        capStyle: ShapePath.RoundCap

                        PathCurve {
                            x: 10 + 1 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.telemetry[1].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 2 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.telemetry[2].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 3 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.telemetry[3].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 4 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.telemetry[4].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 5 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.telemetry[5].barHeight - 5
                        }
                        PathCurve {
                            x: 10 + 6 * ((chartArea.width - 20) / 6)
                            y: chartArea.height - root.telemetry[6].barHeight - 5
                        }
                    }
                }

                // TODO: Interactive Points and Hover Logic
                Repeater {
                    // model: [root.day1Value, root.day2Value, root.day3Value, root.day4Value, root.day5Value, root.day6Value, root.day7Value]
                    model: root.telemetry
                    delegate: Item {
                        // Position calculations following your formula [3]
                        x: 6 + index * ((chartArea.width - 20) / 6)
                        y: chartArea.height - modelData.barHeight - 9
                        width: 8
                        height: 8

                        // The Neon Dot
                        Rectangle {
                            id: dotPoint
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: Constants.secondaryColor
                            border.color: Constants.descriptionColor
                            border.width: hoverArea.containsMouse ? 1 : 0

                            // Neon glow following NeonIcon pattern [4, 5]
                            // DropShadow {
                            //     anchors.fill: parent
                            //     source: parent
                            //     color: parent.color
                            //     radius: hoverArea.containsMouse ? 15 : 8
                            //     samples: 15
                            //     opacity: 0.8
                            // }
                        }

                        // Hover Detection Area
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            anchors.margins: -10 // Makes the hit area larger and easier to touch
                            hoverEnabled: true
                        }

                        // Tooltip Popup (Visible on Hover)
                        Rectangle {
                            id: tooltip
                            visible: hoverArea.containsMouse
                            y: -45 // Positioned above the dot
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 70
                            height: 25
                            color: Constants.surfaceColor
                            border.color: Constants.primaryColor
                            border.width: 1
                            z: 100

                            Text {
                                anchors.centerIn: parent
                                text: modelData.kcal + " Kcal "
                                color: Constants.secondaryColor
                                font.family: Constants.techFont.family // Digital font
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
            RowLayout {
                height: 21
                width: parent.width - 30
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 28
                Repeater {
                    model: root.telemetry
                    Text {
                        Layout.fillWidth: true
                        text: modelData.day
                        color: Constants.secondaryColor
                        font.family: Constants.techFont.family // Digital font
                        font.pixelSize: 11
                    }
                }
            }
        }

        // 5. Bottom Stats Grid
        RowLayout {
            width: parent.width
            height: 50
            // spacing: 43
            // Layout.fillWidth: true
            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "AVG_SESSIONS"
                    color: Constants.primaryTextColor
                    opacity: 0.7
                    font.family: Constants.techFont.family
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                NeonText {
                    label: root.avgSessions
                    labelColor: root.avgSessions >= root.ghostSessions ? Constants.primaryTextColor : Constants.secondaryTextColor
                    font.family: Constants.mainFont.family
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "AVG_CALORIES"
                    color: Constants.primaryTextColor
                    opacity: 0.7
                    font.family: Constants.techFont.family
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                NeonText {
                    label: root.avgCalories + "k"
                    labelColor: root.avgCalories >= root.ghostCalories ? Constants.primaryTextColor : Constants.secondaryTextColor
                    font.family: Constants.mainFont.family
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "IMPROVEMENT"
                    color: Constants.primaryTextColor
                    opacity: 0.7
                    font.family: Constants.techFont.family
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                NeonText {
                    label: root.improvement + "%"
                    labelColor: root.improvement
                                > 0 ? Constants.primaryTextColor : Constants.secondaryTextColor
                    font.family: Constants.mainFont.family
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "EFFICIENCY"
                    color: Constants.primaryTextColor
                    opacity: 0.7
                    font.family: Constants.techFont.family
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                NeonText {
                    label: root.efficiency + "%"
                    labelColor: root.efficiency
                                >= 0 ? Constants.primaryTextColor : Constants.secondaryTextColor
                    font.family: Constants.mainFont.family
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
