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
    // Text {
    //     id: mainTimer
    //     text: "00:03:47.2"
    //     color: "#00FF00" // Verde neón como en tu captura
    //     font.pixelSize: 48
    //     font.family: "Monospace"
    //     anchors {
    //         top: parent.top
    //         topMargin: 50
    //         horizontalCenter: parent.horizontalCenter
    //     }
    // }
    Row {
        id: timerRow
        anchors {
            top: parent.top
            topMargin: 50
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 2 // Espacio mínimo entre el tiempo y las milésimas

        // Minutos y Segundos (GRANDES)
        Text {
            text: "00:03:47"
            color: "#00FF00"
            font.pixelSize: 48
            font.family: "Monospace"
            font.bold: true
            verticalAlignment: Text.AlignBottom
        }

        // Milésimas (PEQUEÑAS)
        Text {
            text: ".2"
            color: "#00FF00"
            font.pixelSize: 24 // La mitad del tamaño
            font.family: "Monospace"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8 // Ajuste fino para que alineen por la base
            opacity: 0.8 // Un poco de transparencia para dar jerarquía
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
