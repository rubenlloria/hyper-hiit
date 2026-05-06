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

    property string debugName: "Dashboard.qml"
    property string infoName: "Dashboard.qml"
    property var rankNames: ({})

    // Definim el model buit per evitar l'error de ListElement
    // ListModel {
    //     id: directivesModel
    // }

    Component.onCompleted: {
    var activeId = dbManager.getActiveDirectiveId() -1;
    neonAccordion.activeDirectiveName = directiveModel.data(directiveModel.index(activeId, 0), 258);
    neonAccordion.activeDirectiveDesc = directiveModel.data(directiveModel.index(activeId, 0), 259);
    neonAccordion.activeIconGlyph = directiveModel.data(directiveModel.index(activeId, 0), 260);
    neonAccordion.activeThemeColor = directiveModel.data(directiveModel.index(activeId, 0), 261);
    rankNames = dbManager.getRankLabels();
    Constants.hDebug(debugName, "rankNames: " + rankNames);
    updateCharts();
    Constants.hInfo(infoName, "Dashboard resumed with Directive ID " + activeId);
    }

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
                dbManager.setActiveDirectiveId(model.id);

                // 2. Update HUD visual state with selected directive metadata
                neonAccordion.activeDirectiveName = model.name;
                neonAccordion.activeDirectiveDesc = model.description;
                neonAccordion.activeIconGlyph = model.icon;
                neonAccordion.activeThemeColor = model.color;

                // 3. Collapse shard for optimal tactical overlay space [Source 6]
                neonAccordion.isOpen = false;

                Constants.hInfo(infoName, "Active Directive updated to " + model.name);
            }
        }
    }

    /**
     * [NEURAL_SYNC] Protocol Matrix Repeater.
     * Automatically instantiates NeonDirective components based on the C++ directiveModel.
     */

    function formatTime(totalSeconds) {
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;

        // Returns formatted string with zero-padding (e.g., "05:08")
        return minutes.toString().padStart(2, '0') + ":" +
               seconds.toString().padStart(2, '0');
    }

    protocols.protocolView.model: protocolModel

    protocols.protocolView.delegate: NeonProtocol {
        // Data Mapping from C++ Roles
        protocolName: model.name
        estimatedDuration: formatTime(model.duration)
        moduleCount: model.moduleCount
        rankLabel: rankNames[model.rank]
        personalBest: (model.personalBest === 0)
                      ? model.duration / protocolModel.maxDuration
                      : model.personalBest / protocolModel.maxDuration
        primaryColor: neonAccordion.activeThemeColor
        currentProgress: model.duration / protocolModel.maxDuration


        // Aesthetic Persistence: RANK color logic [Source 29]
        // rankColor: (model.rank === "ROOT") ? Constants.terminalGreen :
        //            (model.rank === "ADVANCED") ? Constants.cyanNeon : "#ffffff"

        itemMouseArea.onClicked: {
            Constants.hInfo(infoName, "Initializing " + model.name);

            mainStack.push("Briefing.qml", {
                "activeProtocolId": model.id,
                "protocolName": model.name,
                "themeColor": neonAccordion.activeThemeColor,
                "rank": rankNames[model.rank],
                // "calories": model.calories,
                "moduleCount": model.moduleCount,
                "duration": formatTime(model.duration),
                "personalBest": model.personalBest
            });
        }

    }

    header.settingsMouseArea.onClicked: {
        Constants.hInfo(infoName, "Navigating to System Config...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.push("Architect.qml");
    }

    Connections {
        target: sessionManager

        // This handler triggers when the C++ signal is emitted
        function onSessionSaved() {
            Constants.hDebug("Dashboard", "Session synchronization detected. Refreshing charts.");
            updateCharts();
        }
    }

    function updateCharts() {
        // 1. Retrieve raw historical telemetry (Level 4)
        let rawHistory = dbManager.getWeeklyCalorieHistory();
        // if (rawHistory.length === 0) return;

        // const maxGraphHeight = 80; // Buffer height in pixels
        let maxGraphHeight = evolutionChart.evolutionShape.height;
        Constants.hDebug(debugName, "maxGraphHeight: " + maxGraphHeight);
        let processedData = [];
        let peakKcal = 0;

        // First pass: Convert to kcal integers and identify the maximum value (kcalTarget)
        for (let i = 0; i < rawHistory.length; i++) {
            let kcalValue = rawHistory[i].calories;
            if (kcalValue > peakKcal) peakKcal = kcalValue;

            // Temporarily store the integer value to avoid double conversion
            processedData.push({
                "day": rawHistory[i].day,
                "calories": kcalValue
            });
        }

        // Safety check: Avoid division by zero if no calories were burned
        // 2. Calculate the Rounded Target (Safety Margin)
        // We choose a step based on the magnitude of the peak
        let step = 100;
        if (peakKcal < 500) step = 50;  // For smaller values, round to nearest 50
        if (peakKcal < 100) step = 20;  // For very low activity, round to nearest 20
        let kcalTarget = (peakKcal > 0) ? (Math.floor(peakKcal / step) + 1) * step  : 1000;

        // Second pass: Calculate scaled height based on the dynamic kcalTarget
        for (let j = 0; j < processedData.length; j++) {
            let entry = processedData[j];

            // Height = (Current kcal / Max kcal) * maxPixels
            let scaledHeight = Math.floor((entry.calories * maxGraphHeight) / kcalTarget);

            // Update the object with the final UI metrics
            processedData[j] = {
                "day": entry.day,
                "kcal": entry.calories,
                "barHeight": Math.min(scaledHeight, maxGraphHeight)
            };
            Constants.hDebug(debugName, "day: " + entry.day + " | dataPoint:" + scaledHeight);
        }

        // 2. Synchronize with the UI component
        evolutionChart.telemetry = processedData;
        evolutionChart.topLabel = kcalTarget;
        evolutionChart.middleLabel= kcalTarget / 2;

        Constants.hDebug(debugName, "Charts updated. Dynamic kcalTarget set to: " + kcalTarget);

        /////// GET IMPROVEMENT ///////
        let delta = dbManager.getImprovementPercentage();
        // Formatting the Tactical Overlay
        evolutionChart.improvement = (delta > 0 ? "+" : "") + delta;
    }
}
