import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import ".."


/*
    NeonAchievement Component: Achievement Badges dashboard widget.
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
    property color cornerColor: Constants.secondaryColor
    property alias achievementMatrix: achievementMatrix

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
                glyph: Constants.badgeIcon // TrendingUp icon from Lucide
                size: 20
                color: Constants.secondaryColor
                Layout.alignment: Qt.AlignVCenter
            }

            NeonText {
                id: evoTitle
                label: "ACHIEVEMENT_MATRIX"
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                labelColor: Constants.secondaryColor
                cornerWidth: 1
            }
            Item {
                // Expander
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
        GridLayout {
            id: achievementMatrix
            width: parent.width
            height: 145
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 5
            rowSpacing: 15
            columnSpacing: 10
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

            // NEURAL SYNC: Dynamic generation based on C++ model
            Repeater {
                id: achievementRepeater
                // Accessing the QList<QObject*> achievements property from C++
                model: achievementManager.achievements

                delegate: NeonBadge {
                    // Layout scale fixed at 60px per requirement
                    size: 60

                    // Mapping C++ properties to UI components
                    // modelData is the Achievement object from the QList
                    glyph: achievementMatrix.iconMap[modelData.icon] || "x"
                    unlocked: modelData.unlocked

                    // Optional: The name/description can be used for tooltips
                }
            }
        }
    }
}
