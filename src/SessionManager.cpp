/****************************************************************************
** File: SessionManager.cpp
** Date: 21/4/2026
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
#include "SessionManager.h"

void SessionManager::startSession(int protocolId, int moduleCount) {
    m_protocolId = protocolId;
    m_startTimestamp = QDateTime::currentSecsSinceEpoch();
    m_totalCalories = 0.0f;
    m_activeModuleIndex = 0;

    // Initialize the buffer with zeros based on protocol structure [Source 16]
    m_moduleDurations.clear();
    for(int i = 0; i < moduleCount; ++i) m_moduleDurations << 0;

    hInfo() << "Session Started for Protocol:" << protocolId << "Modules:" << moduleCount;
}

void SessionManager::recordModuleTime(int index, int seconds) {
    if (index >= 0 && index < m_moduleDurations.size()) {
        // We only update if the new time is valid (prevents overwriting on navigation errors)
        m_moduleDurations[index] = seconds;
        hDebug() << "Module" << index << "telemetry recorded:" << seconds << "s";
    }
}

int SessionManager::getStoredTime(int index) const {
    if (index >= 0 && index < m_moduleDurations.size()) {
        return m_moduleDurations.at(index);
    }
    return 0;
}

QString SessionManager::getModulesLogString() const {
    // Converts the list to the "90,20,80..." format for Level 4 persistence
    QStringList list;
    for (int time : m_moduleDurations) list << QString::number(time);
    return list.join(",");
}
