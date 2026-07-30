/****************************************************************************
** File: main.qml
** Date: 18/2/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import Qt5Compat.GraphicalEffects
import org.aic.hyperhiit 1.0
import "views" // Import folder containing Dashboard, Architect and Protocol views
import "components"
import "."      // Import current directory to access Constants singleton

Window {
    id: mainWindow

    readonly property string debugName: "main.qml"
    readonly property string infoName: "main.qml"

    property color currentDirectiveColor: Constants.primaryTextColor
    property alias mainStack: mainStack

    width: Constants.designWidth    // Value 412 defined in Constants.qml
    height: Constants.designHeight  // Value 865 defined in Constants.qml
    visible: true
    title: "HyperHIIT - System Interface"
    color: Constants.backgroundColor // Background color from Constants.qml
    visibility: Qt.platform.os === "android" ? Window.FullScreen : Window.Windowed


    // Logic to update the scale factor dynamically
    onWidthChanged: {
        Constants.scaleFactor = mainWindow.width / Constants.designWidth
    }

    // Keep Aspect Ratio (Desktop Only)
    Binding {
        target: mainWindow
        property: "height"
        value: mainWindow.width * (Constants.designHeight / Constants.designWidth)
        when: Qt.platform.os !== "android"
    }

    // Global aesthetic synchronization
    Binding {
        target: Constants
        property: "activeTheme"
        // Link the active palette to the index retrieved from the system manager
        value: Constants.themes[Constants.themeKeys[systemManager.systemTheme]]
    }

    // --- GLOBAL FONT LOADING ---
    // Loading fonts from ui/assets/fonts/ for project-wide availability
    FontLoader { source: Constants.fontUrl("Orbitron-VariableFont_wght.ttf") }
    FontLoader { source: Constants.fontUrl("ShareTechMono-Regular.ttf") }
    FontLoader { source: Constants.fontUrl("lucide.ttf") }

    Timer {
        id: delayedExit
        interval: 1000 // Sufficient time for HWUI to detach
        onTriggered: Qt.quit()
    }

    Item {
        id: root
        width: Constants.designWidth
        height: Constants.designHeight
        anchors.centerIn: parent
        // Apply the transformation
        scale: Constants.scaleFactor
        // Add margins to prevent UI overlapping with physical notches
        // Fallback to 0 if margins are undefined (Desktop/Generic targets)
        anchors.topMargin: Screen.safeAreaMargins ? Screen.safeAreaMargins.top : 0
        anchors.bottomMargin: Screen.safeAreaMargins ? Screen.safeAreaMargins.bottom : 0
        anchors.leftMargin: Screen.safeAreaMargins ? Screen.safeAreaMargins.left : 0
        anchors.rightMargin: Screen.safeAreaMargins ? Screen.safeAreaMargins.right : 0

        // Wrap the StackView in a Flickable
        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: mainStack.implicitHeight

            // Disable interaction if content fits perfectly
            interactive: contentHeight > height
            // Prevent the "bouncing" effect at the edges
            boundsBehavior: Flickable.StopAtBounds
            // Custom ScrollBar configuration
            ScrollBar.vertical: ScrollBar {
                id: vbar
                width: 1 // Precisely 1px wide as requested
                policy: ScrollBar.AsNeeded

                // Neon Cyberpunk look
                contentItem: Rectangle {
                    color: Constants.secondaryColor
                    opacity: 0.8
                }
            }
            // --- NAVIGATION MANAGER (StackView) ---
            StackView {
                id: mainStack
                anchors.fill: parent

                // Dashboard is established as the project's initial screen
                initialItem: Dashboard {
                    id: mainDashboard
                }
            }
        }

        NeonPlayer {
            id: player
            visible: systemManager.systemAudio
            anchors.bottom: footer.top
            isPlaying: mediaController.isPlaying
            trackProgress: (mediaController.trackProgress > 0)
                           ? mediaController.trackProgress
                           : 0.0

            trackMetadata: mediaController.notificationAccessGranted
                           ? mediaController.trackMetadata
                           : "AUDIO UPLINK: NOT GRANTED"

            property real startX: 0

            // Playback Toggle
            playMouseArea.onClicked: {
                if (mainWindow.checkAudioUplink()) {
                    mediaController.togglePlayback();
                }
            }

            // Swipe Navigation Logic (Android Optimized)
            marqueeSwipeArea.onPressed: (mouse) => {
                                            player.startX = mouse.x;
                                        }

            marqueeSwipeArea.onReleased: (mouse) => {
                                             if (!mainWindow.checkAudioUplink()) {
                                                    return;
                                                }
                                             let delta = mouse.x - player.startX;
                                             if (Math.abs(delta) > 50) { // Threshold for tactical activation
                                                 if (delta > 0) {
                                                     mediaController.previousTrack();
                                                 } else {
                                                     mediaController.nextTrack();
                                                 }
                                             } else {
                                                 mediaController.togglePlayback();
                                             }
                                         }

            onVisibleChanged: {
                if (visible) {
                    mainWindow.checkAudioUplink()
                }
            }
        }

        // --- FOOTER DATA ---
        NeonFooter {
            id: footer
            anchors.bottom: parent.bottom
        }

        // --- SCANLINES EFFECT (.scanlines de cyberpunk.css) ---
        Rectangle {
            id: scanlines
            width: parent.width
            height: 10
            // anchors.fill: parent
            // anchors.fill
            opacity: 0.2
            z: 50

            visible: systemManager.systemScanline

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: Constants.secondaryColor
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
            PropertyAnimation on y {
                from: -10
                to: root.height
                duration: 3000
                loops: Animation.Infinite
                running: systemManager.systemScanline
            }
        }

        ConfirmPopup {
            id: confirmPopup
            width: mainWindow.width
            height: mainWindow.height
        }
    }

    // --- NAVIGATION FUNCTIONS ---
    // These functions enable screen switching from any component within the app
    function openArchitect() {
        mainStack.push("views/Architect.qml") // Navigates to the Architect view
    }

    function openProtocol() {
        mainStack.push("views/Protocol.qml")  // Navigates to the Protocol view
    }

    function goBack() {
        if (mainStack.depth > 1) {
            mainStack.pop() // Returns to the previous screen if stack depth permits
        }
    }

    // Function to handle a safe exit sequence
    function safeExit() {
        Constants.hInfo(infoName, "Initiating safe system shutdown protocol.");
        mainWindow.hide(); // Force Android surface detachment to prevent HWUI crash
        delayedExit.start();
    }

    function checkAudioUplink() {
        if (mediaController.notificationAccessGranted) {
            return true
        }
        confirmPopup.target = "AUDIO // UPLINK";
        confirmPopup.message = "hyper//hiit requires notification access to sync playback data. Enable it in Android Settings to continue."
        confirmPopup.enableCancel = false;
        confirmPopup.onAccept = function() {
            mediaController.requestNotificationAccess()
        }
        confirmPopup.open()

        return false
    }


    Component.onCompleted: {
        // [DEBUG] Log resolution for scaling verification [Source 27]
        Constants.hInfo(infoName, "SYSTEM_READY: Screen Geometry -> " + Screen.width + "x" + Screen.height
                    + " | OS: " + Qt.platform.os);
        Constants.hInfo(infoName, "SYSTEM_READY: App Window -> " + mainWindow.width + "x" + mainWindow.height);
        Constants.hInfo(infoName, "SYSTEM_READY: root geometry -> " + root.width + "x" + root.height);
        // Constants.setTheme(systemManager.systemTheme);
    }

    Connections {
        target: systemManager

        function onSystemThemeChanged() {
            Constants.hInfo("main.qml", "Updating theme");
            Constants.setTheme(systemManager.systemTheme);
        }
    }
}
