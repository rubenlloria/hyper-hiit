import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ".."


/*
    NeonProtocol Component: Individual training protocol card.
    Designed for Android/Mobile with property injection for C++.
*/
Item {
    id: root
    width: 350
    height: 85

    // Properties for C++ data injection
    property string protocolName: "INFERNO_SEQUENCE"
    property string rankLevel: "root"
    property string estimatedDuration: "129"
    property string moduleCount: "4"
    property real currentProgress: 0.75 // Vaand 1.0
    property real personalBest: 0.60 // Value between 0.0 and 1.0
    property color primaryColor: Constants.primaryColor
    property color secondaryColor: Constants.secondaryColor

    // Card Background and Neon Border
    Rectangle {
        id: backgroundBase
        anchors.fill: parent
        color: "#1a1a1f"
        opacity: 0.8
        border.color: root.primaryColor
        border.width: 1
    }

    // Border Glow Effect
    DropShadow {
        id: borderGlow
        anchors.fill: backgroundBase
        source: backgroundBase
        color: root.primaryColor
        radius: 10
        samples: 15
        spread: 0.2
        transparentBorder: true
    }

    // Content Layout
    Item {
        anchors.fill: parent
        anchors.margins: 12

        // Upper Section: Title and Rank
        NeonText {
            id: titleLabel
            label: root.protocolName
            labelColor: root.primaryColor
            size: 16
            // text: root.protocolName
            // color: root.primaryColor
            // font.family: "Orbitron"
            // font.pixelSize: 16
            // font.bold: true
            anchors.left: parent.left
            anchors.top: parent.top
        }

        Text {
            id: rankLevel
            text: "root"
            color: root.secondaryColor
            font.family: "Share Tech Mono"
            font.pixelSize: 12
            font.bold: true
            anchors.right: parent.right
            anchors.top: parent.top

            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                color: "transparent"
                border.color: root.secondaryColor
                border.width: 1
                opacity: 0.5
            }
        }

        // Middle Section: Technical Data
        Row {
            id: dataRow
            anchors.top: titleLabel.bottom
            anchors.topMargin: 4
            spacing: 15

            Text {
                id: estimatedDuration
                text: "DURATION: " + root.estimatedDuration
                color: "#ffffff"
                opacity: 0.7
                font.family: "Share Tech Mono"
                font.pixelSize: 10
            }

            Text {
                id: moduleCount
                text: "MODULES: " + root.moduleCount
                color: "#ffffff"
                opacity: 0.7
                font.family: "Share Tech Mono"
                font.pixelSize: 10
            }
        }

        // Lower Section: Neon Progress Bar
        Rectangle {
            id: progressTrack
            width: parent.width
            height: 8
            color: "#0d0d10"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5

            // Progress Fill
            Rectangle {
                id: progressFill
                width: parent.width * root.currentProgress
                height: parent.height
                color: root.primaryColor

                // Gradient logic for exceeding PB
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: root.primaryColor
                    }
                    GradientStop {
                        id: gradientMid
                        position: 1.0
                        color: root.primaryColor
                    }
                }
            }

            // Personal Best Marker (Cyan vertical line)
            Rectangle {
                id: pbMarker
                width: 2
                height: parent.height + 6
                color: root.secondaryColor
                anchors.verticalCenter: parent.verticalCenter
                x: parent.width * root.personalBest
                z: 2
            }
        }
    }

    // State for Performance exceeding Personal Best
    states: [
        State {
            name: "record_breaking"
            when: root.currentProgress > root.personalBest
            PropertyChanges {
                target: gradientMid
                color: "#ffffff" // Changes to White-Magenta gradient
            }
            PropertyChanges {
                target: progressFill
                color: "#ffffff"
            }
        }
    ]
}
