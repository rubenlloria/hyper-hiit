
/****************************************************************************
** File: NeonCombo.ui.qml
** Date: 28/6/2026
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
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import ".."


/*
   NeonCombo.ui.qml
   NeonCombo Component
   Customized dropdown for the Architect Suite (v0.9.2).
   Used for selecting UNIT_TYPES and TARGET_ZONES.
*/
ComboBox {
    id: control

    // --- PROPERTIES ---
    property color accentColor: Constants.primaryColor
    property bool isDirty: false
    // property int highlightedIndex: 1

    // Static models for the Architect Suite
    readonly property var unitModel: ["SECONDS", "REPS", "BREATHS", "METERS"]
    readonly property var zoneModel: ["CORE", "FULL_BODY", "UPPER_PUSH", "UPPER_PULL", "LOWER_HINGE", "LOWER_KNEE", "STRETCH", "MOBILITY", "REST"]
    readonly property var difficultyModel: ["NEWBIE", "ADVANCED", "ROOT"]

    // width: 140
    height: 35
    model: unitModel

    // 1. LIST ITEM DELEGATE (The dropdown rows)
    delegate: ItemDelegate {
        width: control.width
        height: 30

        contentItem: Text {
            text: modelData
            // Highlighted text is black, standard is accent color
            color: control.highlightedIndex === index ? "#0d0d10" : control.accentColor
            font.family: Constants.techFont.family
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
        }

        background: Rectangle {
            // Background is solid accent color when highlighted (as seen in screenshot)
            color: control.highlightedIndex === index ? control.accentColor : "transparent"
        }
    }

    // 2. DROP DOWN INDICATOR (The arrow)
    indicator: NeonIcon {
        x: control.width - width - 10
        y: (control.height - height) / 2
        width: 15
        height: 15
        glyph: Constants.chevronDown
        color: control.accentColor
        size: 25
    }

    // 3. MAIN DISPLAY TEXT (The collapsed view)
    contentItem: Text {
        leftPadding: 10
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font.family: Constants.mainFont.family
        font.pixelSize: 12
        font.bold: true
        color: control.accentColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // 4. COMPONENT FRAME
    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 35
        color: Constants.deepColor
        border.color: control.isDirty ? Constants.rootColor : control.accentColor
        border.width: 1

        // Subtle inner glow
        layer.enabled: true
        layer.effect: InnerShadow {
            color: control.accentColor
            opacity: control.isDirty ? 0.4 : 0.2
            // color: control.isDirty ? "#40bf00ff" : Qt.alpha(control.accentColor, 0.2)
            radius: 4
            samples: 8
        }
    }

    // 5. POPUP CONFIGURATION
    popup: Popup {
        y: control.height + 2
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 0

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {
                active: true
            }
        }

        background: Rectangle {
            color: Constants.backgroundColor
            border.color: control.isDirty ? Constants.rootColor : control.accentColor
            border.width: 1
        }
    }
}
