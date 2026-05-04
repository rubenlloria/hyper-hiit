pragma Singleton
import QtQuick
//import QtQuick.Studio.Application

QtObject {
    // --- WINDOW DIMENSIONS ---
    readonly property int width: 412
    readonly property int height: 865
    // Reference dimensions from your original design
    readonly property int designWidth: 412
    readonly property int designHeight: 915
    // Scale factor based on the actual width of the window/screen
    // This ensures the UI looks the same on a 360px or 412px logical width screen
    property real scaleFactor: 1.0
    // Helper function to scale sizes easily
    function px(value) { return value * scaleFactor }

    // --- COLOR PALETTE (Centralized for Neon Theme) ---
    readonly property color blackNeon:          "#030213"
    readonly property color darkNeon:           "#1a1a1f"
    readonly property color whiteNeon:          "#ffffff"
    readonly property color cyanNeon:           "#00fff9"
    readonly property color fuchsiaNeon:        "#bf00ff"
    readonly property color greenNeon:          "#39ff14"
    readonly property color terminalGreen:      greenNeon   // TODO: DELETEME
    readonly property color neonLime:           greenNeon   // TODO: DELETEME
    readonly property color redNeon:             "#ff003c"
    readonly property color radicalRed:         redNeon     // TODO: DELETEME
    readonly property color yellowNeon:         "#ffdf00"
    readonly property color cyberYellow:        yellowNeon  // TODO: DELETEME
    // readonly property color backgroundColor: "#EAEAEA"
    readonly property color backgroundColor:    blackNeon
    readonly property color descriptionColor:   whiteNeon
    readonly property color primaryColor:       fuchsiaNeon
    readonly property color secondaryColor:     cyanNeon
    readonly property color primaryTextColor:   cyanNeon
    readonly property color secondaryTextColor: fuchsiaNeon
    readonly property color onColor:            cyanNeon
    readonly property color offColor:           fuchsiaNeon


    // --- DESIGN TOKENS ---

    // --- ICONS (From Lucide font)
    readonly property string settingsIcon:  "\uE154" // settings
    readonly property string playIcon:      "\uE481" // square-play
    readonly property string backIcon:      "\uE1E2" // arrow-big-left
    readonly property string flameIcon:     "\ue0d2" // Fat burning
    readonly property string heartIcon:     "\ue0f2" // Cardio
    readonly property string targetIcon:    "\ue180" // Endurance
    readonly property string zapIcon:       "\ue1b4" // Strength
    readonly property string brainIcon:     "\ue3c6" // Neural
    readonly property string chevronDown:   "\uE06D" // chevron-down
    readonly property string chevronLeft:   "\uE06E" // chevron-left
    readonly property string chevronRight:  "\uE06F" // chevron-right
    readonly property string chevronUp:     "\uE070" // chevron-up
    readonly property string evolutionIcon: "\uE191" // trending-up

/*
    // --- FONT CONFIGURATION ---

    readonly property font mainFont: Qt.font({
        family: "Orbitron",
        pixelSize: 16,
        weight: Font.Normal
    })

    readonly property font techFont: Qt.font({
        family: "Share Tech Mono",
        pixelSize: 40,
        letterSpacing: 1
    })

    readonly property font techFontLabel: Qt.font({
        family: "Share Tech Mono",
        pixelSize: 14,
        letterSpacing: 1
    })

    readonly property font titleFont: Qt.font({
        family: "Orbitron",
        pixelSize: 28,
        weight: Font.Bold
    })

    readonly property font iconFont: Qt.font({
        family: "Lucide",
        pixelSize: 40,
    })
*/

    // --- FONT LOADING (CRITICAL FIX) ---
    // We create hidden loaders to register the TTF files in the app
    property var _loader1: FontLoader { id: lucideLoader; source: Qt.resolvedUrl("assets/fonts/lucide.ttf") }
    property var _loader2: FontLoader { id: orbitronLoader; source: Qt.resolvedUrl("assets/fonts/Orbitron-VariableFont_wght.ttf") }
    property var _loader3: FontLoader { id: shareTechLoader; source: Qt.resolvedUrl("assets/fonts/ShareTechMono-Regular.ttf") }
    property var _loader4: FontLoader { id: orbitronMonoLoader; source: Qt.resolvedUrl("assets/fonts/OrbitronMono-Black.ttf") }

    // --- FONT CONFIGURATIONS ---
    // Now 'family' will match the name registered by the loaders
    readonly property font iconFont: Qt.font({
        family: lucideLoader.name,
        pixelSize: 40
    })

    readonly property font mainFont: Qt.font({
        family: orbitronLoader.name,
        pixelSize: 16
    })

    readonly property font mainMonoFont: Qt.font({
        family: orbitronMonoLoader.name,
        pixelSize: 16,
        weight: Font.Black
    })

    readonly property font titleFont: Qt.font({
        family: orbitronLoader.name,
        pixelSize: 28,
        weight: Font.Bold

    })

    readonly property font techFont: Qt.font({
        family: shareTechLoader.name,
        pixelSize: 14,
        letterSpacing: 1
    })

    // Updated path to point to your new assets folder [Source 27]
    readonly property string fontDirectory: "assets/fonts/"
    // Helper to resolve URLs relative to this file
    function fontUrl(fontFileName) {
        return Qt.resolvedUrl(fontDirectory + fontFileName)
    }

    /**
     * Custom logging helpers to match the hyper//hiit backend format.
     * Provides a unified look for terminal telemetry [Source 122].
     */
    function hDebug(qml, msg) {
        if (qml === "") return;
        console.debug("[DEBUG]:", qml+":", msg)
    }

    function hInfo(qml, msg) {
        if (qml === "") return;
        console.info("[INFO]:", qml+":", msg)
    }

    function hWarning(qml, msg) {
        if (qml === "") return;
        console.warn("[WARNING]:", qml+":", msg)
    }

    function hCritical(qml, msg) {
        if (qml === "") return;
        console.error("[CRITICAL]:", qml+":", msg)
    }

}
