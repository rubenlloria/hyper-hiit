import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Window {
    id: window
    width: 360
    height: 640
    visible: true
    color: "#000000" // Color de respaldo

    FontLoader { id: orbitronFont; source: "assets/fonts/Orbitron-VariableFont_wght.ttf" }

    // --- CAPA 0: FONDO TÉCNICO ---
    Image {
        id: backgroundImage
        source: "qrc:/res/background_tech.png" // Ruta a tu imagen
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop // Se adapta a la pantalla
        opacity: 0.8 // Ajusta la intensidad para que no moleste a la vista
        z: -1 // Se asegura de estar detrás de todo
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
        anchors.centerIn: parent
        value: 0.6
        // Si la imagen ya tiene un círculo, puedes ajustar el tamaño
        // de tu ProgressDial para que encaje perfectamente encima.
        anchors.verticalCenterOffset: 10
        anchors.horizontalCenterOffset: 5
    }

    // El Botón Cyber en el centro
    CyberButton {
        id: startButton
        text: "START"
        font.family: customFont.name

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.15 // Se adapta al tamaño de cualquier móvil

        scale: pressed ? 0.95 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        onClicked: {
            console.log("Sistema Iniciado: HYPER//HIIT en marcha")
            // Aquí lanzaremos la lógica del cronómetro más adelante
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
