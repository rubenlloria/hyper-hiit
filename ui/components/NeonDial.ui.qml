import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: root
    property real value: 0.75 // Valor de 0.0 a 1.0
    property color dialColor: Constants.secondaryColor
    property color dialBgColor: Constants.darkNeon
    property alias quantity: quantity.text
    property string unit: unit
    property alias dialMessage: dialMessage.label
    property color messageColor: Constants.secondaryColor
    property int size: 200
    property alias dialMouseArea: interactionArea

    width: root.size + 50
    height: root.size + 50

    // Rectangle {
    //         anchors.fill: parent
    //         color: "#ffffff"
    //         z: -1
    //     }
    Shape {
        anchors.fill: parent
        anchors.centerIn: parent
        layer.enabled: true
        layer.samples: 8 // Suavizado de bordes de alta calidad

        // 1. Carril de fondo (Gris oscuro)
        ShapePath {
            id: grooveRing
            fillColor: "transparent"
            strokeColor: root.dialBgColor
            strokeWidth: 15
            capStyle: ShapePath.RoundCap // Bordes redondeados

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.size / 2 - 20
                radiusY: root.size / 2 - 20
                startAngle: -90
                sweepAngle: 360
            }
        }

        // 2. Anillo de Progreso UNIDO y REDONDEADO
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.dialColor
            strokeWidth: 15
            strokeStyle: ShapePath.SolidLine // Línea continua
            capStyle: ShapePath.RoundCap // ESTO redondea las puntas del anillo

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.size / 2 - 20
                radiusY: root.size / 2 - 20
                startAngle: -90
                sweepAngle: 360 * root.value
            }
        }

        // 3. Brillo de contorno (Glow sutil)
        Shape {
            id: glowBase
            anchors.fill: parent
            opacity: 1
            ShapePath {
                fillColor: "transparent"
                strokeColor: "#000000"
                strokeWidth: 2

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.size / 2 - 5
                    radiusY: root.size / 2 - 5
                    startAngle: -90
                    sweepAngle: 360
                }
            }
        }
        DropShadow {
            id: ringGlow
            anchors.fill: glowBase
            source: glowBase
            color: Constants.primaryColor
            radius: 20
            samples: 25
            spread: 0.3
            transparentBorder: true
        }

        Shape {
            id: outerRing
            anchors.fill: parent
            opacity: 0.3
            ShapePath {
                id: outerStroke
                fillColor: "transparent"
                strokeColor: root.dialColor
                strokeWidth: 2

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.size / 2 - 5
                    radiusY: root.size / 2 - 5
                    startAngle: -90
                    sweepAngle: 360
                }
            }
        }
    }

    // Textos centrales (Situs / Reps)
    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            id: quantity
            text: "30x"
            color: "white"
            font.pixelSize: 45
            font.bold: true
            font.family: "Monospace"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        NeonText {
            id: dialMessage
            label: "WAIT"
            labelColor: root.messageColor
            font.pixelSize: 18
            font.letterSpacing: 4
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            cornerWidth: 1
        }
    }

    MouseArea {
        id: interactionArea
        anchors.fill: parent
        // Prevent clicking through the dial
        preventStealing: true
    }
}
