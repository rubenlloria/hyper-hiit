import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.aic.hyperhiit 1.0
import ".."

Item {
    id: dashboardRoot
    anchors.fill: parent

    // --- Header: Operator Info ---
    Column {
        id: headerInfo
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
        spacing: 5

        Text {
            text: "OPERATOR_ID: USER_01"
            color: "#00FFFF"
            font.family: "Orbitron"
            font.pixelSize: 18
        }

        // Barra de evolución (XP Bar)
        Rectangle {
            width: parent.width * 0.6
            height: 4
            color: "#1A1A1A"
            Rectangle {
                width: parent.width * 0.7 // Ejemplo de progreso
                height: parent.height
                color: "#00FF00"
            }
        }
    }

    // --- Center: Active Directive ---
    Rectangle {
        id: directivePanel
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: 200
        color: "#0A0A0A"
        border.color: "#00FFFF"
        border.width: 2
        radius: 10

        Column {
            anchors.centerIn: parent
            spacing: 15

            Text {
                text: "CURRENT DIRECTIVE"
                color: "#444444"
                font.family: "Orbitron"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "RE-COMP"
                color: "white"
                font.family: "Orbitron"
                font.pixelSize: 32
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // --- Bottom: Navigation ---
    CyberButton {
        id: protocolButton
        text: "ACCESS PROTOCOLS"
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 100
        }
        onClicked: stack.push("ProtocolNexus.qml")
    }

    // Mini Botón de Settings
    // Image {
    //     source: "qrc:/ui/assets/icons/settings.svg"
    //     anchors { bottom: parent.bottom; right: parent.right; margins: 20 }
    //     width: 30; height: 30
    //     opacity: 0.6

    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: stack.push("SettingsView.qml")
    //     }
    // }
}
