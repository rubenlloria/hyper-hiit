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

    // property int activeSessionId: 0

    onActiveSessionIdChanged: {
        Constants.hDebug(debugName, "activeSessionId: " + activeSessionId)
        if (activeSessionId > 0) {
            Constants.hDebug(debugName, "activeSessionId > 0");
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
        mainStack.pop();
    }

    function refreshData(sessionId) {
        Constants.hDebug(debugName, "Getting session totals");

        totalsRepeater.model = dbManager.getSessionTotals(sessionId);
        analysisRepeater.model = dbManager.getSessionDetailedAnalysis(sessionId);
    }

    }
