import QtQuick
import org.aic.hyperhiit 1.0

import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."
import "."

ProtocolForm {
    id: protocolController
    // Initial state: Preparation phase
    currentModuleName: "ENGAGING"
    countdownTimer: -5 // Starting from -5 as requested
    unitType: 0 // Display as REPS/Units for the countdown
    unit: systemManager.getUnitLabel(unitType)
    currentQuantity: countdownTimer + unit

    property var lastAchievements: []

    property string debugName: "Protocol.qml"
    property string infoName: "Protocol.qml"

    property int activeSessionId: 0
    property real startX: 0
    property real tapX: 0
    property real threshold: 50 // Minimum pixels to trigger a displacement
    property var executionList: []
    property var structuredData: structuredData
    property int currentIndex: 0
    property int activeSubsystemId: 0
    property bool isRunning: false
    property bool m_targetReached: false
    property bool enableSkipForward: true

    // Internal state for progress tracking
    property real currentModuleDuration: 10000
    property real elapsedMs: 0
    readonly property var unitSymbols: ["s", "x", "b"]
    property double sessionStoredCalories: 0.0
    property double userWeight: 80.0 // TODO: Default weight from system specifications
    property int userAge: 45 // TODO: Default weight from system specifications
    property bool userIsMale: true // TODO: Default weight from system specifications
    property var lastSessionCheckpoints: [] // Stores the QList<int> returned from C++

    onActiveProtocolIdChanged: {
        if (activeProtocolId > 0) {
            loadProtocolDetails();
            let next = executionList[0];
            let unitSymbol = systemManager.getUnitLabel(next.data.unit_type) || "";
            // Constants.hDebug(debugName, next.data.module_name + " Content: " + JSON.stringify(next));
            // Constants.hDebug(debugName, "Protocol Content: " + JSON.stringify(executionList));
            nextModuleText.label = next.data.quantity + unitSymbol + " " + next.data.module_name;
        }
    }

    Component.onCompleted: {
        // let next = executionList[0];
        // nextModuleText.label = next.mod.quantity + next.mod.unit + " " + next.mod.name ;
        userWeight = sessionManager.userWeight;

        lastSessionCheckpoints = sessionManager.loadLastSessionData(protocolController.activeProtocolId);
        if (lastSessionCheckpoints.length > 0) {
            Constants.hDebug(debugName, "Historical telemetry loaded: " + lastSessionCheckpoints.length + " points.");
        }
        // Ensure display remains active during active mission telemetry
        systemManager.keepScreenOn(true);
    }

    Component.onDestruction: {
        // Revert to system default power management on exit
        systemManager.keepScreenOn(false);
    }

    Chronometer {
        id: globalChronometer

        onTimeTextChanged:{
            mainTimer.cents= globalChronometer.timeText.substring(6, 8);
            let minsec = globalChronometer.timeText.substring(0, 5);
            if (mainTimer.minSec !== minsec) {
                mainTimer.minSec = minsec;

                // Get MET Data
                let moduleData = executionList[currentIndex].data;
                let met = moduleData.met_factor;

                // Calculate elapsed time in hours for the current module
                // Formula: hours = milliseconds / (1000 * 3600)
                let elapsedHours = unitChronometer.elapsedMs / 3600000.0;

                // Dynamic calorie calculation
                // Formula: MET * kg * hours * demographic corrector
                let ageFactor = Math.min(Math.max((30 - userAge) * 0.003, -0.15), 0.10);
                let sexFactor = userIsMale ? 0.05 : -0.05;
                let corrector = 1.0 + ageFactor + sexFactor;
                let sessionKcal = sessionStoredCalories > 0 ? sessionStoredCalories / 1000 : 0;
                let liveModuleKcal = met * userWeight * elapsedHours * corrector;
                // Constants.hDebug(debugName, "met: " + met + " | weight: " + userWeight + " | hours: " + elapsedHours)

                // Update the UI property kcal (Stored from previous + Active module)
                protocolController.calories = Math.round(sessionKcal + liveModuleKcal);
                // Constants.hDebug(debugName, "Session cal: " + sessionKcal + " | Module cal: " + liveModuleKcal);

            }
        }
    }

    /**
     * Dedicated C++ instance for the Dial/Unit progress.
     * This ensures the progress remains accurate even if the app is minimized.
     */
    Chronometer {
        id: unitChronometer

        onTargetReached: {
            m_targetReached = true;
            Constants.hInfo(infoName, "maximum time reached!");
            if ( unitType === 0 ) {
                Constants.hDebug(debugName, "module time reached, switching next module...")
                nextModule();
            }
            else {
                progressDial.dialBgColor = Constants.secondaryColor;
                progressDial.dialColor = Constants.primaryColor;
            }
        }

        onTimeTextChanged: {
            // Calculate progress based on the actual elapsed MS from C++
            // Using the currentModuleDuration calculated in loadUnit()
            if (protocolController.isRunning && protocolController.currentModuleDuration > 0) {
                // Get raw elapsed time from the chronometer logic
                let elapsedMs = unitChronometer.elapsedMs;
                if (m_targetReached) {
                    progressDial.value = Math.min((elapsedMs - currentModuleDuration) / currentModuleDuration, 1.0);
                } else {
                    progressDial.value = Math.min(elapsedMs / currentModuleDuration, 1.0);
                }

                // Constants.hDebug(debugName, "dial updated | elapsedMS: " + elapsedMs + " | moduleDuration: " + protocolController.currentModuleDuration);
                if ( unitType === 0 ) {
                    // Constants.hDebug(debugName, "unitType: " + unitType + ": countdown");
                    let remainingMs = Math.max(0, currentModuleDuration - elapsedMs);
                    currentQuantity = Math.ceil(remainingMs / 1000) + "s";
                }
            }
        }
    }

    // Back button action
    header.settingsMouseArea.onClicked: {
        Constants.hInfo(infoName, debugName, "Back to Briefing...");
        systemManager.systemReady = false;
        if ( header.buttonLink === "back"){
            Constants.runDeferred(
                        () => {
                            mainStack.pop();
                        });
        } else{
            Constants.runDeferred(
                        () => {
                            mainStack.push("Summary.qml",{
                                           "activeSessionId": activeSessionId,
                                           "lastAchievements": lastAchievements
                                           });
                        });
        }
    }

    // Internal timer for the 5-second countdown
    Timer {
        id: preparationTimer
        interval: 1000 // 1 second
        repeat: true
        running: true // Starts immediately upon entering the view

        onTriggered: {
            if (protocolController.countdownTimer < 0) {
                // Countdown: -5, -4, -3, -2, -1
                protocolController.countdownTimer++;
                protocolController.currentQuantity = String(protocolController.countdownTimer) + protocolController.unit;

                let cdProgress = (5 + protocolController.countdownTimer) / 5;
                progressDial.value = Math.min(Math.max(cdProgress, 0.0), 1.0);
                // Constants.hDebug(debugName, "Countdown value: " + progressDial.value);

                if (protocolController.countdownTimer === 0) {
                    // Transition to ACTIVE mission state
                    preparationTimer.stop();
                    startProtocol();
                }
            }
        }
    }

    progressDial.dialMouseArea.onPressed: (mouse) => {
        startX = mouse.x;
    }

    progressDial.dialMouseArea.onReleased: (mouse) => {
        tapX = mouse.x
        let deltaX = tapX - startX;

        if (Math.abs(deltaX) > threshold) {
            if (deltaX > 0) {
                // [TACTICAL_ACTION] Displacement to the RIGHT
                handleRightSwipe();
            } else {
                // [TACTICAL_ACTION] Displacement to the LEFT
                handleLeftSwipe();
            }
        } else {
            // Simple touch without significant displacement
            handleDialTap();
        }
    }

    function handleRightSwipe() {
        // Logic to move backward on moldule list
        prevModule();
    }

    function handleLeftSwipe() {
        if ( unitType || enableSkipForward )
            nextModule();
        // Logic to move forward on moldule list
    }

    function handleDialTap() {
        // Logic to move forward or backward if tap on left side
        if ( tapX < 30 ) {
            prevModule();
        } else if ( unitType  || enableSkipForward ) {
            nextModule();
        }
        // Constants.hDebug(debugName, "Mouse tap at " + tapX);
        // Constants.hDebug(debugName, "Dial tapped. Validating current state.");
    }

    /**
     * Retrieves full Level 4 metadata from C++ and flattens the hierarchy.
     */
    function loadProtocolDetails() {
        let structuredData = dbManager.getProtocolExecutionDetails(activeProtocolId);
        // Constants.hDebug(debugName, "Full Model Content: " + JSON.stringify(structuredData));
        let tempSequence = [];
        let subsystems = 0;

        for (let i = 0; i < structuredData.length; i++) {
            subsystems = i + 1;
            let subsystem = structuredData[i];
            if (subsystem.modules) {
                for (let j = 0; j < subsystem.modules.length; j++) {
                    tempSequence.push({
                        "data": subsystem.modules[j],
                        "subId": subsystem.subsystem_id
                    });
                }
            }
        }

        executionList = tempSequence;
        Constants.hInfo(infoName, "Protocol sequence synchronized | Subsystems: " + subsystems + " | Total units: " + executionList.length);
    }

    /**
     * [EXECUTION_START] Engages the clock and loads the first module.
     */
    function startProtocol() {
        if (executionList.length === 0)
            return;

        isRunning = true;
        if (typeof globalChronometer !== "undefined") {
            sessionManager.startSession(activeProtocolId, executionList);
            globalChronometer.start(0);
        }
        progressDial.dialMessage = "NEXT";
        loadModule(0);
    }

    /**
     * [NEURAL_LINK] Updates the UI shard with the current module telemetry.
     */
    function loadModule(index) {
        Constants.hDebug(debugName, "executionList.length: " + executionList.length + " | index: " + index);
        if (index >= executionList.length) {
            finishProtocol();
            return;
        }

        currentIndex = index;
        let entry = executionList[currentIndex];
        let unitSymbol = systemManager.getUnitLabel(entry.data.unit_type) || "";
        // Constants.hDebug(debugName, entry.data.module_name + " Content: " + JSON.stringify(entry));

        let previousCheckpointSecs = (index > 0) ? sessionManager.getStoredTime(index - 1) : 0;
        Constants.hDebug(debugName, "previousCheckpointSecs: " + previousCheckpointSecs );
        let currentGlobalMs = globalChronometer.elapsedMs;
        let calculatedModuleMs = currentGlobalMs - (previousCheckpointSecs);

        // elapsedMs = sessionManager.getStoredTime(currentIndex);
        // Constants.hDebug(debugName, "elapsedMs: " + elapsedMs);
        progressDial.value = 0;
        m_targetReached = false;
        progressDial.dialBgColor = Constants.surfaceColor;
        progressDial.dialColor = Constants.secondaryColor

        // Update UI Properties for ProtocolForm.ui.qml [Source 17]
        currentModuleName = entry.data.module_name;
        currentQuantity = entry.data.quantity + unitSymbol;
        unitType = entry.data.unit_type;

        // Duration Calculation: quantity * rep_time * fatigue_rate [Source 18]
        // unit_type 0: SECONDS | 1: REPS
        // TODO: Add countdown timer to time unitType (0) ??
        if (unitType === 0) {
            protocolController.currentModuleDuration = entry.data.quantity * 1000;
            progressDial.messageColor = Constants.primaryTextColor;
            progressDial.dialMessage = "WAIT";
        } else {
            protocolController.progressDial.messageColor = Constants.secondaryTextColor;
            progressDial.dialMessage = "NEXT";

            let lastDuration = 0;
            if (lastSessionCheckpoints.length > index) {
                let currentCP = lastSessionCheckpoints[index];
                let prevCP = (index > 0) ? lastSessionCheckpoints[index - 1] : 0;
                lastDuration = currentCP - prevCP;
            }
            if (lastDuration > 0) {
                // Use real historical duration for the 'Ghost' effect
                protocolController.currentModuleDuration = lastDuration;
                Constants.hDebug(debugName, "Duration loaded from last session: " + lastDuration);
            } else {
                let baseTime = entry.data.rep_time || 2.0; // TODO: load from last session if exists
                let fatigue = entry.data.fatigue_rate || 1.0;
                protocolController.currentModuleDuration = (entry.data.quantity * baseTime * fatigue) * 1000;
                Constants.hDebug(debugName, "Duration calculated: " + protocolController.currentModuleDuration );
            }
        }

        if (index < executionList.length -1) {
            // Constants.hDebug(debugName, "Let next");
            let next = executionList[index +1];
            let nextUnitSymbol = systemManager.getUnitLabel(next.data.unit_type) || "";
            nextModuleText.label = next.data.quantity + nextUnitSymbol + " " + next.data.module_name ;
            // Constants.hDebug(debugName, next.data.module_name + " Content: " + JSON.stringify(next));
        } else {
            // Constants.hDebug(debugName, "NO Let next");
            nextModuleText.label = "Last" ;
        }
        // Update active subsystem for the Row of Rectangles
        activeSubsystemId = entry.subId;
        protocolController.subsystemProgress.activeSubsystemIndex = activeSubsystemId - 1;

        // Filter the execution list to find modules belonging to the current subsystem
        let modulesInCurrentSub = executionList.filter(item => item.subId === activeSubsystemId);
        let totalModulesInSub = modulesInCurrentSub.length;
        // We search for the current entry's position in the filtered subset
        let currentModuleInSubPosition = modulesInCurrentSub.findIndex(item => item === entry);
        // The fill now represents completed/active module steps instead of raw time
        subsystemProgress.activeSubsystemProgress = currentModuleInSubPosition / totalModulesInSub;

        // Constants.hDebug(debugName, "SUBSYSTEM_SYNC: Sub " + activeSubsystemId +
        //             " | Step: " + currentModuleInSubPosition + "/" + totalModulesInSub);

        // Capture the total calories accumulated in previous modules from the manager
        sessionStoredCalories = sessionManager.totalCalories;
        // Constants.hInfo("Module " + index + " loaded. Baseline calories: " + sessionStoredCalories.toFixed(2));

        Constants.hDebug(debugName, "FLOW_UPDATE: Subsystem " + activeSubsystemId + " | Module: " + currentModuleName);
        // We restart it for each new module to have a clean 0.0 -> 1.0 range
        unitChronometer.stop();
        unitChronometer.startFrom(calculatedModuleMs, currentModuleDuration);
        Constants.hInfo(infoName, "Module " + index + " synced. Recovered Offset: " + (calculatedModuleMs / 1000) + "s");
    }

    /**
     * Transition to the next module unit.
     */
    function nextModule() {
        if (isRunning) {
            let globalMS = Math.round(globalChronometer.elapsedMs);
            sessionManager.recordModuleCheckpoint(currentIndex, globalMS);
            loadModule(currentIndex + 1);
        }
    }

    /**
     * Transition to the prev module unit.
     */
    function prevModule() {
        if (isRunning && currentIndex > 0) {
            loadModule(currentIndex - 1);
        }
    }

    function finishProtocol() {
        isRunning = false;
        currentModuleName = "COMPLETED";
        currentQuantity = "";
        progressDial.messageColor = Constants.primaryTextColor
        progressDial.dialMessage = "STOPPED";
        nextModuleText.label = "GOD_JOB!";
        nextModuleTitle.label = " ";
        subsystemProgress.activeSubsystemProgress = 1.0;

        if (typeof globalChronometer !== "undefined") {
            globalChronometer.stop();
            Constants.hInfo(infoName, "Session chronometer halted.");
        }

        if (typeof unitChronometer !== "undefined") {
            unitChronometer.stop();
            Constants.hInfo(infoName, "Modules chronometer halted.");
        }

        Constants.hInfo(infoName, "Execution sequence finalized and all timers stopped.");
        let currentAchievements = achievementManager.achievements;
        for (let i = 0; i < currentAchievements.length; i++) {
            // We save a static copy of the 'unlocked' property
            // to avoid live pointer references during comparison
            lastAchievements.push({
                "unlocked": currentAchievements[i].unlocked
            });
        }

        activeSessionId = sessionManager.saveSession();
        header.buttonLabel ="SUMMARY";
        header.buttonGlyph = Constants.summaryIcon;
        header.buttonLink = "summary";
    }
}

