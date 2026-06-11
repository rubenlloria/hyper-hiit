import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

ArchitectForm {
    // Ara sí, definim l'acció del clic
    header.settingsMouseArea.onClicked: {
        console.log("Back to core-config");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.pop();
    }
}
