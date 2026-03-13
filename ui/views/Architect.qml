import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

ArchitectForm {
    // Ara sí, definim l'acció del clic
    header.settingsMouseArea.onClicked: {
        console.log("Navigating to System Config...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.push("Dashboard.qml");
    }
    restoreDBButton.interactionArea.onClicked: {
        console.log("Restoring database...");
    }
}
