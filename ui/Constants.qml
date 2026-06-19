pragma Singleton
import QtQuick
//import QtQuick.Studio.Application

QtObject {
    id: qtObject
    // --- WINDOW DIMENSIONS ---
    readonly property int width: 412
    readonly property int height: 865
    // Reference dimensions from your original design
    readonly property int designWidth: 412
    readonly property int designHeight: 915
    readonly property int bottomMargin: 70
    // Scale factor based on the actual width of the window/screen
    // This ensures the UI looks the same on a 360px or 412px logical width screen
    property real scaleFactor: 1.0
    // Helper function to scale sizes easily
    function px(value) { return value * scaleFactor }

    // =========================================================================
    // --- CYBERPUNK COLOR PALETTE ---
    // =========================================================================
    readonly property color blackNeon:          "#030213"
    readonly property color darkNeon:           "#1a1a1f"
    readonly property color deepNeon:           "#0d0d10"
    readonly property color darkMagenta:        "#1a0b1a"
    readonly property color darkBlue:           "#0d0d20"
    readonly property color whiteNeon:          "#ffffff"
    readonly property color greyNeon:           "#9595a7" // "#808090"
    readonly property color cyanNeon:           "#00fff9"
    readonly property color fuchsiaNeon:        "#bf00ff"
    readonly property color greenNeon:          "#39ff14"
    readonly property color redNeon:            "#ff003c"
    readonly property color yellowNeon:         "#ffdf00"

    // --- NEW EXPERIMENTAL & TACTICAL VARIABLES ---
    readonly property color deepVoid:           "#0a0a0f"
    readonly property color electricAmber:      "#ffb300"
    readonly property color darkAmber:          "#8a6200"
    readonly property color abyssalBlue:        "#050522"
    readonly property color matteWhite:         "#f0f0f5"
    readonly property color tacticalGray:       "#a0a0b0"
    readonly property color lightGray:          "#e0e0e0"
    readonly property color inkBlack:           "#1a1a1f"
    readonly property color charcoal:           "#212126" // "#2a2a30"
    readonly property color softRed:            "#ff809d"
    readonly property color softBlue:           "#6666a3"
    readonly property color tangerine:          "#ff5e00"
    readonly property color spaceBlue:          "#5b84ff"

    // =========================================================================
    // --- THEME DEFINITIONS (Hardcoded Matrix) ---
    // =========================================================================
    readonly property var themeKeys: ["CYBERPUNK", "GHOST_SHELL", "LIGHT_REPORT"]
    readonly property var themes: {
        "CYBERPUNK": {
            "backgroundColor":     blackNeon,
            "surfaceColor":        darkNeon,
            "deepColor":           deepNeon,
            "descriptionColor":    whiteNeon,
            "rootColor":           redNeon,
            "primaryColor":        fuchsiaNeon,
            "secondaryColor":      cyanNeon,
            "primaryDarkColor":    darkMagenta,
            "secondaryDarkColor":  darkBlue,
            "primaryTextColor":    cyanNeon,
            "secondaryTextColor":  fuchsiaNeon,
            "onColor":             cyanNeon,
            "offColor":            fuchsiaNeon
        },
        "GHOST_SHELL": {
            "backgroundColor":     deepVoid,
            "surfaceColor":        darkNeon,
            "deepColor":           deepNeon,
            "descriptionColor":    tacticalGray,
            "rootColor":           greyNeon,
            "primaryColor":        matteWhite,
            "secondaryColor":      electricAmber,
            "primaryDarkColor":    darkAmber,
            "secondaryDarkColor":  abyssalBlue,
            "primaryTextColor":    electricAmber,
            "secondaryTextColor":  matteWhite,
            "onColor":             electricAmber,
            "offColor":            darkNeon
        },
        "LIGHT_REPORT": {
            "backgroundColor":     lightGray,
            "surfaceColor":        whiteNeon,
            "deepColor":           greyNeon,
            "descriptionColor":    charcoal,
            "rootColor":           inkBlack,
            "primaryColor":        redNeon,
            "secondaryColor":      darkBlue,
            "primaryDarkColor":    softRed,
            "secondaryDarkColor":  softBlue,
            "primaryTextColor":    darkBlue,
            "secondaryTextColor":  redNeon,
            "onColor":             redNeon,
            "offColor":            greyNeon
        }
    }

    // --- ACTIVE PALETTE (Neural Sync) ---
    // We use a reference to the active theme object
    property var activeTheme: themes["CYBERPUNK"]

    // These properties allow existing components to remain unchanged
    property color backgroundColor:     activeTheme.backgroundColor
    property color surfaceColor:        activeTheme.surfaceColor
    property color deepColor:           activeTheme.deepColor
    property color descriptionColor:    activeTheme.descriptionColor
    property color rootColor:           activeTheme.rootColor
    property color primaryColor:        activeTheme.primaryColor
    property color secondaryColor:      activeTheme.secondaryColor
    property color primaryDarkColor:    activeTheme.primaryDarkColor
    property color secondaryDarkColor:  activeTheme.secondaryDarkColor
    property color primaryTextColor:    activeTheme.primaryTextColor
    property color secondaryTextColor:  activeTheme.secondaryTextColor
    property color onColor:             activeTheme.onColor
    property color offColor:            activeTheme.offColor

    // --- DESIGN TOKENS ---

    // --- ICONS (From Lucide font)
    readonly property string settingsIcon:  "\uE154" // settings
    readonly property string playIcon:      "\uE481" // square-play
    readonly property string pauseIcon:     "\uE684" // square-pause
    readonly property string backIcon:      "\uE1E2" // arrow-big-left
    readonly property string flameIcon:     "\ue0d2" // Fat burning
    readonly property string heartIcon:     "\ue0f2" // Cardio
    readonly property string targetIcon:    "\ue180" // Endurance
    readonly property string zapIcon:       "\ue1b4" // Strength &
    readonly property string brainIcon:     "\ue3c6" // Neural
    readonly property string chevronDown:   "\uE06D" // chevron-down
    readonly property string chevronLeft:   "\uE06E" // chevron-left
    readonly property string chevronRight:  "\uE06F" // chevron-right
    readonly property string chevronUp:     "\uE070" // chevron-up
    readonly property string evolutionIcon: "\uE191" // trending-up
    readonly property string summaryIcon:   "\uE2A5" // chart-line
    readonly property string dashboardIcon: "\uE1C1" // layout-dashboard
    readonly property string badgeIcon:     "\uE241" // ACHIEMEVENT_MATRIX
    readonly property string pencilIcon:    "\uE1F9" // pencil (Edit directive)
    readonly property string trashIcon:     "\uE18E" // trash-2 (delete)
    // Power & Stamina Protocols (High Intensity)
    readonly property string kineticIcon:   "\ue58c" // bolt (Kinetic Energy)
    readonly property string weightIcon:    "\ue530" // weight (Heavy Load)
    readonly property string recoveryIcon:  "\ue054" // battery-charging (Power Recovery)
    // Bio-Sync & Neural Protocols (Coordination)
    readonly property string dnaIcon:       "\ue393" // dna (Genetic Code)
    readonly property string microchipIcon: "\ue61a" // microchip (System Core)
    // Tactical & Combat (Industrial/Architect)
    readonly property string swordsIcon:    "\ue2b4" // swords (Combat Drill)
    readonly property string crosshairIcon: "\ue0ac" // crosshair (Precision Grid)
    readonly property string terminalIcon:  "\ue181" // terminal (Data Override)
    // --- ADDITIONAL PROTOCOLS (To round the grid)
    readonly property string atomIcon:      "\uE3D7" // atom (Metabolic/Molecular)
    readonly property string radarIcon:     "\uE497" // radar (Surveillance/Field)
    readonly property string anvilIcon:     "\uE580" // anvil (Muscular fortification)
    readonly property string starIcon:      "\uE176" // star (Priority directive)
    readonly property string muscleIcon:    "\ue5eb" // biceps-flexed (Strength Matrix / Muscular fortification)
    readonly property string zenIcon:       "\ue2d3" // flower (Yoga & Pilates / Core symmetry)
    readonly property string runIcon:       "\ue3b9" // footprints (Locomotion Grid / Running)
    readonly property string swimIcon:      "\ue283" // waves (Aqua Dynamics / Swimming)
    // // --- TRAINING MODALITIES & SPECIFIC GOALS ---
    readonly property string dumbbellIcon:     "\ue3a1" // dumbbell (Weightlifting / Hypertrophy)
    readonly property string bikeIcon:       "\ue1d2" // bike (Cycling / Endurance protocols)
    readonly property string combatIcon:     "\ue68b" // hand-fist (Combat drills / Martial arts)
    readonly property string mountainIcon:   "\ue231" // mountain (Outdoor training / Altitude)
    readonly property string agilityIcon:    "\ue1b0" // wind (Speed & Agility / Quick response)
    readonly property string stretchIcon:    "\ue27c" // stretch-horizontal (Flexibility / Mobility)
    readonly property string medalIcon:      "\ue36f" // medal (Competitive goals / Performance)
    readonly property string trophyIcon:     "\ue373" // trophy (Mastery directives / Final rank)

    // --- SYSTEM & UTILITY
    readonly property string saveIcon:      "\uE14D" // save (Consolidate configuration)
    readonly property string scanIcon:      "\uE257" // scan (Module diagnostic)
    readonly property string eyeIcon:       "\uE0BA" // eye (Visual monitoring)
    readonly property string infoIcon:      "\uE0F9" // info (System metadata)

    // Badges
    readonly property string activityIcon:  "\uE038" //  1. NEURAL Badge
    readonly property string fireIcon:      "\uE53A" //  2. FIRE Badge
    readonly property string shieldIcon:    "\uE158" //  3. IRON Badge
    readonly property string ffwIcon:       "\uE0Bd" //  4. SPEED Badge
    readonly property string timerIcon:     "\uE1E0" //  5. ENDURANCE Badge
    readonly property string crownIcon:     "\uE1D6" //  6. ULTRA Badge
    readonly property string cpuIcon:       "\uE0A9" //  7. OVERCLOCK Badge
    readonly property string loginIcon:     "\uE10D" //  8. SYSINIT Badge
    readonly property string ghostIcon:     "\uE20E" //  9. GHOST Badge
    readonly property string layersIcon:    "\uE529" // 10. CENTURION Badge


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

    /**
     * Tactical Switch: Updates the active palette reference.
     * This can be called from SystemManager or directly from UI.
     */
    function setTheme(index) {
        let key = themeKeys[index];
        if (key && themes[key]) {
            activeTheme = themes[key];
            Constants.hInfo("Constants", "Aesthetic shift to: " + key);
        }
    }
}
