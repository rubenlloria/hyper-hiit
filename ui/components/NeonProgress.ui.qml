import QtQuick
import QtQuick.Layouts
import ".."


/*
 * NeonProgress Component: A segmented progress bar for mission phases.
 * Visualizes subsystem completion and Personal Best (PB) marker.
 */
Item {
    id: root
    width: 360
    height: 6

    // Public properties for state and theme
    property var subsystemsModel: [] // Array of subsystem durations/IDs
    property int activeSubsystemIndex: -1
    property real activeSubsystemProgress: 0.5 // Internal progress of the current phase
    property real pbValue: 0.0 // Personal Best position from 0.0 to 1.0
    property color accentColor: Constants.cyanNeon

    RowLayout {
        id: segmentContainer
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: root.subsystemsModel

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: modelData.estimatedDuration || 100
                height: parent.height
                color: index < root.activeSubsystemIndex ? root.accentColor : "transparent"
                border.color: root.accentColor
                border.width: 1
                opacity: index <= root.activeSubsystemIndex ? 1.0 : 0.3

                // Inner progress for the active segment
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * (index === root.activeSubsystemIndex ? root.activeSubsystemProgress : 0)
                    color: root.accentColor
                    visible: index === root.activeSubsystemIndex

                    // Simple glow for the active part
                    layer.enabled: true
                }
            }
        }
    }

    // Personal Best (PB) Marker [Source 27]
    Rectangle {
        id: pbMarker
        x: (root.width * root.pbValue) - 1
        y: -4
        width: 2
        height: root.height + 8
        color: Constants.terminalGreen
        visible: root.pbValue > 0

        Text {
            text: "PB"
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.color
            font.family: Constants.techFont.family
            font.pixelSize: 8
        }
    }
}
