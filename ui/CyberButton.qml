import QtQuick
import QtQuick.Controls

Button {
    id: control
    text: "START"

    // Propiedades personalizadas para el color
    property color glowColor: "#00f3ff"

    contentItem: Text {
        text: control.text
        font.family: "Orbitron" // O tu fuente tecno
        font.pixelSize: 20
        font.bold: true
        color: control.pressed ? "#000" : glowColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Canvas {
        implicitWidth: 200
        implicitHeight: 60
        onPaint: {
            var ctx = getContext("2d");
            var w = width;
            var h = height;
            var cut = 15; // El tamaño del corte de esquina

            ctx.reset();
            ctx.beginPath();
            // Dibujamos la forma con esquinas cortadas
            ctx.moveTo(cut, 0);
            ctx.lineTo(w - cut, 0);
            ctx.lineTo(w, cut);
            ctx.lineTo(w, h - cut);
            ctx.lineTo(w - cut, h);
            ctx.lineTo(cut, h);
            ctx.lineTo(0, h - cut);
            ctx.lineTo(0, cut);
            ctx.closePath();

            // Fondo
            ctx.fillStyle = control.pressed ? glowColor : "transparent";
            ctx.fill();

            // Borde neón
            ctx.strokeStyle = glowColor;
            ctx.lineWidth = 2;
            ctx.stroke();
        }
    }
}
