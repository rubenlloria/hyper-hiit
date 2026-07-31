import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

ConfigForm {
    id: configForm

    readonly property string debugName: "Config.qml"
    readonly property string infoName: "Config.qml"

    property bool _isReady: systemManager.systemReady

    // Colors
    readonly property color colorSaved: Constants.primaryTextColor
    readonly property color colorDirty: Constants.secondaryTextColor
    property var pendingData: ({})
    property var pulsingComponents: []   // Components currently in success animation

    // USER_NAME TextField
    userNameField.onTextChanged: {
        queueSave("userName", configForm.userNameField.text, configForm.userNameField)
    }

    // BIOMASS_KG SpinBox
    weightField.onValueChanged: {
        queueSave("userWeight", configForm.weightField.value, configForm.weightField)
    }

    // HEIGHT_CM SpinBox
    heightField.onValueChanged: {
        queueSave("userHeight", configForm.heightField.value, configForm.heightField);
    }

    // AGE SpinBox
    ageField.onValueChanged: {
        queueSave("userAge", configForm.ageField.value, configForm.ageField);
    }

    // SEX Selector
    sexSelector.onSelectedIndexChanged: {
        queueSave("userSex", sexSelector.selectedIndex, configForm.sexSelector)
    }

    // RANK_LEVEL Selector
    rankSelector.onSelectedIndexChanged: {
        queueSave("userRank", configForm.rankSelector.selectedIndex, configForm.rankSelector);
    }

    // SYSTEM_THEME Selector
    themeSelector.onSelectedIndexChanged: {
        queueSave("systemTheme", configForm.themeSelector.selectedIndex, configForm.themeSelector);
    }

    // SCANLINE_RENDER Switch
    scanlineSwitch.onCheckedChanged: {
        queueSave("systemScanline", configForm.scanlineSwitch.checked, configForm.scanlineSwitch);
    }

    // AUDIO_UPLINK Switch
    audioSwitch.onCheckedChanged: {
        queueSave("systemAudio", configForm.audioSwitch.checked, configForm.audioSwitch);
    }

    // SHUTDOWN_CONFIRM Switch
    exitConfirmSwitch.onCheckedChanged: {
        queueSave("systemExitConfirm", configForm.exitConfirmSwitch.checked, configForm.exitConfirmSwitch);
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

    Component.onCompleted: {
        Constants.hInfo(infoName, "Config form ready");
    }

    architectMouseArea.onClicked: {
        systemManager.systemReady = false;
        Constants.hWarning(infoName, "Accessing ARCHITECT...");
        Constants.runDeferred(
                    () => {
                        mainStack.push("Architect.qml");
                    });
    }

    restoreDBButton.interactionArea.onClicked: {
        confirmPopup.target = "SYSTEM // DATABASE";
        confirmPopup.message = "ARE YOU SURE YOU WANT TO DELETE " +
                "[SYSTEM DATABASE]" +
                "? THIS ACTION WILL PERMANENTLY ERASE DATA FROM THE REGISTRY."
        confirmPopup.onAccept = function() {
            Constants.hWarning(infoName, "Restoring database...");
            dbManager.restoreDatabase();
        };

        confirmPopup.onCancel = function() {
            Constants.hInfo(infoName, "Purge cancelled");
        };

        confirmPopup.open();
    }

    // Timer {
    //     id: nameDebouncer
    //     interval: 2000 // Between 1500-2500ms
    //     repeat: false
    //     onTriggered: commitData("userName", configForm.userNameField.text, configForm.userNameField)
    // }

    // // Debouncing Timer for Biomass (Critical for MET_FACTOR)
    // Timer {
    //     id: biomassDebouncer
    //     interval: 2000
    //     repeat: false
    //     onTriggered: commitData("biomass", configForm.weightField.value, configForm.weightField)
    // }

    Timer {
        id: globalDebouncer
        interval: 2000
        repeat: false
        onTriggered: {
            // Process the specific field that triggered the timer
            for (var key in pendingData) {
                var item = pendingData[key];
                // commitData(key, item.value, item.component);

                // if (Data.key) {
                //     commitData(pendingData.key, pendingData.value, pendingData.component);
                // }
                Constants.hDebug(debugName, "Processing: " + key)
                if (item) {
                    Constants.hDebug(debugName, "value: " + item.value + " | component: " + item.component)
                    commitData(key, item.value, item.component);
                }
            }
            // Clear pending context
            pendingData = {};
        }
    }

    // Logic function to queue the asynchronous save
    function queueSave(key, value, component) {
        if (!_isReady)  return

        // Update visual state to Magenta (Unsaved)
        component.neonColor = configForm.colorDirty;

        var newQueue = pendingData

        // Update the pending context
        newQueue[key] = {
            "value": value,
            "component": component
        };

        pendingData = newQueue;

        // Restart the countdown
        globalDebouncer.restart();
    }

    function commitData(key, value, component) {
        Constants.hDebug(debugName, "Asynchronous commit to DB: " + key + " -> " + value);

        if (key.startsWith("user")) {
            sessionManager.setConfig(key, value);
        }
        else if (key.startsWith("system")) {
            systemManager.setConfig(key, value);
        } else {
            Constants.hWarning(debugName, "Key not recognized: " + key + ", with value: " + value);
        }

        // Simulate backend success
        component.neonColor = colorSaved;

        // Trigger visual confirmation pulse
        if (component.hasOwnProperty("showSuccessPulse")) {
            component.showSuccessPulse = true;

            // Transfer to pulsing list to avoid interference with pendingData
            var pulses = pulsingComponents;
            pulses.push(component);
            pulsingComponents = pulses;

            pulseResetTimer.restart();
        }
    }

    Timer {
        id: pulseResetTimer
        property var targetComponent: null
        interval: 600
        onTriggered: {
            for (var i = 0; i < pulsingComponents.length; i++) {
                if (pulsingComponents[i]) pulsingComponents[i].showSuccessPulse = false;
            }
            pulsingComponents = []; // Clear visual queue
        }
    }
}
