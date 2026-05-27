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
#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

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
    // 1. SYSTEM_INITIATE: First mission finalized
    m_achievements.append(new Badge("SYS_INIT", "log-in", "First terminal mission entry logged.", [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history");
        if (q.exec() && q.next()) {
            int sessionCount = q.value(0).toInt();
            qDebug() << "[DEBUG]: Badge Info:" << "Total count of Sessions completed:" << sessionCount;

            return sessionCount >= 1;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve session count.";
        return false;
    }, this));

    // 2. FIRE_STARTER: > 5,000 kcal total [Source 196]
    m_achievements.append(new Badge("FIRE", "fire", "Extracted 5,000 kcal from systems.", [this]() {
        QSqlQuery q("SELECT SUM(calories_burned) FROM session_history");
        if (q.exec() && q.next()) {
            int totalKcal = round(q.value(0).toDouble() / 1000);

            qDebug() << "[DEBUG]: Badge Info:" << "Total count of Kcal burned:" << totalKcal;
            return totalKcal >= 5000.0;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve Kcal count.";
        return false;
    }, this));

    // 3. IRON_CORE: First ROOT rank protocol
    m_achievements.append(new Badge("IRON", "shield", "Root level authorization achieved.", [this]() {
        QSqlQuery q("SELECT 1 FROM session_history h JOIN protocols p ON h.protocol_id = p.protocol_id "
                    "WHERE p.rank = 3 LIMIT 1");
        if (q.exec() && q.next()) {
            qDebug() << "[DEBUG]: Badge Info:" << "ROOT level reached";
            return true;
        }
        qDebug() << "[DEBUG]: Badge Info:" << "ROOT level NOT reached";
        return false;
    }, this));

    // 4. SPEED_DEMON: Efficiency > 105%
    m_achievements.append(new Badge("SPEED", "ffwd", "Efficiency overclocked beyond 105%.", [this]() {
        QSqlQuery q("SELECT MAX(session_speed) FROM session_history");
        if (q.exec() && q.next()) {
            double maxSpeedReached = q.value(0).toDouble();

            // Technical Log: tracking the highest speed recorded in the system
            qDebug() << "[DEBUG]: Badge Info:" << "Peak session speed found:" << maxSpeedReached * 100;

            // Logic comparison performed in C++ level instead of SQL level
            // Threshold: 1.05 represents 105% efficiency against previous Personal Best
            return maxSpeedReached > 1.05;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve max speed";
        return false;
    }, this));

    // 5. ENDURANCE_UNIT: > 10 hours total activity
    m_achievements.append(new Badge("ENDURANCE", "timer", "10 hours of active mission uptime.", [this]() {
        QSqlQuery q("SELECT SUM(session_duration) FROM session_history");
        if (q.exec() && q.next()) {
            long hoursActive = q.value(0).toLongLong();
            qDebug() << "[DEBUG]: Badge Info:" << "Hours active: " << round(hoursActive / (1000 * 60 * 60)) << "h.";

            return hoursActive >= 36000000;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve total hours active";
        return false;
    }, this));

    // 6. ULTRA_ROOT: ROOT protocol in every directive
    m_achievements.append(new Badge("ULTRA_ROOT", "crown", "Dominated ROOT rank in every directive.", [this]() {
        // Get the total count of directives currently in the system
        QSqlQuery qTotal("SELECT COUNT(*) FROM directives");
        int totalDirectives = 0;
        if (qTotal.exec() && qTotal.next()) {
            totalDirectives = qTotal.value(0).toInt();
        }

        // Safety check: if no directives exist, achievement cannot be unlocked
        if (totalDirectives <= 0) return false;

        // Count how many distinct directives have at least one COMPLETED ROOT protocol
        QSqlQuery qCompleted;
        qCompleted.prepare("SELECT COUNT(DISTINCT dp.dir_id) FROM directives_protocols dp "
                           "JOIN session_history h ON dp.protocol_id = h.protocol_id "
                           "JOIN protocols p ON h.protocol_id = p.protocol_id "
                           "WHERE p.rank = 3");

        if (qCompleted.exec() && qCompleted.next()) {
            int completedRootDirectives = qCompleted.value(0).toInt();

            // Tactical Log: Monitoring progression towards total domination
            qDebug() << "[DEBUG]: Badge Info:" << "Completed" << completedRootDirectives << "of" << totalDirectives << " ROOT protocols from diferent directives";

            // Achievement is unlocked only if progress matches or exceeds total directives
            return completedRootDirectives >= totalDirectives;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve root protocols completed";
        return false;
    }, this));

    // 7. OVERCLOCKED: Improvement > +20% [Source 189]
    m_achievements.append(new Badge("OVERCLOCK", "cpu", "+20% weekly performance improvement.", [this]() {
        int improvementPercentage = m_db->getImprovementPercentage();

        qDebug() << "[DEBUG]: Badge Info:" << "Current system improvement: " << QString("%1\%").arg(improvementPercentage);

        return improvementPercentage >= 20;
    }, this));

    // 8. NEURAL_SYNC: 7 consecutive days of activity
    m_achievements.append(new Badge("NEURAL", "activity", "7-day synchronization streak.", [this]() {
        QSqlQuery q("SELECT COUNT(DISTINCT date(session_timestamp, 'unixepoch', 'localtime')) "
                    "FROM session_history WHERE session_timestamp >= strftime('%s','now','-7 days')");
        if (q.exec() && q.next()) {
            int daysActive = q.value(0).toInt();
            qDebug() << "[DEBUG]: Badge Info:" << "Days active in last week:" << daysActive;

            // The achievement is unlocked if there are 7 distinct active days
            return daysActive >= 7;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve days active in last week.";
        return false;
    }, this));

    // 9. GHOST_BUSTER: 5 Personal Bests in 7 days
    m_achievements.append(new Badge("GHOST_BUSTER", "ghost", "Shattered 5 records in a single week.", [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE session_speed > 1.0 "
                    "AND session_timestamp >= strftime('%s','now','-7 days')");
        if (q.exec() && q.next()) {
            int ghosts = q.value(0).toInt();

            qDebug() << "[DEBUG]: Badge Info:" << "Shattered" << ghosts << "ghosts last 7 days";

            return  ghosts >= 5;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve ghosts in last week.";
        return false;
    }, this));

    // 10. CENTURION_LOG: 100 missions completed
    m_achievements.append(new Badge("CENTURION", "layers", "100 combat logs successfully stored.", [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history");
        if (q.exec() && q.next()) {
            int totalSessions = q.value(0).toInt();

            qDebug() << "[DEBUG]: Badge Info:" << "Total count of Sessions completed:" << totalSessions;

            return totalSessions >= 100;
        }
        qWarning() << "[WARNING]: Badge Info:" << "Failed to retrieve session count.";
        return false;
    }, this));
}

void AchievementManager::runTacticalCheck() {
    hInfo() << "Synchronizing Achievement Matrix telemetry...";
    for (QObject *obj : std::as_const(m_achievements)) {
        hInfo() << static_cast<Badge*>(obj)->name();
        static_cast<Badge*>(obj)->updateState();
    }
}
