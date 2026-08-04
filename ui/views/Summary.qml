
/****************************************************************************
** File: Summary.qml
** Date: 12/5/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
import QtQuick
import QtQuick.Controls
import "../components"
import ".."

/**
 * Summary.qml
 */

SummaryForm{
    id: summaryView

    property string debugName: "Summary.qml"
    property string infoName: "Summary.qml"

    property var rankNames: ({})
    property var lastAchievements: []
    property var sessionNewAchievements: []

    // property int activeSessionId: 0

    Component.onCompleted: {
        Constants.hDebug(debugName, "last Achievements test name " + lastAchievements[0].name);
        Constants.hDebug(debugName, "last Achievements test unlocked" + lastAchievements[0].unlocked);

        // TACTICAL DELTA: Filter badges that are now unlocked but weren't before
        achievementManager.runTacticalCheck();
        let currentAchievements = achievementManager.achievements;
        let earnedThisSession = [];
        for (let i = 0; i < currentAchievements.length; i++) {
            let currentBadge = currentAchievements[i];
            let lastBadge = lastAchievements[i];

            // If the badge is unlocked now
            if (currentBadge.unlocked) {
                // Check if it was previously locked in lastAchievements
                let wasAlreadyUnlocked = lastBadge.unlocked;
                Constants.hDebug(debugName, "Checking: " + currentBadge.name + "(" + lastBadge.name + ") => " + wasAlreadyUnlocked);

                if (!wasAlreadyUnlocked) {
                    earnedThisSession.push(currentBadge);
                    currentBadge.resetStatus();
                }
            }
        }

        sessionNewAchievements = earnedThisSession;
        Constants.hDebug(debugName, "New achievements detected: " + sessionNewAchievements.length);

        // Ensure display remains active during active mission telemetry
        systemManager.keepScreenOn(true);
    }

    Component.onDestruction: {
        // Revert to system default power management on exit
        systemManager.keepScreenOn(false);
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
        systemManager.systemReady = false;
        Constants.runDeferred(
                    () => {
                        mainStack.pop(null);
                    });
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
