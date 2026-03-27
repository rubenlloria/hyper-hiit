import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

ProtocolForm {
    // Ara sí, definim l'acció del clic
    header.settingsMouseArea.onClicked: {
        console.log("Navigating to System Config...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.push("Dashboard.qml");
    }
}