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
        hCritical() << "SessionManager initialized without Database Uplink.";
    } else {
        hDebug() << "SessionManager Uplink established.";
        loadUserConfig();
    }

    m_totalCalories = 0.0f;
    m_activeModuleIndex = 0;
    m_sessionId = 0;
}

void SessionManager::startSession(int protocolId,  const QVariantList &executionList) {
    m_protocolId = protocolId;
    m_startTimestamp = QDateTime::currentSecsSinceEpoch();
    m_totalCalories = 0.0f;
    m_activeModuleIndex = 0;
    m_totalMetScore = 0.0;
    m_speed = 0.0;
    m_executionList = executionList;

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
    loadLastSessionData(protocolId);

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

int SessionManager::saveSession() {
    if (m_moduleDurations.isEmpty()) return 0;
    hInfo() << "Saving session";
    // hDebug() << "Execution List: " << m_executionList;

    // Structure to accumulate session-wide performance per module_id
    struct ModulePerformance {
        double firstTR = -1.0;     // Time per rep (seconds) in the first encounter
        double totalSeconds = 0.0; // Cumulative duration across all subsystems
        int totalQuantity = 0;     // Cumulative reps across all subsystems
        int occurrenceCount = 0;
    };
    QMap<QString, ModulePerformance> analysisMap;

    // Analyze and accumulate telemetry data
    for (int i = 0; i < m_moduleDurations.size(); ++i) {
        int currentMs = m_moduleDurations.at(i);
        int prevMs = (i > 0) ? m_moduleDurations.at(i - 1) : 0;
        double actualDurationMs = static_cast<double>(currentMs - prevMs);

        if (actualDurationMs <= 0) continue;

        QVariantMap moduleData = m_executionList.at(i).toMap()["data"].toMap();

        // Filter: Calibrate all modules except based on time (unit_type: 0)
        if (moduleData["unit_type"].toInt() == 0) continue;

        // hDebug() << "moduleData: " << moduleData;
        QString m_name = moduleData["module_name"].toString();
        int qty = moduleData["quantity"].toInt();
        if (qty <= 0) continue;
        double metFactor = moduleData["met_factor"].toDouble();

        // Accumulate Mechanical Volume (MET Score) for all modules
        m_totalMetScore += (metFactor * qty); // WARNING: only valid if (unit_type != 0)


        double currentTR = (actualDurationMs / 1000.0) / qty;

        // Populate analysis data
        if (!analysisMap.contains(m_name)) {
            analysisMap[m_name].firstTR = currentTR;
        }
        analysisMap[m_name].totalSeconds += (actualDurationMs / 1000.0);
        analysisMap[m_name].totalQuantity += qty;
        analysisMap[m_name].occurrenceCount++;
        hDebug() << "Populating module id: " << m_name;
    }

    m_speed= 1.00; // Default if no previous session exists

    if (!m_lastSessionDurations.isEmpty()) {
        int currentTotalMs = m_moduleDurations.last();
        int previousTotalMs = m_lastSessionDurations.last();

        if (currentTotalMs > 0) {
            m_speed= (static_cast<double>(previousTotalMs) / currentTotalMs);
            m_speed = std::round(m_speed * 100.0) / 100.0;
            hDebug() << "m_speed: " << m_speed;
        }
    }

    // Compute final metrics
    for (auto it = analysisMap.begin(); it != analysisMap.end(); ++it) {
        QString m_name = it.key();
        ModulePerformance stats = it.value();

        // Calibration requires at least two data points to establish a fatigue trend
        if (stats.occurrenceCount < 2) continue;

        // Base repetition time (from the 'fresh' first instance)
        double calibratedRepTime = stats.firstTR;

        // Average repetition time across the entire session volume
        double averageTR = stats.totalSeconds / stats.totalQuantity;

        // Fatigue rate is the percentage increase from base to average
        double rawFatigue = averageTR / calibratedRepTime;
        double calibratedFatigue = std::max(0.0, rawFatigue);

        hDebug() << "Module Calibration [Volume Model] | NAME:" << m_name
                 << " | Base RT:" << calibratedRepTime << "s | Avg RT:" << averageTR
                 << "s | Fatigue:" << calibratedFatigue;


        // Call database to update the module blueprint
        if (m_db) {
            m_db->updateModuleData(m_name, calibratedRepTime, calibratedFatigue);
        }
    }

    // Serialize checkpoints to CSV string (e.g., "190,256,289")
    QStringList telemetryList;
    for (int checkpoint : std::as_const(m_moduleDurations)) {
        telemetryList << QString::number(checkpoint);
    }
    QString telemetryString = telemetryList.join(",");

    // The total duration is the last checkpoint recorded
    int totalDuration = m_moduleDurations.last();
    int durationSec = std::round(totalDuration / 1000);

    // Final metabolic impact calculation
    // Note: m_totalCalories has been accumulating during module transitions

    hInfo() << "Persisting Session | Protocol: " << m_protocolId
            << " | Timestamp: " << m_startTimestamp
            << " | Duration: " << totalDuration
            << "s | Data: [" << telemetryString << "]"
            << " | speed: " << m_speed
            << " | metScore: " << m_totalMetScore
            << " | Calories: " << m_totalCalories;

    // Delegate to DatabaseManager
    m_sessionId = m_db->saveSession(m_protocolId, m_startTimestamp, totalDuration, telemetryString, m_totalCalories, m_speed, m_totalMetScore);
    m_db->updateProtocolDuration(m_protocolId, durationSec);

    m_db->updatePersonalBest(m_protocolId, durationSec);

    emit sessionSaved();
    hDebug() << "Session saved";
    return m_sessionId;
}

/**
 * @brief Recalculates total session calories based on the current checkpoint buffer.
 * @meta Provides a robust calculation even if session navigation occurs.
 */
void SessionManager::updateSessionCalories() {
    float totalCalories = 0.0f;
    // Demographic corrector (age and sex), normalized to 30 years
    // TODO: get from Session
    float ageFactor = std::clamp((30.0f - m_userAge) * 0.003f, -0.15f, 0.10f);
    // float sexFactor = m_userIsMale ? 0.05f : -0.05f;
    float sexFactor = ( m_userSex - 1) * 0.05f;
    float corrector = 1.0f + ageFactor + sexFactor;
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
        // Apply standard metabolic formula with demographic corrector
        totalCalories += metFactor * m_userWeight * hours * corrector;
    }
    m_totalCalories = std::round(totalCalories * 100.0) / 100.0;
    hDebug() << "Total calories: " << m_totalCalories;
    // emit totalCaloriesChanged();
}

