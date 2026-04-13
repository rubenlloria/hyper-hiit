/****************************************************************************
** File: Briefing.qml
** Date: 13/4/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License version 2 as
** published by the Free Software Foundation.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
import QtQuick
import "../components"
// Access to NeonIcon, NeonText, etc.
import ".."

BriefingForm {
    // Ara sí, definim l'acció del clic
    header.settingsMouseArea.onClicked: {
        console.log("Back to dashboard...");
        // Aquí aniria la crida al StackView o al controlador C++
        mainStack.push("Dashboard.qml");
    }
}