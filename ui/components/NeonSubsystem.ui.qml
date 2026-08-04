
/****************************************************************************
** File: NeonSubsystem.ui.qml
** Date: 15/4/2026
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
    width: subsystemColumn.implicitWidth
    height: subsystemColumn.implicitHeight
    property color color: Constants.secondaryTextColor
    property int subsystemId: 0
    property var modulesModel: []

    Column {
        id: subsystemColumn
        spacing: 5
        Rectangle {
            width: root.width
            height: 1
            color: root.color
            opacity: 0.2
        }

        Text {
            text: qsTr("SUBSYSTEM_0") + root.subsystemId + ":"
            color: Constants.primaryTextColor
            font.family: Constants.mainFont.family
            font.pixelSize: 12
        }
        Repeater {
            id: moduleRepeater
            model: root.modulesModel

            Text {
                text: modelData.quantity + modelData.unit + " " + modelData.name
                color: root.color
                font.family: Constants.techFont.family
                font.pixelSize: 20
                font.bold: true
            }
        }
    }
}
