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
    property color titleColor: Constants.fuchsiaNeon
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
