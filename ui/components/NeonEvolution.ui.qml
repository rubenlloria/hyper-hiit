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
    color: Constants.blackNeon
    border.color: "#00fff9"
    border.width: 1
    opacity: 0.9

    // --- Technical Properties for Data Binding ---
    property string avgSessions: "2.1"
    property string avgCalories: "514"
    property string improvement: "+23%"
    property color cornerColor: Constants.secondaryColor
    property color cyanColor: "#00fff9"
    property color magentaColor: "#bf00ff"
    property int day1Value: 10
    property int day2Value: 0
    property int day3Value: 40
    property int day4Value: 80
    property int day5Value: 70
    property int day6Value: 20
    property int day7Value: 60

    // 1. Neon Glow Effect (Bloom)
    // DropShadow {
    //     anchors.fill: root
    //     source: root
    //     color: root.cyanColor
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
        anchors.margins: 15
        spacing: 15

        // 3. Header Section
        Row {
            width: parent.width
            spacing: 10

            Text {
                text: "\uea64" // TrendingUp icon from Lucide
                font.family: "lucide"
                font.pixelSize: 16
                color: root.cyanColor
            }

            Text {
                text: "EVOLUTION_METRICS"
                font.family: "Orbitron"
                font.pixelSize: 14
                font.bold: true
                color: root.cyanColor
                Layout.fillWidth: true
            }

            Text {
                text: "LAST_7_DAYS"
                font.family: "Share Tech Mono"
                font.pixelSize: 10
                color: root.cyanColor
                opacity: 0.6
            }
        }

        // 4. Chart Visualization Area [6, 7]
        Item {
            id: chartArea
            // Layout.fillWidth: true
            // Layout.fillHeight: true
            width: parent.width - 40
            height: 80
            anchors.right: parent.right

            // Grid Lines (Simulating the chart axes)
            Rectangle {
                width: 1
                height: parent.height
                color: root.cyanColor
                opacity: 0.2
                y: 0 //-parent.height
            }
            Rectangle {
                width: parent.width
                height: 1
                color: root.cyanColor
                opacity: 0.2
                anchors.bottom: parent.bottom
            }

            // Simulated Line Chart (Sessions - Cyan)
            Shape {
                id: evolutionShape
                anchors.fill: parent
                layer.enabled: true
                // width: 300
                // height: 100

                // layer.effect: DropShadow {
                //     color: root.cyanColor
                //     radius: 8
                //     samples: 15
                // }
                ShapePath {
                    strokeColor: root.cyanColor
                    strokeWidth: 2
                    fillColor: "transparent"
                    startX: 10
                    startY: 80 - root.day1Value
                    strokeStyle: ShapePath.SolidLine
                    PathLine {
                        x: 10 + 1 * (parent.width - 20) / 6
                        y: 80 - root.day2Value
                    }
                    PathLine {
                        x: 10 + 2 * (parent.width - 20) / 6
                        y: 80 - root.day3Value
                    }
                    PathLine {
                        x: 10 + 3 * (parent.width - 20) / 6
                        y: 80 - root.day4Value
                    }
                    PathLine {
                        x: 10 + 4 * (parent.width - 20) / 6
                        y: 80 - root.day5Value
                    }
                    PathLine {
                        x: 10 + 5 * (parent.width - 20) / 6
                        y: 80 - root.day6Value
                    }
                    PathLine {
                        x: 10 + 6 * (parent.width - 20) / 6
                        y: 80 - root.day7Value
                    }
                }
            }
        }

        // TODO: Interactive Points and Hover Logic
        Repeater {
            model: 7
            delegate: Item {
                // Position calculations following your formula [3]
                x: 10 + index * (chartArea.width - 20) / 6
                y: chartArea.height - chartArea.dayValues[index]
                width: 8
                height: 8

                // The Neon Dot
                Rectangle {
                    id: dotPoint
                    anchors.centerIn: parent
                    width: 6
                    height: 6
                    radius: 3
                    color: hoverArea.containsMouse ? root.magentaColor : root.cyanColor
                    border.color: "#ffffff"
                    border.width: hoverArea.containsMouse ? 1 : 0

                    // Neon glow following NeonIcon pattern [4, 5]
                    DropShadow {
                        anchors.fill: parent
                        source: parent
                        color: parent.color
                        radius: hoverArea.containsMouse ? 15 : 8
                        samples: 15
                        opacity: 0.8
                    }
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
                    y: -35 // Positioned above the dot
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 70
                    height: 25
                    color: "#0d0d10"
                    border.color: root.cyanColor
                    border.width: 1
                    z: 100

                    Text {
                        anchors.centerIn: parent
                        text: chartArea.dayLabels[index] + ": " + chartArea.dayValues[index]
                        color: root.cyanColor
                        font.family: "Share Tech Mono" // Digital font [6]
                        font.pixelSize: 9
                    }
                }
            }
        }

        // 5. Bottom Stats Grid [7, 8]
        Row {
            width: parent.width
            height: 50
            spacing: 92
            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "AVG_SESSIONS"
                    color: root.cyanColor
                    opacity: 0.7
                    font.family: "Share Tech Mono"
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: root.avgSessions
                    color: root.cyanColor
                    font.family: "Orbitron"
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
                    color: root.magentaColor
                    opacity: 0.7
                    font.family: "Share Tech Mono"
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: root.avgCalories
                    color: root.magentaColor
                    font.family: "Orbitron"
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
                    color: root.cyanColor
                    opacity: 0.7
                    font.family: "Share Tech Mono"
                    font.pixelSize: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: root.improvement
                    color: root.cyanColor
                    font.family: "Orbitron"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
