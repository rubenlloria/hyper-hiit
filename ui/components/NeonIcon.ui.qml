
/****************************************************************************
** File: NeonIcon.ui.qml
** Date: 9/3/2026
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
import Qt5Compat.GraphicalEffects

import ".."

Item {
    id: iconRoot
    width: 40
    height: 40

    property alias glyph: shadowSource.text
    property alias size: shadowSource.font.pixelSize
    property alias color: shadowSource.color
    property alias glowRadius: shadow.radius

    // Shadow source (Invisible)
    Text {
        id: shadowSource
        text: "x"
        font.family: Constants.iconFont.family
        font.pixelSize: 40
        color: Constants.primaryColor
        anchors.centerIn: parent
        visible: false
    }

    // Neon Glow effect
    DropShadow {
        id: shadow
        anchors.fill: shadowSource
        source: shadowSource
        color: shadowSource.color
        radius: 20
        samples: 25
        spread: 0.2
        transparentBorder: true
        opacity: 0.8
    }

    // Main visible icon
    Text {
        id: mainIconText
        text: shadowSource.text
        font: shadowSource.font
        color: shadowSource.color
        anchors.centerIn: parent
        visible: true
        renderType: Text.QtRendering
    }
}
