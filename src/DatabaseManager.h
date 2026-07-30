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
// #include "src/SystemManager.h"
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

#define DB_SCHEMA_VERSION 4
#define MIN_JSON_VERSION 0.5

class DatabaseManager : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    explicit DatabaseManager(QObject *parent = nullptr);

    Q_INVOKABLE bool restoreDatabase();
    bool initDatabase();
    bool seedDatabase();
    // Module methods
    Q_INVOKABLE QList<Module> getAllModules();

    // Directive methods
    Q_INVOKABLE QList<Directive> getAllDirectives();
    Q_INVOKABLE int getActiveDirectiveId();
    Q_INVOKABLE void setActiveDirectiveId(int dirId);

    // Protocol methods
    /**
     * @brief Retrieves the full Protocol Matrix from the SQL registry.
     * @return QList of all registered Protocol objects.
     */
    QList<Protocol> getAllProtocols();

    /**
     * @brief Fetches protocols linked to a specific directive.
     * @param dirId The ID of the directive. Use 0 to retrieve ORPHAN protocols.
     * @return QList of Protocol objects matching the filter.
     */
    QList<Protocol> getProtocolsByDirective(int dirId);
    Q_INVOKABLE QVariantList getProtocolStructure(int protocolId, bool useFullAbbreviation = false);
    Q_INVOKABLE QVariantList getProtocolExecutionDetails(int protocolId);
    int setProtocolMaxDuration();
    int saveSession(int protocolId, qint64 timestamp, int totalSecs, const QString &modulesLog, double calories, double speed, double met_score);
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
     *
     * @return the delta percentage (e.g., +5 if efficiency rose from 100% to 105%).
     */
    Q_INVOKABLE int getEfficiency();


    /**
     * @brief Retrieves the average calories burned per day over the last 7 days.
     *
     * @return double kcal (e.g., 513 or 826)
     */
    Q_INVOKABLE int getAverageDailyCalories(int startDay, int windowSize);


    /**
     * @brief Retrieves the average number of sessions completed per day over the last 7 days.
     *
     * @return double  (e.g., 0.9 or 1.2)
     */
    Q_INVOKABLE double getAverageDailySessions(int startDay, int windowSize);


    /**
     * @brief Retrieves the aggregated totals for each unique module performed in a session.
     *
     * Groups by module and unit type to sum up the total volume (e.g., 150x Burpees).
     *
     * @param sessionId The ID of the session to analyze.
     * @return A QVariantList of maps with "name", "quantity", and "unit".
     */
    Q_INVOKABLE QVariantList getSessionTotals(int sessionId);


    /**
     * @brief Retrieves a detailed analysis of a session grouped by subsystems.
     *
     * Computes individual module durations and deltas against the "ghost" session.
     *
     * @param historyId The unique ID of the session record.
     * @return A nested QVariantList for the UI Repeaters.
     */
    Q_INVOKABLE QVariantList getSessionDetailedAnalysis(int historyId);


    /**
     * @brief Retrieves the core metrics for the session summary cards.
     *
     * Aggregates rank, volume, duration, and performance deltas (Improvement/Efficiency).
     *
     * @param historyId The unique ID of the saved session.
     * @return A QVariantMap containing the 6 primary metrics.
     */
    Q_INVOKABLE QVariantMap getSessionSummaryMetrics(int historyId);


    /**
     * @brief Evaluates and updates the personal best time for a protocol.
     *
     * Only overwrites the personal_best field if the new duration is lower
     * than the existing record or if no record exists (zero).
     *
     * @param protocolId The unique identifier of the protocol.
     * @param duration The total duration of the completed session in milliseconds.
     */
    void updatePersonalBest(int protocolId, int duration);

    /**
     * @brief Retrieves a persistent configuration value from the system_config table.
     * @param key The unique identifier for the setting.
     * @param defaultValue Value to return if the key is not found.
     * @return The stored value as a string.
     */
    Q_INVOKABLE QString getConfig(const QString &key, const QString &defaultValue = "");

    /**
     * @brief Persists a configuration value using an atomic insert or replace operation.
     * @param key The unique identifier for the setting.
     * @param value The value to be stored.
     */
    Q_INVOKABLE void setConfig(const QString &key, const QString &value);

    /**
     * @brief Saves a directive to SQL. Receives a QVariantMap from QML for 'Neural Sync'.
     * @param id The model object from the QML delegate.
     * @param id The final database ID (assigned if it was a new draft).
     * @param name Updated name string.
     * @param description Updated description string.
     * @param icon Updated icon glyph code.
     * @param color Updated hex color string.
     * @return The final dir_id assigned by the database.
     */
    Q_INVOKABLE int saveDirective(int id, const QString &name, const QString &description, const QString &icon, const QString &color);

    /**
     * @brief Saves a mission protocol to the database.
     * @param id The protocol unique identifier (-1 for new entries).
     * @param name The mission objective name.
     * @param rank Level of access required (1: NEWBIE, 2: ADVANCED, 3: ROOT).
     * @param directiveId The parent directive to link the protocol to.
     * @return The operational protocol_id, or -1 on failure.
     */
    Q_INVOKABLE int saveProtocol(int id, const QString &name, int rank, const QList<int> &directiveIds);

    /**
     * @brief Save module data using a data shard map.
     * @param moduleData metadata map
     */
    Q_INVOKABLE int saveModule(const QVariantMap &moduleData);

    /**
     * @brief Removes a module record from the master library.
     * @param moduleId The unique database identifier of the module to be removed.
     * @return true if the deletion was successful, false otherwise.
     */
    Q_INVOKABLE bool deleteModule(int moduleId);

    /**
     * Removes a directive from the core registry after integrity verification.
     * @param directiveId The unique identifier of the directive.
     * @return true if successfully removed, false if linked to protocols.
     */
    Q_INVOKABLE bool deleteDirective(int directiveId);

    /**
     * @brief Persists the visual timeline structure to the database mapping table.
     * @param protocolId Target protocol identifier.
     * @param structure List of subsystems containing nested module data.
     * @return True if the synchronization transaction completes successfully.
     */
    Q_INVOKABLE bool saveProtocolStructure(int protocolId, const QVariantList &structure);

    /**
     * @brief Checks if a protocol has associated session history.
     * @param protocolId The ID to verify.
     * @return True if sessions exist in session_history.
     */
    Q_INVOKABLE bool hasProtocolHistory(int protocolId);

    /**
     * @brief Deletes all telemetry and session logs for a specific protocol.
     * @param protocolId Target identifier.
     * @return True if the deletion transaction is successful.
     */
    Q_INVOKABLE bool clearProtocolHistory(int protocolId);

    /**
     * Purges a protocol, its structure, and all associated session history.
     * @param protocolId The unique identifier of the protocol to delete.
     * @return true if the full purge sequence was successful.
     */
    Q_INVOKABLE bool deleteProtocol(int protocolId);

    /**
     * @brief Retrieves the list of directive IDs associated with a protocol.
     * Essential for mapping protocols to multiple directives.
     * @param protocolId The ID of the protocol to query.
     * @return QList of directive IDs.
     */
    Q_INVOKABLE QList<int> getDirectiveList(int protocolId);

    /**
     * @brief Persists the directive mapping for a specific protocol.
     * Performs a purge-and-relink operation to ensure data integrity.
     * @param protocolId The ID of the protocol to update.
     * @param directiveIds List of directive IDs to be associated.
     * @return True if the synchronization was successful.
     */
    Q_INVOKABLE bool setDirectiveList(int protocolId, const QList<int> &directiveIds);

    /**
     * @brief public method to close database
    */
    void closeDatabase();

private:
    QSqlDatabase m_db;
    int m_dbSchema = 0;
    const QMap<QString, int> m_unitMap = {
        {"seconds", 0},
        {"reps",    1},
        {"breaths", 2},
        {"meters", 3}
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

    /**
 * @brief Resolves a protocol ID by its unique name using a direct database query.
 * @param name: Name of protocol to find.
 * @return <int> id of protocol
 */
    int getProtocolIdByName(const QString &name);

    /**
 * @brief Executes incremental schema updates based on the current user_version.
 * @param oldVersion The version detected in the database file.
 */
    void runMigrations(int oldVersion);

    /**
 * @brief Formats a duration in milliseconds to a readable mm:ss string.
 *
 * @param ms duration in milliseconds
 * @return a readable String in format mm:ss h.
 */
    QString formatDuration(int ms);


};

#endif
