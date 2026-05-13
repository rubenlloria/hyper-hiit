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
        mainWindow.currentDirectiveColor = neonAccordion.activeThemeColor;
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
                mainWindow.currentDirectiveColor = model.color;

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

    function updateCharts() { // TODO: Get last week too
        // const maxGraphHeight = 80; // Buffer height in pixels
        let maxGraphHeight = evolutionChart.evolutionShape.height;
        Constants.hDebug(debugName, "maxGraphHeight: " + maxGraphHeight);

        // Retrieve raw historical telemetry (Level 4)
        let currentRaw = dbManager.getWeeklyCalorieHistory(0, 7);
        let ghostRaw = dbManager.getWeeklyCalorieHistory(7, 7);
        // if (rawHistory.length === 0) return;

        // 2. Determine global peak across both weeks for consistent scaling
        let globalPeak = 0;
        const findPeak = (data) => {
            for (let i = 0; i < data.length; i++) {
                if (data[i].calories > globalPeak) globalPeak = data[i].calories;
            }
        };
        findPeak(currentRaw);
        findPeak(ghostRaw);

        // 3. Calculate common scale (kcalTarget)
        let step = globalPeak < 500 ? (globalPeak < 100 ? 20 : 50) : 100;
        let kcalTarget = (globalPeak > 0) ? (Math.floor(globalPeak / step) + 1) * step : 1000;

        // 4. Process and assign to UI components
        evolutionChart.telemetry = processTelemetry(currentRaw, kcalTarget, maxGraphHeight);
        evolutionChart.lastTelemetry = processTelemetry(ghostRaw, kcalTarget, maxGraphHeight);

        // 2. Synchronize with the UI component
        // evolutionChart.telemetry = processedData;
        evolutionChart.topLabel = kcalTarget;
        evolutionChart.centerLabel= kcalTarget / 2;

        Constants.hDebug(debugName, "Charts updated. Dynamic kcalTarget set to: " + kcalTarget);

        /////// GET IMPROVEMENT ///////
        let q_improvement = dbManager.getImprovementPercentage();
        // Formatting the Tactical Overlay
        evolutionChart.improvement = (q_improvement > 0 ? "+" : "") + q_improvement;

        /////// GET EFFICIENCY ///////
        let q_efficiency = dbManager.getEfficiency();
        evolutionChart.efficiency = (q_efficiency > 0 ? "+" : "") + q_efficiency;

        /////// GET AVG_SESSIONS ///////
        let q_avg_sessions = dbManager.getAverageDailySessions(0, 7);
        evolutionChart.avgSessions = q_avg_sessions.toFixed(2);
        let q_ghost_sessions = dbManager.getAverageDailySessions(7, 7);
        evolutionChart.ghostSessions = q_ghost_sessions.toFixed(2);

        /////// GET AVG_KCAL ///////
        let q_avg_kcal = dbManager.getAverageDailyCalories(0, 7);
        evolutionChart.avgCalories = q_avg_kcal;
        let q_ghost_kcal = dbManager.getAverageDailyCalories(7, 7);
        evolutionChart.ghostCalories = q_ghost_kcal;
    }

    function processTelemetry(rawHistory, kcalTarget, maxPixels) {
        let processed = [];
        for (let i = 0; i < rawHistory.length; i++) {
            let entry = rawHistory[i];
            let scaledHeight = Math.floor((entry.calories * maxPixels) / kcalTarget);

            processed.push({
                "day": entry.day,
                "kcal": entry.calories,
                "barHeight": Math.min(scaledHeight, maxPixels)
            });
        }
        return processed;
    }

}
