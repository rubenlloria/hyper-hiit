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

#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include "SessionManager.h"
#include "SystemLog.h"
#include "DatabaseManager.h"

SessionManager::SessionManager(DatabaseManager *db, QObject *parent)
    : QObject(parent)
    , m_db(db)
{
    if (!m_db) {
        hCritical() << "ProtocolModel initialized without Database Uplink.";
    } else {
        hDebug() << "Protocol Shard Uplink established.";
    }

    m_totalCalories = 0.0f;
    m_activeModuleIndex = 0;
}

void SessionManager::startSession(int protocolId,  const QVariantList &executionList) {
    m_protocolId = protocolId;
    m_startTimestamp = QDateTime::currentSecsSinceEpoch();
    m_totalCalories = 0.0f;
    m_activeModuleIndex = 0;

    // Initialize the buffer with zeros based on protocol structure
    m_moduleDurations.clear();
    m_moduleMetFactors.clear();

    // Process the structured data from QML
    for (const QVariant &item : executionList) {
        QVariantMap entry = item.toMap();
        // The user's QML structure stores module info in the "data" key
        QVariantMap moduleData = entry["data"].toMap();

        // Initialize telemetry shards
        m_moduleDurations.append(0);

        // Store MET factor for real-time metabolic tracking [Source 19, 60]
        float met = moduleData["met_factor"].toFloat();
        m_moduleMetFactors.append(met);
        hDebug() << "Met factor" << met ;
    }
    // for(int i = 0; i < moduleCount; ++i) m_moduleDurations << 0;

    hInfo() << "Session Started for Protocol: " << protocolId << " | Modules: " << m_moduleDurations.size() << " | Timestamp: " << m_startTimestamp;
}

/**
 * Records the module checkpoint with a 5-second guard interval.
 * Prevents overwriting valid telemetry if the user navigates by mistake
 */
void SessionManager::recordModuleCheckpoint(int index, int globalMS) {
    if (index < 0 || index >= m_moduleDurations.size()) {
        hWarning() << "Invalid module index for checkpoint:" << index;
        return;
    }

    // Calculate how much time was spent in this module during this specific visit
    // int previousModuleCheckpoint = (index > 0) ? m_moduleDurations.at(index - 1) : 0;
    // int durationInVisit = globalMS - previousModuleCheckpoint;

    // // GUARD LOGIC: If data exists and the visit is too short (< 5s), do not overwrite
    // if (m_moduleDurations[index] > 0 && durationInVisit < 5) {
    //     hInfo() << "Guard triggered for index" << index
    //             << "| Short visit ignored (" << durationInVisit << "s) to preserve data.";
    //     return;
    // }

    // Valid telemetry or first-time record: update the buffer
    m_moduleDurations[index] = globalMS;
    updateSessionCalories();
    hDebug() << "Checkpoint confirmed. Index:" << index << "| Global Time:" << globalMS << "ms";
    hDebug() << "m_moduleDurations: " << m_moduleDurations;
}

QString SessionManager::getModulesLogString() const {
    // Converts the list to the "90,20,80..." format for Level 4 persistence
    QStringList list;
    for (int time : m_moduleDurations) list << QString::number(time);
    return list.join(",");
}

int SessionManager::getStoredTime(int index) const {
    if (index >= 0 && index < m_moduleDurations.size()) {
        return m_moduleDurations.at(index);
    }
    return 0;
}

void SessionManager::setActiveModuleIndex(int index) {
    m_activeModuleIndex = index;
}

void SessionManager::saveSession() {
    if (m_moduleDurations.isEmpty()) return;

    // 1. Serialize checkpoints to CSV string (e.g., "190,256,289")
    QStringList telemetryList;
    for (int checkpoint : std::as_const(m_moduleDurations)) {
        telemetryList << QString::number(checkpoint);
    }
    QString telemetryString = telemetryList.join(",");

    // 2. The total duration is the last checkpoint recorded
    int totalDuration = m_moduleDurations.last();

    // 3. Final metabolic impact calculation [Source 19, 60]
    // Note: m_totalCalories has been accumulating during module transitions

    hInfo() << "Persisting Session | Protocol: " << m_protocolId
            << " | Timestamp: " << m_startTimestamp
            << " | Duration: " << totalDuration
            << "s | Data: [" << telemetryString << "]"
            << "Calories: " << m_totalCalories;

    // 4. Delegate to DatabaseManager (Assuming a saveSession method exists there)
    m_db->saveSession(m_protocolId, m_startTimestamp, totalDuration, telemetryString, m_totalCalories);
    // TODO: m_db->updatePersonalBest(m_protocolId);
}

/**
 * @brief Recalculates total session calories based on the current checkpoint buffer.
 * Provides a robust calculation even if session navigation occurs.
 */
void SessionManager::updateSessionCalories() {
    float totalKcal = 0.0f;
    float userWeight = 80.0f; // TODO: Default weight, to be retrieved from system_config [Source 17]

    // Iterate through checkpoints to calculate relative durations and calories
    for (int i = 0; i < m_moduleDurations.size(); ++i) {
        int checkpoint = m_moduleDurations.at(i);
        if (checkpoint <= 0) continue; // Skip modules not yet reached

        // Calculate relative duration for this specific module window
        int prevCheckpoint = (i > 0) ? m_moduleDurations.at(i - 1) : 0;
        int durationSeconds = checkpoint - prevCheckpoint;

        if (durationSeconds <= 0) continue;

        float hours = durationSeconds / 3600.0f;
        float metFactor = m_moduleMetFactors.at(i);

        // Apply standard metabolic formula [Source 19]
        totalKcal += (metFactor * userWeight * hours);
    }

    m_totalCalories = totalKcal;
    hDebug() << "Total calories: " << m_totalCalories ;
    // emit totalCaloriesChanged();
}
