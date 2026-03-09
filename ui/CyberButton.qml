import QtQuick
import QtQuick.Controls

Button {
    id: control
    text: "START"

    property color glowColor: "#00f3ff"
    property color pressedColor: "#f300f3"

    contentItem: Text {
        text: control.text
        font.family: "Orbitron"
        font.pixelSize: 20
        font.bold: true
        color: control.pressed ? pressedColor : glowColor
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
            var cut = 15; // Corner cut size

            ctx.reset();
            ctx.beginPath();
            // Paint corner cut shapes
            ctx.moveTo(cut, 0);
            ctx.lineTo(w - cut, 0);
            ctx.lineTo(w, cut);
            ctx.lineTo(w, h - cut);
            ctx.lineTo(w - cut, h);
            ctx.lineTo(cut, h);
            ctx.lineTo(0, h - cut);
            ctx.lineTo(0, cut);
            ctx.closePath();

            // Background
            ctx.fillStyle = control.pressed ? glowColor : "transparent";
            ctx.fill();

            // Neon border
            ctx.strokeStyle = glowColor;
            ctx.lineWidth = 2;
            ctx.stroke();
        }
    }
}
