import QtQuick
import QtQuick.Controls
import "../components"
import ".."

/**
 * Summary.qml
 */

SummaryForm{
    id: summaryView

    // property int activeProtocolId: 0

    onActiveProtocolIdChanged: {
        if (activeProtocolId > 0) {
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
}
