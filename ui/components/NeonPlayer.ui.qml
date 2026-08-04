/****************************************************************************
** File: NeonPlayer.ui.qml
** Date: 27/5/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "."
import ".."

Item {
    id: root
    width: 412
    height: 40

    // Core playback properties for Neural Sync
    property bool isPlaying: false
    property bool isOpen: false
    property string trackMetadata: "ARTIST - TITLE"
    property real trackProgress: 0.0 // Value from 0.0 to 1.0
    property color accentColor: Constants.primaryColor

    // Interaction aliases for the functional .qml wrapper
    property alias playMouseArea: playInteraction
    property alias marqueeSwipeArea: swipeInteraction

    states: [
        State {
            name: "scrolling"
            when: metadataText.shouldAnimate
        },
        State {
            name: "idle"
            when: !metadataText.shouldAnimate
            PropertyChanges {
                target: metadataText
                x: 0
            }
        }
    ]

    // 1. TOP PROGRESS BAR (Neon Magenta Line)
    Rectangle {
        id: progressBackground
        width: parent.width
        height: 2
        color: Constants.backgroundColor
        anchors.top: parent.top

        Rectangle {
            id: progressFill
            width: parent.width * root.trackProgress
            height: parent.height
            color: Constants.descriptionColor

            // Neon glow effect for the progress line
            layer.enabled: true
            layer.effect: DropShadow {
                color: root.accentColor
                radius: 4
                samples: 12
                spread: 0.5
            }
        }
    }

    // 2. MAIN PLAYER BODY
    Rectangle {
        id: body
        anchors.top: progressBackground.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        color: Constants.secondaryDarkColor
        opacity: 0.85

        RowLayout {
            anchors.fill: parent
            // anchors.margins: 0
            spacing: 10

            // PLAY/PAUSE CONTROL
            Item {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40

                NeonIcon {
                    id: playbackIcon
                    anchors.centerIn: parent
                    glyph: root.isPlaying ? Constants.pauseIcon : Constants.playIcon
                    color: root.isPlaying ? Constants.primaryColor : Constants.secondaryColor
                    size: 30
                }

                MouseArea {
                    id: playInteraction
                    anchors.fill: parent
                }
            }

            // MARQUEE METADATA DISPLAY
            Item {
                id: marqueeContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Text {
                    id: metadataText
                    text: root.trackMetadata
                    color: Constants.primaryTextColor
                    font.family: Constants.mainFont.family
                    font.bold: true
                    font.letterSpacing: 2
                    font.pixelSize: 14
                    x: 0

                    anchors.verticalCenter: parent.verticalCenter
                    readonly property bool shouldAnimate: width > marqueeContainer.width

                    // Marquee animation logic
                    NumberAnimation on x {
                        from: marqueeContainer.width
                        to: -metadataText.width
                        duration: 10000
                        loops: Animation.Infinite
                        running: metadataText.shouldAnimate
                    }
                }

                // Swipe interaction for Track Navigation (Next/Prev)
                MouseArea {
                    id: swipeInteraction
                    anchors.fill: parent
                    preventStealing: true

                    // Logic for swiping will be handled in the functional side
                    // using drag.axis: Drag.XAxis or gesture recognizers.
                }
            }
        }
    }
}