/**
 * @brief Loads and parses telemetry from the previous session to act as a benchmark.
 * @meta Transforms the comma-separated string into a numeric buffer.
 */
QList<int> SessionManager::loadLastSessionData(int protocolId) {
    m_lastSessionDurations.clear();

    if (!m_db) return m_lastSessionDurations;

    QString rawTelemetry = m_db->getLastSessionTelemetry(protocolId);

    if (rawTelemetry.isEmpty()) {
        hInfo() << "No previous session found for protocol:" << protocolId;
        return m_lastSessionDurations;
    }

    // Parse the CSV string into the numeric buffer [v0.5.2 logic]
    QStringList points = rawTelemetry.split(",");
    for (const QString &point : std::as_const(points)) {
        bool ok;
        int value = point.toInt(&ok);
        if (ok) m_lastSessionDurations.append(value);
    }

    hInfo() << "Loaded" << m_lastSessionDurations.size() << "checkpoints from last session.";
    return m_lastSessionDurations;
}

void SessionManager::loadUserConfig() {
    if (!m_db) return;

    // We use the keys defined in the core//config technical spec
    m_userName = m_db->getConfig("user_name", "");
    m_userWeight = m_db->getConfig("user_weight", "75.0").toFloat();
    m_userHeight = m_db->getConfig("user_height", "175").toInt();
    m_userAge = m_db->getConfig("user_age", "30").toInt();
    m_userSex = m_db->getConfig("user_sex", "1").toInt();
    m_userRank = m_db->getConfig("user_rank", "1").toInt();

    hDebug() << QString("User config loaded -> Name: %1, Age: %2, Weight: %3, Height: %4, Sex: %5, Rank: %6")
                    .arg(m_userName)
                    .arg(m_userAge)
                    .arg(m_userWeight)
                    .arg(m_userHeight)
                    .arg(m_userSex)
                    .arg(m_userSex);

    // Trigger update in case the UI is already listening
    emit userNameChanged();
    emit userWeightChanged();
    emit userHeightChanged();
    emit userAgeChanged();
    emit userSexChanged();
    emit userRankChanged();
}

void SessionManager::setUserName(const QString &name) {
    if (m_userName == name) return;

    m_userName = name;
    if (m_db) {
        m_db->setConfig("user_name", m_userName);
    }

    emit userNameChanged();
}

void SessionManager::setUserWeight(float weight) {
    if (qFuzzyCompare(m_userWeight, weight)) return;

    m_userWeight = weight;
    if (m_db) {
        m_db->setConfig("user_weight", QString::number(weight, 'f', 1));
    }

    emit userWeightChanged();
}

void SessionManager::setUserHeight(int height) {
    if (m_userHeight == height) return;

    m_userHeight = height;
    if (m_db) {
        m_db->setConfig("user_height", QString::number(height));
    }

    emit userHeightChanged();
}

void SessionManager::setUserAge(int age) {
    if (m_userAge == age) return;

    m_userAge = age;
    if (m_db) {
        m_db->setConfig("user_age", QString::number(age));
    }

    emit userAgeChanged();
}

void SessionManager::setUserSex(int sex) {
    if (m_userSex == sex) return;

    m_userSex = sex;
    if (m_db) {
        m_db->setConfig("user_sex", QString::number(m_userSex));
    }

    emit userSexChanged();
}

void SessionManager::setUserRank(int rank) {
    if (m_userRank == rank) return;

    m_userRank = rank;
    if (m_db) {
        m_db->setConfig("user_rank", QString::number(m_userRank));
    }

    emit userRankChanged();
}

void SessionManager::setConfig(const QString &key, const QString &value) {
    if      (key == "userName") {
        setUserName(value);
    }
    else if (key == "userWeight") {
        setUserWeight(value.toFloat());
    }
    else if (key == "userHeight") {
        setUserHeight(value.toInt());
    }
    else if (key == "userAge") {
        setUserAge(value.toInt());
    }
    else if (key == "userSex") {
        setUserSex(value.toInt()); // 0:WOMAN, 1:REPLICANT, 2:MAN
    }
    else if (key == "userRank") {
        setUserRank(value.toInt());
    }
    else {
        hWarning() << "Unknown configuration key received:" << key;
    }
}