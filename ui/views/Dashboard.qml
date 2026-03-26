import QtQuick
import QtQuick.Controls
import "../components"
import ".."

/**
 * Dashboard.qml
 * Functional companion to Dashboard.ui.qml.
 * Handles data models, database simulation, and interaction logic.
 */

DashboardForm {
    id: dashboardView

    // Definim el model buit per evitar l'error de ListElement
    // ListModel {
    //     id: directivesModel
    // }

    // Connexió per obrir/tancar l'acordió
    neonAccordion.headerMouseArea.onClicked: {
        neonAccordion.isOpen = !neonAccordion.isOpen
    }

    /**
     * [NEURAL_SYNC] Directive Matrix Repeater.
     * Automatically instantiates NeonDirective components based on the C++ directiveModel.
     */
    Repeater {
        // Target the specific container inside the NeonAccordion component [Source 89]
        model: directiveModel
        parent: neonAccordion.dropdownList

        delegate: NeonDirective {
            // Automatic Role Mapping: 'name', 'description', 'icon', and 'color'
            // are defined in the C++ DirectiveModel::roleNames() [Source 34]
            directiveTitle: model.name
            directiveDescription: model.description
            directiveGlyph: model.icon
            color: model.color
            width: neonAccordion.width

            // Selection Logic: High-speed Protocol Matrix filtering [Source 11, 16]
            itemMouseArea.onClicked: {
                // 1. Trigger high-speed filter on the Protocol Shard
                protocolModel.filterByDirective(model.id);

                // 2. Update HUD visual state with selected directive metadata
                neonAccordion.activeDirectiveName = model.name;
                neonAccordion.activeDirectiveDesc = model.description;
                neonAccordion.activeIconGlyph = model.icon;
                neonAccordion.activeThemeColor = model.color;

                // 3. Collapse shard for optimal tactical overlay space [Source 6]
                neonAccordion.isOpen = false;

                console.log("NEURAL_SYNC: Active Directive updated to " + model.name);
            }
        }
    }

    /**
     * [NEURAL_SYNC] Protocol Matrix Repeater.
     * Automatically instantiates NeonDirective components based on the C++ directiveModel.
     */

    protocols.protocolView.model: protocolModel

    protocols.protocolView.delegate: NeonProtocol {
        // Data Mapping from C++ Roles [Source 15, 34]
        protocolName: model.name
        estimatedDuration: model.duration
        moduleCount: model.moduleCount
        rankLevel: model.rank
        personalBest: model.personalBest
        primaryColor: neonAccordion.activeThemeColor

        // Aesthetic Persistence: RANK color logic [Source 29]
        // rankColor: (model.rank === "ROOT") ? Constants.terminalGreen :
        //            (model.rank === "ADVANCED") ? Constants.cyanNeon : "#ffffff"

        // itemMouseArea.onClicked: {
        //     console.log("NEURAL_SYNC: Initializing " + model.name);
        // }
    }

    header.settingsMouseArea.onClicked: {
        console.log("Navigating to System Config...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.push("Architect.qml");
    }

}
