/****************************************************************************
** File: AchievementManager.cpp
** Date: 19/5/2026
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
#include "AchievementManager.h"
#include <QSqlQuery>
#include <QVariant>
#include "Badge.h"
#include "SystemLog.h"

AchievementManager::AchievementManager(DatabaseManager *db, QObject *parent)
    : QObject(parent), m_db(db) {
    initMatrix();
}

void AchievementManager::initMatrix() {
    // 1. NEURAL_SYNC: 7 consecutive days of activity
    m_achievements.append(new Badge("NEURAL_SYNC", "activity", "7-day synchronization streak.", [this]() {
        QSqlQuery q("SELECT COUNT(DISTINCT date(session_timestamp, 'unixepoch', 'localtime')) "
                    "FROM session_history WHERE session_timestamp >= strftime('%s','now','-7 days')");
        return (q.exec() && q.next()) ? q.value(0).toInt() >= 7 : false;
    }, this));

    // 2. FIRE_STARTER: > 5,000 kcal total [Source 196]
    m_achievements.append(new Badge("FIRE_STARTER", "flame", "Extracted 5,000 kcal from systems.", [this]() {
        QSqlQuery q("SELECT SUM(calories_burned) FROM session_history");
        return (q.exec() && q.next()) ? q.value(0).toDouble() >= 5000.0 : false;
    }, this));

    // 3. IRON_CORE: First ROOT rank protocol
    m_achievements.append(new Badge("IRON_CORE", "shield", "Root level authorization achieved.", [this]() {
        QSqlQuery q("SELECT 1 FROM session_history h JOIN protocols p ON h.protocol_id = p.protocol_id "
                    "WHERE p.rank = 3 LIMIT 1");
        return (q.exec() && q.next());
    }, this));

    // 4. SPEED_DEMON: Efficiency > 105%
    m_achievements.append(new Badge("SPEED_DEMON", "zap", "Efficiency overclocked beyond 105%.", [this]() {
        QSqlQuery q("SELECT 1 FROM session_history WHERE session_speed > 1.05 LIMIT 1");
        return (q.exec() && q.next());
    }, this));

    // 5. ENDURANCE_UNIT: > 10 hours total activity
    m_achievements.append(new Badge("ENDURANCE_UNIT", "timer", "10 hours of active mission uptime.", [this]() {
        QSqlQuery q("SELECT SUM(session_duration) FROM session_history");
        return (q.exec() && q.next()) ? q.value(0).toLongLong() >= 36000000 : false;
    }, this));

    // 6. ULTRA_ROOT: ROOT protocol in every directive
    m_achievements.append(new Badge("ULTRA_ROOT", "crown", "Dominated ROOT rank in every directive.", [this]() {
        QSqlQuery q("SELECT COUNT(DISTINCT dir_id) FROM directives_protocols dp "
                    "JOIN session_history h ON dp.protocol_id = h.protocol_id "
                    "JOIN protocols p ON h.protocol_id = p.protocol_id "
                    "WHERE p.rank = 3");
        return (q.exec() && q.next()) ? q.value(0).toInt() >= 5 : false;
    }, this));

    // 7. OVERCLOCKED: Improvement > +20% [Source 189]
    m_achievements.append(new Badge("OVERCLOCKED", "cpu", "+20% weekly performance improvement.", [this]() {
        return m_db->getImprovementPercentage() >= 20;
    }, this));

    // 8. SYSTEM_INITIATE: First mission finalized
    m_achievements.append(new Badge("SYSTEM_INITIATE", "log-in", "First terminal mission entry logged.", [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history");
        return (q.exec() && q.next()) ? q.value(0).toInt() >= 1 : false;
    }, this));

    // 9. GHOST_BUSTER: 5 Personal Bests in 7 days
    m_achievements.append(new Badge("GHOST_BUSTER", "ghost", "Shattered 5 records in a single week.", [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE session_speed > 1.0 "
                    "AND session_timestamp >= strftime('%s','now','-7 days')");
        return (q.exec() && q.next()) ? q.value(0).toInt() >= 5 : false;
    }, this));

    // 10. CENTURION_LOG: 100 missions completed
    m_achievements.append(new Badge("CENTURION_LOG", "layers", "100 combat logs successfully stored.", [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history");
        return (q.exec() && q.next()) ? q.value(0).toInt() >= 100 : false;
    }, this));
}

void AchievementManager::runTacticalCheck() {
    hInfo() << "Synchronizing Achievement Matrix telemetry...";
    for (QObject *obj : std::as_const(m_achievements)) {
        static_cast<Badge*>(obj)->updateState();
    }
}
