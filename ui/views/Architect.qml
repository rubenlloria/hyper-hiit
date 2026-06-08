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
        dbManager.restoreDatabase();
    }

    configButton.interactionArea.onClicked: {
        console.log("Restoring database...");
        mainStack.push("ConfigForm.ui.qml");
    }
    summaryButton.interactionArea.onClicked: { // WARNING: Use for test only
        console.log("Navigate to Summary...");
        mainStack.push("Summary.qml",{
                           "activeSessionId": 9,
                           "lastAchievements": [
                               {"unlocked": false}, // NEURAL_SYNC
                               {"unlocked": false}, // FIRE_STARTER
                               {"unlocked": false}, // IRON_CORE
                               {"unlocked": false}, // SPEED_DEMON
                               {"unlocked": false}, // ENDURANCE_UNIT
                               {"unlocked": false}, // ULTRA_ROOT
                               {"unlocked": false}, // OVERCLOCKED
                               {"unlocked": false}, // SYSTEM_INITIATE
                               {"unlocked": false}, // GHOST_BUSTER
                               {"unlocked": false}  // CENTURION_LOG
                           ]
                       });
    }
}
