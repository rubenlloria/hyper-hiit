

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: root
    width: label.implicitWidth
    height: label.implicitHeight

    property alias label: label.text
    property alias labelColor: label.color
    property alias size: label.font.pixelSize

    // FontLoader {
    //     id: internalShareTecFont
    //     source: "fonts/Orbitron-VariableFont_wght.ttf"
    // }
    Text {
        id: label
        text: "LABEL"
        color: Constants.secondaryTextColor
        font.family: Constants.techFont.family
        font.pixelSize: 20
        font.letterSpacing: 1
        anchors.verticalCenter: parent.verticalCenter
        renderType: Text.QtRendering // Ensures implicitWidth is calculated correctly
    }
    DropShadow {
        id: labelGlow
        anchors.fill: label
        source: label
        color: label.color
        radius: 20
        samples: 25
        spread: 0.3
        transparentBorder: true
    }
}
