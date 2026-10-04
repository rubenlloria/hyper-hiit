/****************************************************************************
** File: Briefing.qml
** Date: 13/4/2026
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
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

BriefingForm {
    id: briefingView

    property int activeProtocolId: 0
    property var structuredData: structuredData
    property string record: "--:--"
    // property int estimatedKcal: 0

    onActiveProtocolIdChanged: {
        if (activeProtocolId > 0) {
            // We call the C++ DatabaseManager to get the nested array
            // This is assigned to the model of your outer Repeater
            let data = dbManager.getProtocolStructure(activeProtocolId);
            protocolDataModel = data;
            subsystemRepeater.model = protocolDataModel;
        }
    }

    // Link the back button to the main stack
    header.settingsMouseArea.onClicked: {
        console.log("Back to dashboard...");
        systemManager.systemReady = false;
        Constants.runDeferred(
                    () => {
                        mainStack.pop();
                    });
    }

    executeButton.interactionArea.onClicked: {
        console.log("Executing protocol");
        mainStack.push("Protocol.qml", {
            "activeProtocolId": activeProtocolId,
            "protocolName": protocolName,
            "themeColor": themeColor,
            "rank": rank,
            "moduleCount": moduleCount,
            "duration": duration,
            "personalBest": personalBest,
            "record": record,
            "protocolDataModel": protocolDataModel
        });
    }
}
