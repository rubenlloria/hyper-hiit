import QtQuick
import QtQuick.Controls
import "../components"
import ".."

/**
 * Summary.qml
 */

SummaryForm{
    id: summaryView

    property string debugName: "Dashboard.qml"
    property string infoName: "Dashboard.qml"

    property var rankNames: ({})
    // property int activeSessionId: 0

    Component.onCompleted: {
    }

    onActiveSessionIdChanged: {
        Constants.hDebug(debugName, "activeSessionId: " + activeSessionId)
        if (activeSessionId > 0) {
            Constants.hDebug(debugName, "activeSessionId > 0");
            rankNames = dbManager.getRankLabels();
            Constants.hDebug(debugName, "rankNames: " + rankNames);
            refreshData(activeSessionId);
            // We call the C++ DatabaseManager to get the nested array
            // This is assigned to the model of your outer Repeater
            // let data = dbManager.getProtocolStructure(activeProtocolId);
            // protocolDataModel = data;
            // subsystemRepeater.model = protocolDataModel;
        }
    }

    // Link the back button to the main stack
    header.settingsMouseArea.onClicked: {
        console.log("Back to dashboard...");
        mainStack.pop(null);
    }

    function loadHeaderMetrics(historyId) {
        let data = dbManager.getSessionSummaryMetrics(historyId);

        // Assigning to UI components (ex: NeonMetricCard)
        protocolName = data.protocolName;
        sessionDate = data.sessionDate;
        rank = rankNames[data.rank];
        moduleCount = data.moduleCount;
        duration = data.duration;
        calories = data.calories;
        improvement = data.improvement;
        efficiency = data.efficiency;
        hasGhost = data.hasGhost;
        timeDiff = data.timeDiff;
        timeDiffString = (timeDiff > 0 ? "+" : "" )+ data.timeDiffString;
    }

    function refreshData(sessionId) {
        Constants.hDebug(debugName, "Getting session totals");

        totalsRepeater.model = dbManager.getSessionTotals(sessionId);
        analysisRepeater.model = dbManager.getSessionDetailedAnalysis(sessionId);
        loadHeaderMetrics(sessionId);
    }
}
