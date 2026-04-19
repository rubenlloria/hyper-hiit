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
    unit: "s"
    currentQuantity: countdownTimer + unit

    property real startX: 0
    property real tapX: 0
    property real threshold: 50 // Minimum pixels to trigger a displacement
    property var executionList: []
    property int currentIndex: 0
    property int activeSubsystemId: 0
    property bool isRunning: false

    // Internal state for progress tracking
    property real currentModuleDuration: 10000
    property real elapsedMs: 0
    readonly property var unitSymbols: ["s", "x", "b"]

    onActiveProtocolIdChanged: {
        if (activeProtocolId > 0) {
            loadProtocolDetails();
            let next = executionList[0];
            let unitSymbol = unitSymbols[next.data.unit_type] || "";
            console.log("DEBUG: " + next.module_name + " Content: " + JSON.stringify(next));
            nextModuleText.label = next.data.quantity + unitSymbol + " " + next.data.module_name;
        }
    }

    // Component.onCompleted: {
    //     flattenProtocolModel();
    //     let next = executionList[0];
    //     nextModuleText.label = next.mod.quantity + next.mod.unit + " " + next.mod.name ;
    // }

    Chronometer {
        id: myChrono
        onFinished: {
            console.log("Workout Finished!")
        }

        onMaxReached: {
            console.log("maximum time reached!")
        }

        onTimeTextChanged:{
            mainTimer.minSec = myChrono.timeText.substring(0, 5);
            mainTimer.cents= myChrono.timeText.substring(6, 8);
        }
    }

    /**
     * Dedicated C++ instance for the Dial/Unit progress.
     * This ensures the progress remains accurate even if the app is minimized.
     */
    Chronometer {
        id: unitChronometer

        onTimeTextChanged: {
            // Calculate progress based on the actual elapsed MS from C++
            // Using the currentModuleDuration calculated in loadUnit()
            // console.log("unitChrono changed");
            if (protocolController.isRunning && protocolController.currentModuleDuration > 0) {
                // Get raw elapsed time from the chronometer logic
                let elapsedMs = unitChronometer.elapsedMs;
                progressDial.value = Math.min(elapsedMs / protocolController.currentModuleDuration, 1.0);
                // console.log("dial updated | elapsedMS: " + elapsedMs + "moduleDuration: " + protocolController.currentModuleDuration);
            }
        }
    }

    // Back button action
    header.settingsMouseArea.onClicked: {
        console.log("Back to Briefing...");
        mainStack.pop();
    }

    // // Timer to update the dial value every 50ms for smooth animation
    // Timer {
    //     id: progressUpdater
    //     interval: 50
    //     repeat: true
    //     running: protocolController.isRunning || preparationTimer.running

    //     onTriggered: {
    //         if (preparationTimer.running) {
    //             // Countdown progress: maps -5..0 to 0.0..1.0
    //             // Calculation: (TotalTime + currentNegativeValue) / TotalTime
    //             let cdProgress = (5 + protocolController.countdownTimer) / 5;
    //             progressDial.value = Math.min(Math.max(cdProgress, 0.0), 1.0);
    //             console.log("Countdown value: " + progressDial.value);
    //         } else if (protocolController.isRunning) {
    //             // Module execution progress
    //             protocolController.elapsedMs += 50;
    //             if (protocolController.currentModuleDuration > 0) {
    //                 let execProgress = protocolController.elapsedMs / (protocolController.currentModuleDuration);
    //                 progressDial.value = Math.min(execProgress, 1.0);
    //                 console.log("Module value: " + progressDial.value);
    //             }
    //         }
    //     }
    // }

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
        nextModule();
        // Logic to move forward on moldule list
    }

    function handleDialTap() {
        // Logic to move forward or backward if tap on left side
        if ( tapX < 30 ) {
            prevModule();
        } else {
            nextModule();
        }
        console.debug("DEBUG: Mouse tap at " + tapX);
        // console.log("NEURAL_SYNC: Dial tapped. Validating current state.");
    }

    /**
     * Retrieves full Level 4 metadata from C++ and flattens the hierarchy.
     */
    function loadProtocolDetails() {
        let structuredData = dbManager.getProtocolExecutionDetails(activeProtocolId);
        console.log("DEBUG: Full Model Content: " + JSON.stringify(structuredData));
        let tempSequence = [];

        for (let i = 0; i < structuredData.length; i++) {
            let subsystem = structuredData[i];
            if (subsystem.modules) {
                for (let j = 0; j < subsystem.modules.length; j++) {
                    tempSequence.push({
                        "data": subsystem.modules[j],
                        "subId": subsystem.subsystemId
                    });
                }
            }
        }

        executionList = tempSequence;
        console.log("Protocol sequence synchronized. Total units: " + executionList.length);
    }

    /**
     * [EXECUTION_START] Engages the clock and loads the first module.
     */
    function startProtocol() {
        if (executionList.length === 0)
            return;

        isRunning = true;
        if (typeof myChrono !== "undefined") {
            myChrono.start(0);
        }
        progressDial.dialMessage = "NEXT";
        loadModule(0);
    }

    /**
     * [NEURAL_LINK] Updates the UI shard with the current module telemetry.
     */
    function loadModule(index) {
        console.log("executionList.length: " + executionList.length + " | index: " + index);
        if (index >= executionList.length) {
            finishProtocol();
            return;
        }

        currentIndex = index;
        let entry = executionList[index];
        let unitSymbol = unitSymbols[entry.data.unit_type] || "";
        console.log("DEBUG: " + entry.data.module_name + " Content: " + JSON.stringify(entry));

        elapsedMs = 0;
        progressDial.value = 0;

        // Update UI Properties for ProtocolForm.ui.qml [Source 17]
        currentModuleName = entry.data.module_name;
        currentQuantity = entry.data.quantity + unitSymbol;
        unitType = entry.data.unit_type;
        // unit = unitSymbols[unitType] || "";

        // Duration Calculation: quantity * rep_time * fatigue_rate [Source 18]
        // unit_type 0: SECONDS | 1: REPS
        if (unitType === 0) {
            protocolController.currentModuleDuration = entry.data.quantity * 1000;
            protocolController.progressDial.messageColor = Constants.primaryTextColor
        } else {
            protocolController.progressDial.messageColor = Constants.secondaryTextColor
            let baseTime = entry.data.rep_time || 2.0;
            let fatigue = entry.data.fatigue_rate || 1.0;
            protocolController.currentModuleDuration = (entry.data.quantity * baseTime * fatigue) * 1000;
        }

        if (index < executionList.length -1) {
            console.log("Let next");
            let next = executionList[index +1];
            let nextUnitSymbol = unitSymbols[next.data.unit_type] || "";
            nextModuleText.label = next.data.quantity + nextUnitSymbol + " " + next.data.module_name ;
            console.log("DEBUG: " + next.data.module_name + " Content: " + JSON.stringify(next));
        } else {
            console.log("NO Let next");
            nextModuleText.label = "Last" ;
        }
        // Update active subsystem for the Row of Rectangles
        activeSubsystemId = entry.subId;

        console.log("FLOW_UPDATE: Subsystem " + activeSubsystemId + " | Module: " + currentModuleName);
        // We restart it for each new module to have a clean 0.0 -> 1.0 range
        unitChronometer.stop();
        unitChronometer.start(0);

    }

    /**
     * Transition to the next module unit.
     */
    function nextModule() {
        if (isRunning) {
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
        if (typeof myChrono !== "undefined") myChrono.stop();
        console.log("NEURAL_SYNC: Execution sequence finalized.");
    }
}

