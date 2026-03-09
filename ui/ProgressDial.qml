import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real value: 0.75 // Valor de 0.0 a 1.0
    property color accentColor: "#00FFFF" // Cian neón

    width: 300
    height: 300

    // Rectangle {
    //         anchors.fill: parent
    //         color: "#ffffff"
    //         z: -1
    //     }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8 // Suavizado de bordes de alta calidad

        // 1. Carril de fondo (Gris oscuro)
        ShapePath {
            fillColor: "transparent"
            strokeColor: "#1A1A1A"
            strokeWidth: 15
            capStyle: ShapePath.RoundCap // Bordes redondeados

            PathAngleArc {
                centerX: root.width / 2; centerY: root.height / 2
                radiusX: root.width / 2 - 20; radiusY: root.height / 2 - 20
                startAngle: -90
                sweepAngle: 360
            }
        }

        // 2. Anillo de Progreso UNIDO y REDONDEADO
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.accentColor
            strokeWidth: 15
            strokeStyle: ShapePath.SolidLine // Línea continua
            capStyle: ShapePath.RoundCap // ESTO redondea las puntas del anillo

            PathAngleArc {
                centerX: root.width / 2; centerY: root.height / 2
                radiusX: root.width / 2 - 20; radiusY: root.height / 2 - 20
                startAngle: -90
                sweepAngle: 360 * root.value
            }
        }

        // 3. Brillo de contorno (Glow sutil)
        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.alpha(root.accentColor, 0.3)
            strokeWidth: 2

            PathAngleArc {
                centerX: root.width / 2; centerY: root.height / 2
                radiusX: root.width / 2 - 5; radiusY: root.height / 2 - 5
                startAngle: -90
                sweepAngle: 360
            }
        }
    }

    // Textos centrales (Situs / Reps)
    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            text: "30x"
            color: "white"
            font.pixelSize: 45
            font.bold: true
            font.family: "Monospace"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: "BURPEES"
            color: root.accentColor
            font.pixelSize: 18
            font.letterSpacing: 4
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
