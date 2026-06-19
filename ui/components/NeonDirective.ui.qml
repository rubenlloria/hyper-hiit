
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls

import ".."


/*
    Individual item for the directive selection dropdown.
    Compliant with .ui.qml strict formatting.
*/
Item {
    id: root
    width: 350
    height: 65

    // Public properties for data binding
    property string directiveTitle: "DIRECTIVE_NAME"
    property string directiveDescription: "Description text"
    property string directiveGlyph: "\ue0d2"
    property color color: Constants.primaryTextColor

    // Alias to expose the interaction area to the parent
    property alias itemMouseArea: interactionArea

    // Main background layer
    Rectangle {
        id: backgroundBase
        anchors.fill: parent
        color: Constants.deepColor
        opacity: 0.8
        border.color: root.color
        border.width: 1
    }

    // Visual feedback layer for touch interaction (pressed state)
    Rectangle {
        id: touchHighlight
        anchors.fill: parent
        color: root.color
        opacity: 0 // Hidden by default
    }

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 15

        // Icon placeholder container
        Rectangle {
            id: iconFrame
            width: 40
            height: 40
            color: "transparent"
            NeonIcon {
                id: directiveIcon
                anchors.centerIn: parent
                glyph: root.directiveGlyph // Alias al glifo de Lucide
                color: root.color
                size: 20
                glowRadius: 15 // Valor para el resplandor de neón [1]
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: labelTitle
                text: root.directiveTitle
                color: root.color
                font.family: Constants.mainFont.family
                font.pixelSize: 14
                font.bold: true
                width: 250
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                id: labelDescription
                text: root.directiveDescription
                color: Constants.descriptionColor
                opacity: 0.7
                font.family: Constants.techFont.family
                font.pixelSize: 10
                width: 250
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    MouseArea {
        id: interactionArea
        anchors.fill: parent
    }

    // UI State definitions (must be in root element for .ui.qml)
    states: [
        State {
            name: "pressed"
            when: interactionArea.pressed
            PropertyChanges {
                target: touchHighlight
                opacity: 0.2
            }
            PropertyChanges {
                target: backgroundBase
                border.width: 2
            }
        }
    ]
}
