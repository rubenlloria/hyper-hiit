
/****************************************************************************
** File: NeonTitle.ui.qml
** Date: 12/5/2026
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

import "."
import ".."

Item {
    id: root
    height: titleText.height + 5

    // Propietats personalitzables
    property alias label: titleText.label
    property color titleColor: Constants.secondaryTextColor
    property int fontSize: 18

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 15
        width: parent.width

        // 1. Línia Esquerra (Degradat de transparent a color)
        Item {
            height: parent.height
            Layout.fillWidth: true

            Rectangle {
                id: leftLine
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 1.0
                        color: root.titleColor
                    }
                }
            }

            DropShadow {
                anchors.fill: leftLine
                source: leftLine
                color: root.titleColor
                radius: 10
                samples: 15
            }
        }

        // 2. Text Central (Reutilitzant la teua lògica de NeonText)
        NeonText {
            id: titleText
            label: "TITLE"
            labelColor: root.titleColor
            size: root.fontSize
            cornerWidth: 1
            Layout.alignment: Qt.AlignVCenter
        }

        // 3. Línia Dreta (Degradat de color a transparent)
        Item {
            height: parent.height
            Layout.fillWidth: true

            Rectangle {
                id: rightLine
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: root.titleColor
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }
            }

            DropShadow {
                anchors.fill: rightLine
                source: rightLine
                color: root.titleColor
                radius: 10
                samples: 15
            }
        }
    }
}
