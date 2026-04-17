import QtQuick
import org.aic.hyperhiit 1.0


import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

ProtocolForm {
    id: protocolController
    // Initial state: Preparation phase
    currentModuleName: "ENGAGING"
    countdownTimer: -5 // Starting from -5 as requested
    unitType: 0 // Display as REPS/Units for the countdown
    unit: "s"
    currentQuantity: countdownTimer + unit

    property real startX: 0
    property real threshold: 50 // Minimum pixels to trigger a displacement
    property var flatExecutionList: []
    property int currentFlatIndex: 0
    property int activeSubsystemId: 0
    property bool isRunning: false

    // Internal state for progress tracking
    property real currentModuleDuration: 10000
    property real elapsedInModule: 0

    Component.onCompleted: {
        flattenProtocolModel();
        let next = flatExecutionList[0];
        nextModuleText.label = next.data.quantity + next.data.unit + " " + next.data.name ;
    }

    onProtocolDataModelChanged: {
        if (protocolDataModel && protocolDataModel.length > 0) {
            flattenProtocolModel();
        } else {
            console.log("Wait: Protocol data model is empty or null.");
        }
    }


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

    // Back button action
    header.settingsMouseArea.onClicked: {
        console.log("Back to Briefing...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.pop();
    }

    // Timer to update the dial value every 50ms for smooth animation
    Timer {
        id: progressUpdater
        interval: 50
        repeat: true
        running: protocolController.isRunning || preparationTimer.running

        onTriggered: {
            if (preparationTimer.running) {
                // Countdown progress: maps -5..0 to 0.0..1.0
                // Calculation: (TotalTime + currentNegativeValue) / TotalTime
                let cdProgress = (5 + protocolController.countdownTimer) / 5;
                progressDial.value = Math.min(Math.max(cdProgress, 0.0), 1.0);
                console.log("Countdown value: " + progressDial.value);
            } else if (protocolController.isRunning) {
                // Module execution progress
                elapsedInModule += 50;
                if (currentModuleDuration > 0) {
                    let execProgress = elapsedInModule / currentModuleDuration;
                    progressDial.value = Math.min(execProgress, 1.0);
                    console.log("Module value: " + progressDial.value);
                }
            }
        }
    }

    // [NEURAL_SYNC] Internal timer for the 5-second countdown
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

                    // currentModuleName = "Burpees";
                    // currentQuantity = "30x";

                    // // Start the C++ Chronometer logic
                    // // Assuming 'myChrono' is globally available or passed from main
                    // myChrono.start(0);
                    // console.log("NEURAL_SYNC: Countdown finished. Protocol clock engaged.");
                }
            }
        }
    }

    progressDial.dialMouseArea.onPressed: (mouse) => {
        startX = mouse.x;
    }

    progressDial.dialMouseArea.onReleased: (mouse) => {
        let deltaX = mouse.x - startX;

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
        // Logic to move backward or decrease quantity [Source 17]
        // console.log("NEURAL_SYNC: Right swipe detected. Incrementing module value.");
    }

    function handleLeftSwipe() {
        nextModule();
        // console.log("NEURAL_SYNC: Left swipe detected. Decrementing module value.");
        // Logic to move forward or increase quantity
    }

    function handleDialTap() {
        nextModule();
        // console.log("NEURAL_SYNC: Dial tapped. Validating current state.");
    }

    /**
     * [DATA_PROCESSING] Converts hierarchical model to a linear list.
     * Prevents duplicate DB calls by reusing the existing protocolDataModel [Source 12].
     */
    function flattenProtocolModel() {
        let tempPath = [];
        console.log("DEBUG: Full Model Content: " + JSON.stringify(protocolDataModel));

        // protocolDataModel structure: [ {subsystemId: 1, modules: [...]}, ... ]
        for (let i = 0; i < protocolDataModel.length; i++) {
            let subsystem = protocolDataModel[i];
            for (let j = 0; j < subsystem.modules.length; j++) {
                let module = subsystem.modules[j];
                // Store module data alongside its parent subsystem ID for UI syncing
                tempPath.push({
                    "data": module,
                    "subId": subsystem.subsystem_id
                });
            }
        }
        flatExecutionList = tempPath;
        console.log("NEURAL_SYNC: Protocol flattened. Total units: " + flatExecutionList.length);
    }
    /**
     * [EXECUTION_START] Engages the clock and loads the first module.
     */
    function startProtocol() {
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
        elapsedInModule = 0;
        console.log("flatExecutionList.length: " + flatExecutionList.length + " | index: " + index);
        if (index >= flatExecutionList.length) {
            finishProtocol();
            return;
        }

        currentFlatIndex = index;
        let entry = flatExecutionList[index];

        // Update UI Properties for ProtocolForm.ui.qml [Source 17]
        currentModuleName = entry.data.name;
        currentQuantity = entry.data.quantity + entry.data.unit;
        // unitType = entry.data.unit;

        if (index < flatExecutionList.length -1) {
            console.log("Let next");
            let next = flatExecutionList[index +1];
            nextModuleText.label = next.data.quantity + next.data.unit + " " + next.data.name ;
        } else {
            console.log("NO Let next");
            nextModuleText.label = "Last" ;
        }
        // Update active subsystem for the Row of Rectangles
        activeSubsystemId = entry.subId;

        console.log("FLOW_UPDATE: Subsystem " + activeSubsystemId + " | Module: " + currentModuleName);
    }

    /**
     * [ACTION] Transition to the next atomic unit.
     */
    function nextModule() {
        if (isRunning) {
            loadModule(currentFlatIndex + 1);
        }
    }

    function finishProtocol() {
        isRunning = false;
        currentModuleName = "COMPLETED";
        currentQuantity = "";
        progressDial.dialMessage = "STOPPED";
        nextModuleText.label = "GOD_JOB!";
        nextModuleTitle.label = " ";
        if (typeof myChrono !== "undefined") myChrono.stop();
        console.log("NEURAL_SYNC: Execution sequence finalized.");
    }
}

