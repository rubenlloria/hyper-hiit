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
// import "components"
import "."      // Import current directory to access Constants singleton

Window {
    id: mainWindow
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

    // --- GLOBAL FONT LOADING ---
    // Loading fonts from ui/assets/fonts/ for project-wide availability
    FontLoader { source: Constants.fontUrl("Orbitron-VariableFont_wght.ttf") }
    FontLoader { source: Constants.fontUrl("ShareTechMono-Regular.ttf") }
    FontLoader { source: Constants.fontUrl("lucide.ttf") }

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
                    color: Constants.cyanNeon
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

        // --- FOOTER DATA ---
        NeonFooter {
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
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: "#00fff9"
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
            }
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

    Component.onCompleted: {
        // [DEBUG] Log resolution for scaling verification [Source 27]
        console.log("SYSTEM_READY: Screen Geometry -> " + Screen.width + "x" + Screen.height
                    + "\nOS: " + Qt.platform.os);
        console.log("SYSTEM_READY: App Window -> " + mainWindow.width + "x" + mainWindow.height);
        console.log("SYSTEM_READY: root geometry -> " + root.width + "x" + root.height);
    }
}

/*
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import org.aic.hyperhiit 1.0

import "."

Window {
    id: window
    width: 360
    height: 640
    visible: true
    color: "#000000" // Color de respaldo

    // --- GLOBAL FONT LOADING ---
    // These fonts will be available project-wide once loaded here [1, 2]

    FontLoader {
        id: lucideFont
        source: Constants.fontUrl("lucide.ttf")
    }

    FontLoader {
        id: orbitRegularFont
        source: Constants.fontUrl("Orbit-Regular.ttf")
    }

    FontLoader {
        id: orbitronFont
        source: Constants.fontUrl("Orbitron-VariableFont_wght.ttf")
    }

    FontLoader {
        id: shareTechFont
        source: Constants.fontUrl("ShareTechMono-Regular.ttf")
    }

    // --- CAPA 0: FONDO TÉCNICO ---
    Image {
        id: backgroundImage
        source: "../res/background_tech.png" // Ruta a tu imagen
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop // Se adapta a la pantalla
        opacity: 0.8 // Ajusta la intensidad para que no moleste a la vista
        z: -1 // Se asegura de estar detrás de todo
    }

    // 1. Declare the object FIRST or at the root level
    Chronometer {
        id: myChrono
        onFinished: {
            console.log("Workout Finished!")
        }
    }

    // --- CAPA 1: TU RELOJ Y BOTONES (Encima del fondo) ---
    Row {
        id: timerRow
        anchors {
            top: parent.top
            topMargin: 50
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 2

        // Minutes and Seconds (LARGE)
        Text {
            // We take the first 5 characters "MM:SS"
            text: myChrono.timeText.substring(0, 5)
            color: "#00FF00"
            font.pixelSize: 64 // Increased size for Orbitron
            font.family: "Orbitron"
            font.bold: true
            verticalAlignment: Text.AlignBottom
        }

        // Centiseconds (SMALL)
        Text {
            // We take the last 3 characters ":CC" (including the separator)
            // or just the numbers. Let's use "." + last 2 digits.
            text: "." + myChrono.timeText.substring(6, 8)
            color: "#00FF00"
            font.pixelSize: 32 // Half the size of the main clock
            font.family: "Orbitron"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12 // Adjusted for Orbitron's baseline
            opacity: 0.7
        }
    }

    // Aquí iría tu ProgressDial.qml justo encima del círculo de la imagen
    ProgressDial {
        id: mainProgress
        anchors.centerIn: parent
        value: myChrono.progressValue
        // Si la imagen ya tiene un círculo, puedes ajustar el tamaño
        // de tu ProgressDial para que encaje perfectamente encima.
        anchors.verticalCenterOffset: 10
        anchors.horizontalCenterOffset: 5
    }

    // El Botón Cyber en el centro
    CyberButton {
        id: startButton
        text: "START"
        font.family: orbitronFont.name

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.15 // Se adapta al tamaño de cualquier móvil

        scale: pressed ? 0.95 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        onClicked: {
            console.log("Sistema Iniciado: HYPER//HIIT en marcha")
            // Aquí lanzaremos la lógica del cronómetro más adelante
            myChrono.start(0);
            this.text = "NEXT"
        }

        onPressAndHold: {
            myChrono.stop()
            this.text = "START"
        }
    }

    // Texto decorativo inferior
    Text {
        text: "READY FOR ACTION"
        color: "#444444"
        font.pixelSize: 12
        font.letterSpacing: 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
*/
