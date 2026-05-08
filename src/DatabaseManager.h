/****************************************************************************
** File: DatabaseManager.h
** Date: 18/2/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
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
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/

#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include "src/DirectiveModel.h"
#include "src/ModuleModel.h"
#include "src/ProtocolModel.h"
#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QSqlError>
#include <QSqlQuery>
#include <QMultiMap>

#define DB_SCHEMA_VERSION 1

class DatabaseManager : public QObject {
    Q_OBJECT
    QML_ELEMENT  // WARNING: delete if not compile in the future
public:
    explicit DatabaseManager(QObject *parent = nullptr);

    Q_INVOKABLE bool restoreDatabase();
    bool initDatabase();
    bool seedDatabase();
    // Module methods
    QList<Module> getAllModules();

    // Directive methods
    QList<Directive> getAllDirectives();
    Q_INVOKABLE int getActiveDirectiveId();
    Q_INVOKABLE void setActiveDirectiveId(int dirId);

    // Protocol methods
    QList<Protocol> getAllProtocols();
    QList<Protocol> getProtocolsByDirective(int dirId);
    Q_INVOKABLE QVariantList getProtocolStructure(int protocolId);
    Q_INVOKABLE QVariantList getProtocolExecutionDetails(int protocolId);
    int setProtocolMaxDuration();
    bool saveSession(int protocolId, qint64 timestamp, int totalSecs, const QString &modulesLog, float calories, double speed, double met_score);
    void updateModuleData(const QString &name, double repTime, double fatigueRate);
    void updateProtocolDuration(int protocol_id, int duration);
    QString getLastSessionTelemetry(int protocolId);
    Q_INVOKABLE QVariantMap getRankLabels();

    // Session Methods
    Q_INVOKABLE QVariantList getWeeklyCalorieHistory(int startDay, int windowSize);
    /**
 * @brief Calculates the final IMPROVEMENT percentage comparing Segment A vs Segment B.
 * @return integer (e.g., 23 for +23% or -5 for -5%).
 */
    Q_INVOKABLE int getImprovementPercentage();

    /**
 * @brief Calculates the EFFICIENCY trend comparing Segment A vs Segment B.
 * @return the delta percentage (e.g., +5 if efficiency rose from 100% to 105%).
 */
    Q_INVOKABLE int getEfficiency();

    /**
 * @brief Retrieves the average calories burned per day over the last 7 days.
 * @return double kcal (e.g., 513 or 826)
 */
    Q_INVOKABLE int getAverageDailyCalories(int startDay, int windowSize);

    /**
 * @brief Retrieves the average number of sessions completed per day over the last 7 days.
 * @return double  (e.g., 0.9 or 1.2)
 */
    Q_INVOKABLE double getAverageDailySessions(int startDay, int windowSize);


    // QMultiMap<int, int> getDirectiveProtocolMapping(); // TODO: DELETEME

    // bool restoreDatabase();

private:
    QSqlDatabase m_db;
    int m_dbSchema = 0;
    const QMap<QString, int> m_unitMap = {
        {"seconds", 0},
        {"reps",    1},
        {"breaths", 2}
    };
    QMap<QString, int> nameToModuleId;
    QMap<QString, int> nameToDirectiveId;
    QMap<QString, int> nameToProtocolId;
    bool createTables();
    int insertModule(const QString &name, int difficulty, const QString &target, const QString &desc, const QString &instruction,
                     const QString &safety,
                     // const QString &equipment,
                     int unit, float met, float f_rate, float rep_time);
    int insertDirective(const QString &name, const QString &desc, const QString &icon, const QString &color);
    int insertProtocol(const QString &name, int duration, int modules, int rank, int pb);
    int insertRank(int rank_id, const QString &rank_name);
    int resolveUnitType(const QJsonValue &unitValue);
    void linkProtocol(int protocolId, const QJsonArray &targetDirectives);
    void seedProtocolStructure(int protocolId, const QJsonArray &structureArr);

    /**
 * @brief Internal helper to retrieve the Power Index for a specific time window.
 * @param startDay: Days offset from now (0 for today).
 * @param windowSize: Number of days to include in the sum.
 */
    double getPowerScore(int startDay, int windowSize);

    /**
 * @brief Retrieves the average efficiency (based on speed_index) for a given window.
 * @param startDay: Days offset from now (0 for today).
 * @param windowSize: Number of days to include in the sum.
 * @return a percentage (e.g., 105 for 105% efficiency).
 */
    int getAverageEfficiency(int startDay, int windowSize);

};

#endif
