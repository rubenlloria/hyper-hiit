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

    Component.onCompleted: {
        let activeId = dbManager.getActiveDirectiveId();
        rankNames = dbManager.getRankLabels();
        Constants.hDebug(debugName, "rankNames: " + rankNames);
        updateCharts();
        Constants.hInfo(infoName, "Dashboard resumed with Directive ID " + activeId);
        Constants.hInfo(infoName, "Dashboard ready");
    }

    // Connection for per open/close accordion
    neonAccordion.headerMouseArea.onClicked: {
        neonAccordion.isOpen = !neonAccordion.isOpen
    }

    // This binding applies the color the exact microsecond the component is created
    Binding {
        target: dashboardView.neonAccordion
        property: "activeThemeColor"
        value: sessionManager.activeDirectiveInfo.color
    }

    /**
     * Directive Matrix Repeater.
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
                sessionManager.activeDirectiveInfo = {
                    "id": model.id,
                    "name": model.name,
                    "description": model.description,
                    "icon": model.icon,
                    "color": model.color
                };

                mainWindow.currentDirectiveColor = model.color;

                // 3. Collapse shard for optimal tactical overlay space [Source 6]
                neonAccordion.isOpen = false;

                Constants.hInfo(infoName, "Active Directive updated to " + model.name);
            }
        }
    }

    protocols.protocolView.model: protocolModel

    protocols.protocolView.delegate: NeonProtocol {
        // Data Mapping from C++ Roles
        protocolName: model.name
        estimatedDuration: Constants.formatTime(model.duration)
        moduleCount: model.moduleCount
        rankLabel: rankNames[model.rank]
        personalBest: (model.personalBest === 0)
                      ? model.duration / protocolModel.maxDuration
                      : model.personalBest / protocolModel.maxDuration
        primaryColor: neonAccordion.activeThemeColor
        currentProgress: model.duration / protocolModel.maxDuration

        itemMouseArea.onClicked: {
            Constants.hInfo(infoName, "Initializing " + model.name);

            mainStack.push("Briefing.qml", {
                "activeProtocolId": model.id,
                "protocolName": model.name,
                "themeColor": neonAccordion.activeThemeColor,
                "rank": rankNames[model.rank],
                // "calories": model.calories,
                "moduleCount": model.moduleCount,
                "duration": Constants.formatTime(model.duration),
                "personalBest": model.personalBest,
                "record": Constants.formatTime(model.personalBest)
            });
        }

    }

    header.settingsMouseArea.onClicked: {
        Constants.hInfo(infoName, "Navigating to System Config...");
        systemManager.systemReady = false;
        Constants.runDeferred(() => {
                                  mainStack.push("Config.qml");
                              });
    }

    Connections {
        target: sessionManager

        // This handler triggers when the C++ signal is emitted
        function onSessionSaved() {
            let activeId = dbManager.getActiveDirectiveId();
            Constants.hDebug(debugName, "Session synchronization detected. Refreshing charts and Directive: " + activeId + ".");
            updateCharts();
            protocolModel.filterByDirective(activeId);
        }
    }

    // Triggered when the view becomes active in the StackView
    StackView.onStatusChanged: {
        if (StackView.status === StackView.Active) {
            Constants.hDebug(debugName, "\n############# Stack status changed #############\n");
            // Execute the SQL checks encapsulated in C++ lambdas
            achievementManager.runTacticalCheck();
        }
    }

    exitButton.interactionArea.onClicked: {
        confirmPopup.target = "SYSTEM // SAYONARA";
        confirmPopup.message = "DO YOU WANT TO PROCEED TO EXIT hypper//hiit?"
        // confirmPopup.message = "ARE YOU SURE YOU WANT TO EXIT hypper//hiit?"
        confirmPopup.onAccept = function() {
            Constants.hInfo(infoName, "#### SAYONARA BABY ####");
            mainWindow.safeExit();
            // Qt.quit();
        };

        confirmPopup.onCancel = function() {
            Constants.hInfo(infoName, "Purge cancelled");
        };

        confirmPopup.open();
    }

    function updateCharts() {
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
