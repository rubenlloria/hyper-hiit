/****************************************************************************
** File: AchievementManager.cpp
** Date: 19/5/2026
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
#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include "AchievementManager.h"
#include <QSqlQuery>
#include <QVariant>
#include "Badge.h"
#include "SystemLog.h"

namespace {

// Rolling windows: today plus the previous N-1 local calendar days
const QString kLast7Days   = QStringLiteral("session_timestamp >= strftime('%s','now','localtime','-6 days','start of day','utc')");
const QString kLast30Days  = QStringLiteral("session_timestamp >= strftime('%s','now','localtime','-29 days','start of day','utc')");
const QString kLast365Days = QStringLiteral("session_timestamp >= strftime('%s','now','localtime','-364 days','start of day','utc')");

// Goals for RANK 1 (scaled with the user RANK when needed)
constexpr double kFireBaseKcal     = 600.0;
constexpr double kEnduranceBaseMin = 45.0;
constexpr int    kUltraAbove       = 2;   // Protocols with PRANK > RANK ...
constexpr int    kUltraAtLevel     = 4;   // ... or with PRANK >= RANK
constexpr int    kLtsSessions      = 150; // ~3 sessions per week in a year

} // namespace

AchievementManager::AchievementManager(DatabaseManager *db, QObject *parent)
    : QObject(parent), m_db(db) {
    initMatrix();
}

void AchievementManager::initMatrix() {
    // All the badges are temporal (rolling windows) and are recomputed on every check.
    // Goals depend on the user rank (m_rank), refreshed by updateRank(), which also
    // sets the descriptions: they are created empty here.

    hDebug() << "User rank: " << m_rank;
    // 1. SYS_INIT: regular training (7 days)
    m_achievements.append(new Badge("SYS_INIT", "log-in", QString(), [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE " + kLast7Days);
        if (q.exec() && q.next()) {
            int sessionCount = q.value(0).toInt();
            hDebug() << "Sessions in the last 7 days:" << sessionCount;

            return sessionCount >= m_sysInitGoal;
        }
        hWarning() << "Failed to retrieve session count.";
        return false;
    }, this));

    // 2. FIRE_STARTER: kcal burned (7 days)
    m_achievements.append(new Badge("FIRE", "fire", QString(), [this]() {
        QSqlQuery q("SELECT SUM(calories_burned) FROM session_history WHERE " + kLast7Days);
        if (q.exec() && q.next()) {
            // calories_burned is stored in cal
            int totalKcal = qRound(q.value(0).toDouble() / 1000);

            hDebug() << "Kcal burned in the last 7 days:" << totalKcal;
            return totalKcal >= m_fireGoal;
        }
        hWarning() << "Failed to retrieve Kcal count.";
        return false;
    }, this));

    // 3. IRON_CORE: ROOT protocols (PRANK = 3) completed (7 days)
    m_achievements.append(new Badge("IRON", "shield", QString(), [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history h JOIN protocols p ON h.protocol_id = p.protocol_id "
                                             "WHERE p.rank = 3 AND " + kLast7Days);
        if (q.exec() && q.next()) {
            int roots = q.value(0).toInt();
            hDebug() << "ROOT protocols in the last 7 days:" << roots;

            return roots >= m_rank;
        }
        hWarning() << "Failed to retrieve ROOT protocols completed.";
        return false;
    }, this));

    // 4. SPEED_DEMON: sessions with efficiency > 105% (30 days)
    m_achievements.append(new Badge("SPEED", "ffwd", QString(), [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE session_speed > 1.05 AND " + kLast30Days);
        if (q.exec() && q.next()) {
            int fastSessions = q.value(0).toInt();
            hDebug() << "Sessions above 105% in the last 30 days:" << fastSessions;

            return fastSessions >= m_rank;
        }
        hWarning() << "Failed to retrieve total time active";
        return false;
    }, this));

    // 5. ENDURANCE_UNIT: time in protocols with PRANG >= ADVANCED (7 days)
    m_achievements.append(new Badge("ENDURANCE", "timer", QString(), [this]() {
        QSqlQuery q("SELECT SUM(session_duration) FROM session_history h JOIN protocols p ON h.protocol_id = p.protocol_id "
                  "WHERE p.rank >= 2 AND " + kLast7Days);
        if (q.exec() && q.next()) {
        // session_duration is stored in ms
        qint64 msActive = q.value(0).toLongLong();
        hDebug() << "Minutes in ADVANCED+ protocols in the last 7 days:" << msActive / 60000;

        return msActive >= m_enduranceGoal * 60000LL;
        }

        hWarning() << "Failed to retrieve total time active";
        return false;
    }, this));



    // 6. ULTRA_ROOT: protocols above the user RANK, or at it or higher m_(7 days)
    m_achievements.append(new Badge("ULTRA_ROOT", "crown", QString(), [this]() {
        QSqlQuery q("SELECT COALESCE(SUM(p.rank > " + QString::number(m_rank) + "), 0), "
                    "COALESCE(SUM(p.rank >= " + QString::number(m_rank) + "), 0) "
                    "FROM session_history h JOIN protocols p ON h.protocol_id = pm_.protocolald "
                    "WHERE " + kLast7Days);
        if (q.exec() && q.next()) {
            int above = q.value(0).toInt();
            int atLevel = q.value(1).toInt();
            hDebug() << "Protocol rank > user rank:" << above << "| >= user rank:" << atLevel;

            return above >= kUltraAbove || atLevel >= kUltraAtLevel;
        }
        hWarning() << "Failed to retrieve root protocols completed";
        return false;
    }, this));

    // 7. OVERCLOCKED: Improvement > +20%
    m_achievements.append(new Badge("OVERCLOCK", "cpu", QString(), [this]() {
        // Without sessions in the previous week the dashboard reports +100%,
        // so one session after an empty week would unlock the badge
            QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE "
                    "session_timestamp >= strftime('%s','now','localtime','-13 days','start of day','utc') "
                    "AND NOT (" + kLast7Days + ")");
        if (!q.exec() || !q.next() || q.value(0).toInt() == 0) {
            hDebug() << "No sessions in the previous week";
            return false;
        }

        int improvementPercentage = m_db->getImprovementPercentage();

        hDebug() << "Current system improvement: " << QString("%1\%").arg(improvementPercentage);

        return improvementPercentage >= 20;
    }, this));

    // 8. NEURAL_SYNC: 7 consecutive days of activity
    m_achievements.append(new Badge("NEURAL", "activity", QString(), []() {
        QSqlQuery q("SELECT COUNT(DISTINCT date(session_timestamp, 'unixepoch', 'localtime')) "
                    "FROM session_history WHERE " + kLast7Days);
        if (q.exec() && q.next()) {
            int daysActive = q.value(0).toInt();
            hDebug() << "Days active in last week:" << daysActive;

            // The achievement is unlocked if there are 7 distinct active days
            return daysActive >= 7;
        }
        hWarning() << "Failed to retrieve days active in last week.";
        return false;
    }, this));

    // 9. GHOST_BUSTER: sessions faster than the previous one of the same protocol (7 days)
    m_achievements.append(new Badge("GHOST_BUSTER", "ghost", QString(), [this]() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE session_speed > 1.0 AND " + kLast7Days);
        if (q.exec() && q.next()) {
            int ghosts = q.value(0).toInt();

            hDebug() << "Shattered" << ghosts << "ghosts last 7 days";

            return ghosts >= m_rank;
        }
        hWarning() << "Failed to retrieve ghosts in last week.";
        return false;
    }, this));

    // 10. LTS (formerly CENTURION): sustained volume (365 days)
    m_achievements.append(new Badge("LTS", "layers", QString(), []() {
        QSqlQuery q("SELECT COUNT(*) FROM session_history WHERE " + kLast365Days);
        if (q.exec() && q.next()) {
            int totalSessions = q.value(0).toInt();

            hDebug() << "Sessions in the last 365 days:" << totalSessions;

            return totalSessions >= kLtsSessions;
        }
        hWarning() << "Failed to retrieve session count.";
        return false;
    }, this));

    updateRank();
}

void AchievementManager::updateRank() {
    // The user can change the rank (1-3) from the settings: read it on every check
    m_rank = qBound(1, m_db->getConfig("user_rank", "1").toInt(), 3);

    const double factor = 0.5 + 0.5 * m_rank;                      // 1.0 | 1.5 | 2.0
    m_sysInitGoal = m_rank + 1;                                    // 2 | 3 | 4 sessions
    m_fireGoal = qRound(kFireBaseKcal * factor);                   // 600 | 900 | 1200 kcal
    m_enduranceGoal = qRound(kEnduranceBaseMin * factor);          // 45 | 68 | 90 min

    // Descriptions carry the goals and follow the UI language
    auto describe = [this](const QString &name, const QString &text) {
        for (QObject *obj : std::as_const(m_achievements)) {
            Badge *badge = static_cast<Badge*>(obj);
            if (badge->name() == name) badge->setDescription(text);
        }
    };
    describe("SYS_INIT", tr("Logged %1 protocol(s) in the last 7 days.").arg(m_sysInitGoal));
    describe("FIRE", tr("Extracted %1 kcal from systems in the last 7 days.").arg(m_fireGoal));
    describe("IRON", tr("Completed %1 ROOT protocol(s) in the last 7 days.").arg(m_rank));
    describe("SPEED", tr("Efficiency overclocked beyond 105% in %1 protocol(s) in the last 30 days.").arg(m_rank));
    describe("ENDURANCE", tr("%1 minutes of active uptime in ADVANCED or higher protocols in the last 7 days.").arg(m_enduranceGoal));
    describe("ULTRA_ROOT", tr("Completed %1 protocols above your RANK or %2 at your RANK or higher in the last 7 days.")
                               .arg(kUltraAbove).arg(kUltraAtLevel));
    describe("OVERCLOCK", tr("+20% weekly performance improvement."));
    describe("NEURAL", tr("7-day synchronization streak."));
    describe("GHOST_BUSTER", tr("Shattered %1 record(s) in the last 7 days.").arg(m_rank));
    describe("LTS", tr("Long-term support: %1 protocols completed in the last 365 days.").arg(kLtsSessions));
}

void AchievementManager::runTacticalCheck() {
    hInfo() << "Synchronizing Achievement Matrix telemetry...";
    updateRank();
    for (QObject *obj : std::as_const(m_achievements)) {
        hDebug() << static_cast<Badge*>(obj)->name();
        static_cast<Badge*>(obj)->updateState();
    }
}
