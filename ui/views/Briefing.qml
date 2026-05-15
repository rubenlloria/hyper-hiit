/****************************************************************************
** File: Briefing.qml
** Date: 13/4/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License version 2 as
** published by the Free Software Foundation.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

BriefingForm {
    id: briefingView

    property int activeProtocolId: 0
    property var structuredData: structuredData

    onActiveProtocolIdChanged: {
        if (activeProtocolId > 0) {
            // We call the C++ DatabaseManager to get the nested array
            // This is assigned to the model of your outer Repeater
            let data = dbManager.getProtocolStructure(activeProtocolId);
            protocolDataModel = data;
            subsystemRepeater.model = protocolDataModel;
            structuredData = dbManager.getProtocolExecutionDetails(activeProtocolId);
            // Constants.hDebug("Briefing", structuredData[0].data);
        }
    }

    // Link the back button to the main stack
    header.settingsMouseArea.onClicked: {
        console.log("Back to dashboard...");
        mainStack.pop();
    }

    executeButton.interactionArea.onClicked: {
        console.log("Executing protocol");
        mainStack.push("Protocol.qml", {
            "activeProtocolId": activeProtocolId,
            "protocolName": protocolName,
            "themeColor": themeColor,
            "rank": rank,
            // TODO: "calories": model.calories,
            "moduleCount": moduleCount,
            "duration": duration,
            "personalBest": personalBest,
            "protocolDataModel": protocolDataModel,
            "structuredData": structuredData
        });
    }

    function calculateCalorieEstimation() {
        // kcal = MET × pes_kg × (duration_h) × fatigue_factor × demofactor
        let totalKcal = 0.0;
    //     if (!structuredData || structuredData.length === 0) return 0.0;

    //     // Iterate through subsystems [1]
    //     for (let i = 0; i < structuredData.length; i++) {
    //         let moduleList = structuredData[i].modules; // Array of module objects [1]

    //         for (let j = 0; j < moduleList.length; j++) {
    //             let mod = moduleList[j];
    //             let durationMins = 0.0;

    //             // Determine duration in minutes based on unit type [4, 5]
    //             // unit_type: 0 = seconds, 1 = reps, 2 = breaths
    //             if (mod.unit_type === 0) {
    //                 durationMins = mod.quantity / 60.0;
    //             } else {
    //                 // Convert repetitions to estimated time using rep_time [6]
    //                 durationMins = (mod.quantity * mod.rep_time) / 60.0;
    //             }

    //             // Apply standard metabolic formula [2, 7]
    //             // Formula: (MET * 3.5 * weight / 200.0) * minutes
    //             totalKcal += (mod.met_factor * 3.5 * userWeight / 200.0) * durationMins;
    //         }
    //     }
        return totalKcal;
    }

}
