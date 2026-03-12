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
    ListModel {
        id: directivesModel
    }

    // Connexió per obrir/tancar l'acordió
    neonAccordion.headerMouseArea.onClicked: {
        neonAccordion.isOpen = !neonAccordion.isOpen
    }

    Component.onCompleted: {
        // 1. Define the directives data using Constants for icons and colors [3, 4]
        const data = [
            { name: "FAT_BURNING", desc: "Metabolic acceleration protocols", glyph: Constants.flameIcon, accent: Constants.fuchsiaNeon },
            { name: "CARDIO_ENHANCEMENT", desc: "Cardiovascular optimization system", glyph: Constants.heartIcon, accent: Constants.cyanNeon },
            { name: "STRENGTH_MATRIX", desc: "Muscular fortification sequence", glyph: Constants.zapIcon, accent: Constants.radicalRed },
            { name: "ENDURANCE_GRID", desc: "Stamina amplification framework", glyph: Constants.targetIcon, accent: Constants.neonLime },
            { name: "NEURAL_FLOW", desc: "Neural-synaptic synchronization", glyph: Constants.brainIcon, accent: Constants.cyberYellow }
        ];

        // 2. Iterate through data to populate the model and create visual elements [2, 5]
        data.forEach(itemData => {
            console.log("Creating directive:", itemData.name, "| Icon:", itemData.glyph, "| Accent:", itemData.accent);
            directivesModel.append(itemData);

            // Create the NeonDirective component from the components folder [6]
            var component = Qt.createComponent("../components/NeonDirective.ui.qml");
            if (component.status === Component.Ready) {
                // Instantiate the object inside the accordion's dropdown list [5, 7]
                var item = component.createObject(neonAccordion.dropdownList, {
                    "directiveTitle": itemData.name,
                    "directiveDescription": itemData.desc,
                    "directiveGlyph": itemData.glyph,
                    "color": itemData.accent,
                    "width": neonAccordion.width
                });

                // SELECTION LOGIC: Use .connect() to avoid "read-only property clicked" error
                // This updates the main accordion state when an item is selected [8]
                item.itemMouseArea.clicked.connect(function() {
                    neonAccordion.activeDirectiveName = itemData.name;
                    neonAccordion.activeDirectiveDesc = itemData.desc;
                    neonAccordion.activeIconGlyph = itemData.glyph;
                    neonAccordion.activeThemeColor = itemData.accent;
                    neonAccordion.isOpen = false; // Close accordion after selection
                    console.log("Active directive updated to: " + itemData.name);
                });
            } else {
                console.error("Failed to load NeonDirective.ui.qml:", component.errorString());
            }
        });
    }
    header.settingsMouseArea.onClicked: {
        console.log("Navigating to System Config...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.push("Architect.qml");
    }

}
