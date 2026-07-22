/****************************************************************************
** File: DatabaseManager.cpp
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

#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include <QFile>
#include "DatabaseManager.h"
#include "SystemManager.h"
#include "SystemLog.h"

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {}

bool DatabaseManager::initDatabase() {
    // Locate the writable storage for the database file [1]
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);

    QString dbPath = path + "/hyperhiit_core.db";
    hDebug() << "database on '" << dbPath << "'.";
    // QFile::remove(dbPath); // TODO DELETEME
    bool firstRun = !QFile::exists(dbPath);

    if (QSqlDatabase::contains(QSqlDatabase::defaultConnection)) {
        m_db = QSqlDatabase::database();
    } else {
        m_db = QSqlDatabase::addDatabase("QSQLITE");
    }
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        hCritical() << "Failed to establish db connection.";
        return false;
    }

    if (firstRun) {
        hDebug() << "First run detected. Creating default database grid...";
        if (!createTables()) return false;
        if (!seedDatabase()) return false;
    }

    QSqlQuery query("PRAGMA user_version;");
    if (query.next()) {
        m_dbSchema = query.value(0).toInt();
        query.finish();
        query.clear();
        hInfo() << "Current database file schema version:" << m_dbSchema;
    } else {
        hCritical() << "Could not retrieve schema version.";
    }

    if (m_dbSchema > DB_SCHEMA_VERSION) {
        hCritical() << "Database file is newer than this application version!";
    } else if (m_dbSchema < DB_SCHEMA_VERSION) {
        hWarning() << "Older schema version detected (" << m_dbSchema << "). Migrating...";
        runMigrations(m_dbSchema);
    }

    hInfo() << "Database system online.";
    return true;
}

bool DatabaseManager::createTables() {
    QSqlQuery q;

    hInfo() << "Creating tables";

     // System Configuration Table.
    QString createConfig =
        "CREATE TABLE IF NOT EXISTS system_config ("
            "config_key TEXT PRIMARY KEY,"
            "config_value TEXT"
            ");";
    if (!q.exec(createConfig)) {
        hCritical() << "Failed to create config "
                       "table:" << q.lastError().text();
        return false;
    }

    // 1. Modules table
    QString createModules =
       "CREATE TABLE IF NOT EXISTS modules ("
            "module_id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "mod_name VARCHAR(100) UNIQUE NOT NULL,"
            "target_zone VARCHAR(50),"      // Target area (e.g., FULL BODY)
            "difficulty INT,"                // 1: Begginer | 2: Intermediate | 3: Advanced
            "mod_description TEXT,"
            "mod_instructions TEXT,"
            "mod_safety TEXT,"
            "mod_equipment TEXT,"
            "unit_type INTEGER NOT NULL,"   // 0: SECONDS | 1: REPS | 2: BREATHS
            "rep_time FLOAT,"
            "met_factor FLOAT,"             // Efficiency constant
            "fatigue_rate FLOAT"            // Performance tier 1
            ");";
    if (!q.exec(createModules)) {
        hCritical() << "Failed to create modules "
                    "table:" << q.lastError().text();
        return false;
    }

    // 2. Directives table
    QString createDirectives =
        "CREATE TABLE IF NOT EXISTS directives ("
            "dir_id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "dir_name TEXT NOT NULL, "
            "dir_description TEXT, "
            "dir_icon TEXT, "
            "dir_color TEXT"
            ");";
    if (!q.exec(createDirectives)) {
        hCritical() << "Failed to create directives table:" << q.lastError().text();
        return false;
    }

    // 3. Protocols table: linked to directives
    QString createProtocols =
        "CREATE TABLE IF NOT EXISTS protocols ("
        "protocol_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "protocol_name TEXT NOT NULL, "
        "estimated_duration INTEGER, "
        "module_count INTEGER, "
        "rank INTEGER, "
        "personal_best INTEGER"
        ");";

    if (!q.exec(createProtocols)) {
        hCritical() << "Failed to create protocols table:" << q.lastError().text();
        return false;
    }

    // 4. Mapping directive_protocols table: Implements the many-to-many relationship
    QString createMapping =
        "CREATE TABLE IF NOT EXISTS directives_protocols ("
        "dir_id INTEGER, "
        "protocol_id INTEGER, "
        "PRIMARY KEY (dir_id, protocol_id), " // Enforces uniqueness and optimizes B-Tree lookup
        "FOREIGN KEY(dir_id) REFERENCES directives(dir_id) ON DELETE CASCADE, "
        "FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id) ON DELETE CASCADE"
        ");";
    if (!q.exec(createMapping)) {
        hCritical() << "Failed to create directives_protocols table:" << q.lastError().text();
        return false;
    }

    // 5. Mapping protocol_structure table: Implements the many-to-many relationship
    QString createStructure =
        "CREATE TABLE IF NOT EXISTS protocol_structure ("
            "p_map_id INTEGER PRIMARY KEY,"
            "protocol_id INTEGER,"
            "subsystem INTEGER,"
            "s_order INT,"
            "module_id INTEGER,"
            "quantity INT,"
            "unit_type INT,"
            "UNIQUE (protocol_id, subsystem, s_order),"
            "FOREIGN KEY (protocol_id) REFERENCES protocols(protocol_id),"
            "FOREIGN KEY (module_id) REFERENCES modules(module_id)"
            ");";
    if (!q.exec(createStructure)) {
        hCritical() << "Failed to create protocol_structure table:" << q.lastError().text();
        return false;
    }

    // Rank labels
    QString createRanks=
        "CREATE TABLE IF NOT EXISTS ranks ("
        "rank_level INTEGER PRIMARY KEY, "
        "rank_name TEXT NOT NULL UNIQUE"
        ");";

    if (!q.exec(createRanks)) {
        hCritical() << "Failed to create ranks table:" << q.lastError().text();
        return false;
    }

    // Stores a snapshot of each completed workout for performance analysis.
    QString createHistoy =
        "CREATE TABLE IF NOT EXISTS session_history ("
            "history_id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "protocol_id INTEGER, "
            "session_timestamp INTEGER, " // Unix timestamp (seconds since epoch)
            "session_duration INTEGER, "  // Total session time in seconds
            "modules_duration TEXT, "     // Comma-separated module times: "90,20,80..."
            "calories_burned REAL, "      // Calculated metabolic impact
            "session_speed REAL, "
            "met_score REAL, "
            "FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)"
            ")";
    if (!q.exec(createHistoy)) {
        hCritical() << "Failed to create session_history table:" << q.lastError().text();
        return false;
    }

    QString versionQuery = QString("PRAGMA user_version = %1;").arg(DB_SCHEMA_VERSION);
    // Set the schema version to 1
    if (!q.exec(versionQuery)) {
        hDebug() << "Error setting initial schema version:" << q.lastError().text();
    } else {
        hInfo() << "set current database schema: " << DB_SCHEMA_VERSION;
    }

    hInfo() << "Tables created succesfully";
    return true;
} // createTables()

bool DatabaseManager::seedDatabase() {
    QSqlQuery q;

    hInfo() << "Seeding tables";
    // Load the data shard from the Qt Resource System
    // QFile file(":/qt/qml/res/init_data.json");
    QFile file(":/qt/qml/org/aic/hyperhiit/res/init_data.json");
    if (!file.open(QIODevice::ReadOnly)) {
        hCritical() << "Data shard init_data.json not found.";
        return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    if (jsonData.isEmpty()) {
        hWarning() << "Shard is empty. Neural Sync aborted.";
        return false;
    }

    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    QJsonObject root = doc.object();

    QString versionStr = root["version"].toString();
    float version = versionStr.toFloat();

    if (version < MIN_JSON_VERSION) {
        hCritical() << "Incompatible Data Packet: Detected version" << versionStr
                    << "but system requires at least" << MIN_JSON_VERSION;
        return false;
    }

    QJsonArray modulesArr = root["modules"].toArray();
    QJsonArray directivesArr = root["directives"].toArray();
    QJsonArray protocolsArr = root["protocols"].toArray();
    QJsonArray ranksArr = root["ranks"].toArray();
    // QJsonArray mappingArr = root["mapping"].toArray();

    // Start SQL Transaction to maximize performance and ensure Neural Sync integrity
    if (!m_db.transaction()) {
        hCritical() << "Could not start transaction:" << m_db.lastError().text();
        return false;
    }

    // QSqlQuery q;
    // 1. PRINT FULL JSON (Indented for readability)
    // hDebug() << "--- [START FULL_JSON_SHARD] ---";
    // hDebug().noquote() << doc.toJson(QJsonDocument::Indented);
    // hDebug() << "--- [END FULL_JSON_SHARD] ---";


    //////////// MODULES ///////////////
    for (const QJsonValue &value : std::as_const(modulesArr)) { // TODO: add equipment as list. see doc
        QJsonObject d = value.toObject();
        QString moduleName = d.value("module_name").toString();
        hInfo() << "inserting module " << moduleName;
        // insertModule(name, difficulty, zone, desc, inst, safe, equip, unit, met, fatigue, time)
        int id = insertModule(
            moduleName,
            d.value("difficulty").toInt(0),
            d.value("target_zone").toString("FULL_BODY"),
            d.value("description").toString(),
            d.value("instructions").toString(),
            d.value("safety_info").toString(),
            // d.value("equipment").toString(),
            resolveUnitType(d.value("unit_type")),
            d.value("met_factor").toDouble(),
            d.value("fatigue_rate").toDouble(),
            d.value("rep_time").toDouble()
            );
        if (id != -1) {
            nameToModuleId[moduleName.toLower()] = id;
        }
    }

    //////////// DIRECTIVES ///////////////
    for (const QJsonValue &value : std::as_const(directivesArr)) {
        QJsonObject d = value.toObject();
        QString directiveName = d.value("directive_name").toString();
        hInfo() << "inserting directive " << directiveName;
        int id = insertDirective(
            directiveName,
            d.value("directive_description").toString(),
            d.value("directive_icon").toString(),
            d.value("directive_color").toString()
            );
        if (id != -1) {
            nameToDirectiveId[directiveName] = id;
        }
    }

    //////////// PROTOCOLS ///////////////
    for (const QJsonValue &value : std::as_const(protocolsArr)) {
        QJsonObject d = value.toObject();
        QString protocolName = d.value("protocol_name").toString();
        hInfo() << "inserting protocol " << protocolName;
        int id = insertProtocol(
            protocolName,
            d.value("estimated_duration").toDouble(),
            d.value("module_count").toInt(),
            d.value("rank").toInt(),
            d.value("personal_best").toDouble()
            );
        if (id != -1) {
            nameToProtocolId[protocolName] = id;
            QJsonArray targetDirs = d.value("target_directives").toArray();
            linkProtocol(id, targetDirs);
            QJsonArray protocolStructure = d.value("structure").toArray();
            seedProtocolStructure(id, protocolStructure);
            // for (const QJsonValue &dVal : std::as_const(targetDirs)) {
            //     QString dirName = dVal.toString(); // e.g., "FAT_BURNING"
            //     // Lookup the Directive ID using our pre-populated map
            //     if (nameToDirectiveId.contains(dirName)) {
            //         int directiveId = nameToDirectiveId[dirName];

            //         q.bindValue(":dir_id", directiveId);
            //         q.bindValue(":prot_id", id);

            //         if (!q.exec()) {
            //             hDebug() << "Mapping failure for" << dirName << "<->" << protocolName;
            //         }
            //     }
            // }
        }
    }

    ///////////////// RANKS ///////////////////
    for (const QJsonValue &value : std::as_const(ranksArr)) {
        QJsonObject d = value.toObject();
        QString rankName= d.value("rank_name").toString();
        int id = insertRank(
            d.value("rank_level").toInt(0),
            rankName
            );
        if (id < 0) {
            hCritical() << "Failed to insert rank " << rankName
                        << " with id: " << d.value("rank_level").toInt(0);
        } else {
            hInfo() << "inserted rank " << rankName;
        }
    }

    hInfo() << "Tables seeded succesfully";

    if (m_db.commit()) {
        hInfo() << "UPLINK_COMPLETE: Neural Sync at 100%";
        return true;
    } else {
        hCritical() << "[CRITICAL]: Transaction commit failed. Rolling back.";
        m_db.rollback();
        return false;
    }

    return true;
}

QList<Module> DatabaseManager::getAllModules() {
    QList<Module> moduleList;
    QSqlQuery q("SELECT * FROM modules ORDER BY mod_name ASC");

    while (q.next()) {
        Module m;
        m.id = q.value("module_id").toInt();
        m.name = q.value("mod_name").toString();
        m.targetZone = q.value("target_zone").toString();
        m.difficulty = q.value("difficulty").toInt();
        m.description = q.value("mod_description").toString();
        m.instructions = q.value("mod_instructions").toString();
        m.safety = q.value("mod_safety").toString();
        m.equipment = q.value("mod_equipment").toString();
        m.unitType = q.value("unit_type").toInt();
        m.repTime = q.value("rep_time").toDouble();
        m.metFactor = q.value("met_factor").toDouble();
        m.fatigueRate = q.value("fatigue_rate").toDouble();

        hDebug() << "Append module " << m.name;
        moduleList.append(m);
    }
    return moduleList;
}

QList<Directive> DatabaseManager::getAllDirectives() {
    QList<Directive> list;
    QSqlQuery q("SELECT * FROM directives ORDER BY dir_id ASC");

    while (q.next()) {
        Directive d;
        d.id = q.value("dir_id").toInt();
        d.name = q.value("dir_name").toString();
        d.description = q.value("dir_description").toString();
        d.icon = q.value("dir_icon").toString();
        d.color = q.value("dir_color").toString();

        hDebug() << "Append directive " << d.name;
        list.append(d);
    }
    return list;
}

/**
 * @brief Fetches the active directive from the Database.
 * @return active directive id
 */
int DatabaseManager::getActiveDirectiveId() {
    QSqlQuery q;
    int dirId;
    q.prepare("SELECT config_value FROM system_config WHERE config_key = 'active_directive_id'");

    if (q.exec() && q.next()) {
        dirId = q.value(0).toInt();
        hDebug() << "GET active_directive_id: " << dirId;
        return dirId;
    }

    // Fallback if table is empty: Default to Directive 1 (FAT_BURNING)
    hWarning() << "failed to GET active_directive_id.";
    return 1;
}

/**
 * @brief Sets the active directive to the Database.
 */
void DatabaseManager::setActiveDirectiveId(int dirId) {
    QSqlQuery q;
    q.prepare("INSERT OR REPLACE INTO system_config (config_key, config_value) "
              "VALUES ('active_directive_id', :dirId)");
    q.bindValue(":dirId", QString::number(dirId));
    if (q.exec()) {
        hDebug() << "SET active_directive_id: " << dirId;
    } else {
        hWarning() << "failed to SET active_directive_id: " << dirId;
    }
}


/**
 * Retrieves the Protocol Matrix core data.
 * Does not include structure yet (handled via relational mapping) [Source 15, 23].
 */
QList<Protocol> DatabaseManager::getAllProtocols() {
    QList<Protocol> list;
    QSqlQuery q("SELECT * FROM protocols ORDER BY protocol_name ASC");

    while (q.next()) {
        Protocol p;
        p.id = q.value("protocol_id").toInt();
        p.name = q.value("protocol_name").toString();
        p.estimatedDuration = q.value("estimated_duration").toInt();
        p.moduleCount = q.value("module_count").toInt();
        p.rank = q.value("rank").toInt();
        p.personalBest = q.value("personal_best").toInt();

        hDebug() << "Append protocol " << p.name;
        list.append(p);
    }
    return list;
}

/**
 * [LEVEL_02] Fetches protocols linked to a specific directive.
 * Uses a relational JOIN between 'protocols' and the mapping table 'directives_protocols' [Source 16].
 */
QList<Protocol> DatabaseManager::getProtocolsByDirective(int dirId) {
    QList<Protocol> list;
    QSqlQuery q;

    q.prepare("SELECT p.* FROM protocols p "
              "JOIN directives_protocols dp ON p.protocol_id = dp.protocol_id "
              "WHERE dp.dir_id = :dirId "
              "ORDER BY p.protocol_name ASC");
    q.bindValue(":dirId", dirId);

    if (q.exec()) {
        while (q.next()) {
            Protocol p;
            p.id = q.value("protocol_id").toInt();
            p.name = q.value("protocol_name").toString();
            p.estimatedDuration = q.value("estimated_duration").toInt();
            p.moduleCount = q.value("module_count").toInt();
            p.rank = q.value("rank").toInt();
            p.personalBest = q.value("personal_best").toInt();

            hDebug() << "Append protocol " << p.name;
            list.append(p);
        }
    } else {
        hCritical() << "Failed to load protocol list from DB" << q.lastError().text();
    }
    return list;
}

/**
 * [NEURAL_SYNC] Generates a nested structure of Subsystems and Modules.
 * Required for the BriefingForm MVP (v0.4.0-beta).
 * Each subsystem object contains a 'modules' list property [Source 1, 12, 17].
 */
QVariantList DatabaseManager::getProtocolStructure(int protocolId, bool useFullAbbreviation) {
    QVariantList subsystems;
    QSqlQuery subQuery;

    // STEP 1: Identify distinct subsystems [Source 16]
    subQuery.prepare("SELECT DISTINCT subsystem FROM protocol_structure "
                     "WHERE protocol_id = :id ORDER BY subsystem ASC");
    subQuery.bindValue(":id", protocolId);

    if (subQuery.exec()) {
        while (subQuery.next()) {
            QVariantMap subsystemMap;
            int currentSubId = subQuery.value(0).toInt();

            // [TACTICAL_FIX] Send raw ID as integer
            subsystemMap["subsystem_id"] = currentSubId;
            hDebug() << "Appendig subsystem_id: " << currentSubId << "with modules:";

            // STEP 2: Fetch modules for this subsystem
            QVariantList modulesInSub;
            QSqlQuery modQuery;
            modQuery.prepare("SELECT m.mod_name, ps.quantity, ps.unit_type "
                             "FROM protocol_structure ps "
                             "JOIN Modules m ON ps.module_id = m.module_id "
                             "WHERE ps.protocol_id = :p_id AND ps.subsystem = :sub_id "
                             "ORDER BY ps.s_order ASC");
            modQuery.bindValue(":p_id", protocolId);
            modQuery.bindValue(":sub_id", currentSubId);

            if (modQuery.exec()) {
                while (modQuery.next()) {
                    QVariantMap mod;
                    mod["name"] = modQuery.value(0).toString();
                    mod["quantity"] = modQuery.value(1).toInt();
                    // TODO: delete useFullAbbreviation and return (int)unit_type (char)unit [or unit_symbol] and (string)unit_label
                    int unitType = modQuery.value(2).toInt();
                    mod["unit"] = SystemManager::getUnitLabel(unitType, useFullAbbreviation);
                    mod["zone"] = "FULL BODY";

                    modulesInSub.append(mod);
                    hDebug() << "\t" << mod["quantity"].toString() << mod["unit"].toString() << " " << mod["name"].toString();
                }
            }

            subsystemMap["modules"] = modulesInSub;
            subsystems.append(subsystemMap);
        }
    }
    return subsystems;
}

/**
 * @brief Deep data extraction for the execution engine for ProtocolForm
 */
QVariantList DatabaseManager::getProtocolExecutionDetails(int protocolId) {
    QVariantList executionPacket;
    QSqlQuery query;

    // SQL JOIN to fetch Level 4 metadata: rep_time, met_factor, and fatigue_rate
    query.prepare(
        "SELECT ps.subsystem, ps.module_id, ps.quantity, ps.unit_type, "
        "m.mod_name, m.rep_time, m.target_zone, m.met_factor, m.fatigue_rate, m.unit_type AS default_type "
        "FROM protocol_structure ps "
        "JOIN modules m ON ps.module_id = m.module_id "
        "WHERE ps.protocol_id = :protId "
        "ORDER BY ps.subsystem ASC, ps.s_order ASC"
        );
    query.bindValue(":protId", protocolId);

    if (!query.exec()) {
        hDebug() << "Execution sync error:" << query.lastError().text();
        return executionPacket;
    }

    // Grouping modules by subsystem for the UI progress row [7, 8]
    int currentSubId = -1;
    QVariantMap subsystemMap;
    QVariantList moduleList;

    while (query.next()) {
        int subId = query.value("subsystem").toInt();

        if (subId != currentSubId) {
            if (currentSubId != -1) {
                subsystemMap["modules"] = moduleList;
                executionPacket.append(subsystemMap);
            }
            currentSubId = subId;
            subsystemMap = QVariantMap();
            subsystemMap["subsystem_id"] = subId;
            moduleList = QVariantList();

            hDebug() << "Extracting data of Subsystem " << subId;
        }

        QVariantMap mod;
        int currentUnit = query.value("unit_type").toInt();
        int defaultType = query.value("default_type").toInt();

        mod["module_id"] = query.value("module_id").toInt();
        mod["module_name"] = query.value("mod_name").toString();
        mod["quantity"] = query.value("quantity").toInt();
        mod["unit_type"] = currentUnit;
        mod["default_type"] = defaultType;
        mod["is_default"] = (currentUnit == defaultType);
        mod["unit"] = SystemManager::getUnitLabel(query.value("default_type").toInt(),true);
        mod["rep_time"] = query.value("rep_time").toFloat();
        mod["zone"] = query.value("target_zone").toString();
        mod["met_factor"] = query.value("met_factor").toFloat();
        mod["fatigue_rate"] = query.value("fatigue_rate").toFloat();
        moduleList.append(mod);

        hDebug() << "Module metadata extraction:\n"
                 << QJsonDocument::fromVariant(mod).toJson(QJsonDocument::Indented).constData();

    }

    // Append last subsystem
    if (currentSubId != -1) {
        subsystemMap["modules"] = moduleList;
        executionPacket.append(subsystemMap);
    }

    return executionPacket;
}

int DatabaseManager::setProtocolMaxDuration() {
    QSqlQuery q;

    // 1. Query the longest protocol duration from the Master Table [Source 15]
    if (q.exec("SELECT MAX(estimated_duration) FROM protocols") && q.next()) {
        int maxVal = q.value(0).toInt();

        // 2. Dynamic Tactical Buffer: 10% of the maximum value
        const int TACTICAL_BUFFER = qRound(maxVal * 0.1);
        int finalScale = maxVal + TACTICAL_BUFFER;

        // 3. Persistent Configuration Update (Neural Sync Storage)
        // We use INSERT OR REPLACE to maintain a single 'protocol_max_duration' key
        QSqlQuery configQuery;
        configQuery.prepare("INSERT OR REPLACE INTO system_config (config_key, config_value) "
                            "VALUES ('protocol_max_duration', :val)");
        configQuery.bindValue(":val", QString::number(finalScale));

        if (configQuery.exec()) {
            hDebug() << "[SYSTEM] Protocol Matrix Scale updated to:" << finalScale << "s.";
            return finalScale;
        }
    }

    hCritical() << "Failed to update global protocol scale.";
    return 0; // Return 0 as failure signal
}

/**
 * Extracts the mapping shard for Directive -> Protocol links.                  TODO: DELETEME
 * Essential for the 'Master Cache' filtering strategy in v0.3 [Source 16].
 */
// QMultiMap<int, int> DatabaseManager::getDirectiveProtocolMapping() {
//     QMultiMap<int, int> map;
//     QSqlQuery q("SELECT dir_id, protocol_id FROM directives_protocols");

//     while (q.next()) {
//         // MultiMap allows one Directive ID to point to multiple Protocol IDs
//         map.insert(q.value("dir_id").toInt(), q.value("protocol_id").toInt());
//     }
//     return map;
// }

bool DatabaseManager::restoreDatabase() {
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/hyperhiit_core.db";

    // 1. Release the SQLite file lock by closing the active connection [Source 101]
    if (m_db.isOpen()) {
        m_db.close();
        hInfo() << "Database connection closed for restoration.";
    }

    if (QFile::remove(dbPath)) {
        hInfo() << "" << dbPath << " deleted successfully";
    } else {
        hCritical() << "Could not delete file " << dbPath;
        return false;
    }
    return initDatabase();
}

int DatabaseManager::insertModule(const QString &name, int difficulty, const QString &target, const QString &desc, const QString &instruction,
                                             //  name,     difficulty,                zone,                  desc,                instruction
                                const QString &safety,
                                  // const QString &equipment,
                                  int unit, float met, float f_rate, float rep_time){
                                             //safe,                  equip,         unit,       met,       fatigue,      time
    QSqlQuery q;
    //TODO Chek if module exists
    q.prepare("INSERT OR IGNORE INTO modules(mod_name, target_zone, difficulty, mod_description, mod_instructions, mod_safety, mod_equipment, "
              "unit_type, rep_time, met_factor, fatigue_rate) "
              "VALUES (:name, :target, :difficulty, :desc, :instruction, :safe, :equipment, :unit, :rep_time, :met, :fatigue)");

    q.bindValue(":name", name);
    q.bindValue(":target", target);
    q.bindValue(":difficulty", difficulty);
    q.bindValue(":desc", desc);
    q.bindValue(":instruction", instruction);
    q.bindValue(":safe", safety);
    q.bindValue(":equipment", "NONE");
    q.bindValue(":unit", unit);
    q.bindValue(":rep_time", static_cast<double>(rep_time));
    q.bindValue(":met", static_cast<double>(met));
    q.bindValue(":fatigue", static_cast<double>(f_rate));

    // hDebug() << "q.executedQuery(): " << q.executedQuery();
    // hDebug() << "q.boundValues(): " << q.boundValues();
    if (!q.exec()) {
        hCritical() << "Failed to insert module:" << q.lastError().text();
        return -1;
    }
    return q.lastInsertId().toInt();
}

int DatabaseManager::insertDirective(const QString &name, const QString &desc, const QString &icon, const QString &color) {
    QSqlQuery q;
    q.prepare("INSERT OR IGNORE INTO directives (dir_name, dir_description, dir_icon, dir_color) "
              "VALUES (:name, :desc, :icon, :color)");

    q.bindValue(":name", name);
    q.bindValue(":desc", desc);
    q.bindValue(":icon", icon);
    q.bindValue(":color", color);

    if (!q.exec()) {
        hCritical() << "Failed to insert directive:" << q.lastError().text();
        return -1;
    }
    // hDebug() << "q.executedQuery(): " << q.executedQuery();
    // hDebug() << "q.boundValues(): " << q.boundValues();
    return q.lastInsertId().toInt();
}

int DatabaseManager::insertProtocol(const QString &name, int duration, int modules, int rank, int pb) {
    QSqlQuery q;

    q.prepare("INSERT OR IGNORE INTO protocols (protocol_name, estimated_duration, module_count, rank, personal_best) "
              "VALUES (:name, :duration, :count, :rank, :pb)");
    q.bindValue(":name", name);
    q.bindValue(":duration", duration);
    q.bindValue(":count", modules);
    q.bindValue(":rank", rank);
    q.bindValue(":pb", pb);
    if (!q.exec()) {
        hCritical() << "Failed seeding protocol " << name << ":" << q.lastError().text();
        return -1;
    }
    setProtocolMaxDuration();
    return q.lastInsertId().toInt();
}

int DatabaseManager::insertRank(int rank_level, const QString &rank_name) {
    QSqlQuery q;

    q.prepare("INSERT OR IGNORE INTO ranks (rank_level, rank_name) "
              "VALUES (:id, :name)");
    q.bindValue(":id", rank_level);
    q.bindValue(":name", rank_name);
    if (!q.exec()) {
        hCritical() << "Failed seeding rank " << rank_name << ":" << q.lastError().text();
        return -1;
    }
    return q.lastInsertId().toInt();
}

int DatabaseManager::resolveUnitType(const QJsonValue &unitValue) {
    // Returns the integer or -1 if the shard contains an invalid unit
    return m_unitMap.value(unitValue.toString().toLower(), -1);
}

void DatabaseManager::linkProtocol(int id, const QJsonArray &targetDirs) {
    QSqlQuery q;
    q.prepare("INSERT INTO directives_protocols (dir_id, protocol_id) VALUES (:dir_id, :prot_id)");
    for (const QJsonValue &dVal : std::as_const(targetDirs)) {
        QString dirName = dVal.toString(); // e.g., "FAT_BURNING"
        // Lookup the Directive ID using our pre-populated map
        if (nameToDirectiveId.contains(dirName)) {
            int directiveId = nameToDirectiveId[dirName];

            q.bindValue(":dir_id", directiveId);
            q.bindValue(":prot_id", id);

            if (!q.exec()) {
                hCritical() << "Mapping failure for" << dirName << "<->" << nameToProtocolId.key(id);
            }
        }
    }

}

void DatabaseManager::seedProtocolStructure(int protocolId, const QJsonArray &structureArr) {
    QSqlQuery q;
    // Prepare the structure insertion for the Protocol Matrix
    q.prepare("INSERT INTO protocol_structure (protocol_id, subsystem, s_order, module_id, quantity, unit_type) "
              "VALUES (:prot_id, :subsystem, :s_order, :mod_id, :quantity, :unit)");

    for (const QJsonValue &val : std::as_const(structureArr)) {
        QJsonObject s = val.toObject();
        // Resolve the module name to its corresponding DB INTEGER ID
        QString moduleName = s.value("module").toString();

        if (nameToModuleId.contains(moduleName.toLower())) {
            q.bindValue(":prot_id", protocolId);
            q.bindValue(":subsystem", s.value("subsystem").toInt()); // LEVEL_03 Logic
            q.bindValue(":s_order", s.value("s_order").toInt());     // Execution sequence
            q.bindValue(":mod_id", nameToModuleId[moduleName.toLower()]);   // Resolved Module ID
            q.bindValue(":quantity", s.value("quantity").toInt());
            q.bindValue(":unit", resolveUnitType(s.value("unit")));  // Reps or Seconds

            if (!q.exec()) {
                hCritical() << "Failed to link module" << moduleName
                         << "to protocol ID" << protocolId << ":" << q.lastError().text();
            }
        } else {
            hCritical() << "Module reference" << moduleName
                     << "not found in the current data shard. Integrity compromised.";
        }
    }
}

int DatabaseManager::saveSession(int protocolId, qint64 timestamp, int totalSecs, const QString &modulesLog,
                                  double calories, double speed, double met_score) {
    QSqlQuery q;
    q.prepare("INSERT INTO session_history (protocol_id, session_timestamp, session_duration, modules_duration, calories_burned, session_speed, met_score) "
              "VALUES (:pid, :ts, :duration, :log, :kcal, :speed, :met)");

    q.bindValue(":pid", protocolId);
    q.bindValue(":ts", timestamp);
    q.bindValue(":duration", totalSecs);
    q.bindValue(":log", modulesLog);
    q.bindValue(":kcal", calories);
    q.bindValue(":speed", speed);
    q.bindValue(":met", met_score);

    if (!q.exec()) {
        hWarning() << "Critical failure saving session data: " << q.lastError().text();
        return false;
    }

    int sessionId = q.lastInsertId().toInt();

    hDebug() << "Session saved. ID: " << sessionId << " | Duration: " << totalSecs << "s";
    return sessionId;
}

void DatabaseManager::updateModuleData(const QString &name, double repTime, double fatigueRate) {
    QSqlQuery query;

    query.prepare("UPDATE modules SET "
                  "rep_time = :rt, "
                  "fatigue_rate = :fr "
                  "WHERE mod_name = :name");

    query.bindValue(":rt", repTime);
    query.bindValue(":fr", fatigueRate);
    query.bindValue(":name", name);

    if (!query.exec()) {
        hCritical() << "Failed to update metrics for module:" << name
                    << "Error:" << query.lastError().text();
    } else {
        hInfo() << "Module calibrated | id:" << name
                << " | Target RT:" << repTime << "s | Target FR:" << fatigueRate << "%";
    }
}

void DatabaseManager::updateProtocolDuration(int protocolId, int duration) {
    QSqlQuery query;
    query.prepare("UPDATE protocols SET estimated_duration = :duration WHERE protocol_id = :id");
    query.bindValue(":duration", duration);
    query.bindValue(":id", protocolId);

    if (!query.exec()) {
        hCritical() << "Failed to update duration for protocol" << protocolId
                    << "Error:" << query.lastError().text();
    } else {
        hInfo() << "Protocol" << protocolId << "duration updated to:" << duration << "s";
        setProtocolMaxDuration();
    }
}

QString DatabaseManager::getLastSessionTelemetry(int protocolId) {
    QSqlQuery query;
    query.prepare("SELECT modules_duration FROM session_history "
                  "WHERE protocol_id = :id "
                  "ORDER BY session_timestamp DESC LIMIT 1");
    query.bindValue(":id", protocolId);

    if (query.exec() && query.next()) {
        return query.value(0).toString();
    }
    hCritical() << "Failed to get last session telemetry for protocol" << protocolId
                << "Error:" << query.lastError().text();
    return QString();
}

/**
 * Retrieves the sum of calories burned per day for the last 7 days.
 * Based on the session_history table schema [v0.6 Evolution Metrics].
 */
QVariantList DatabaseManager::getWeeklyCalorieHistory(int startDay, int windowSize) {
    QVariantList historyData;
    QMap<QString, int> calorieMap;
    QSqlQuery query;

    // 1. Fetch available telemetry from the last 7 days
    // We group by date string (YYYY-MM-DD) to easily map values later
    QString sql = QString("SELECT date(session_timestamp, 'unixepoch', 'localtime') AS raw_date, "
                  "SUM(calories_burned) AS daily_calories "
                  "FROM session_history "
                  "WHERE session_timestamp >= strftime('%s', 'now', '-%1 days', 'start of day') "
                  "AND session_timestamp < strftime('%s', 'now', '-%2 days', '+1 day', 'start of day') "
                  "GROUP BY raw_date")
                  .arg(startDay + windowSize - 1)
                  .arg(startDay);

    if (!query.exec(sql)) {
        hCritical() << "Failed to fetch calorie history:" << query.lastError().text();
        return historyData;
    }

    // Store database results in a temporary map for fast lookup
    while (query.next()) {
        calorieMap.insert(query.value("raw_date").toString(), query.value("daily_calories").toInt() / 1000);
    }

    // 2. Generate the 7-day sequence (from 6 days ago up to today)
    QDate today = QDate::currentDate();

    for (int i = (windowSize -1); i >= 0; --i) {
        QDate targetDate = today.addDays(-(startDay + i));
        QString dateKey = targetDate.toString("yyyy-MM-dd");

        // Use the value from the DB if it exists, otherwise default to 0.0
        int calories = calorieMap.value(dateKey, 0.0);

        // Convert to standard 3-letter label (e.g., "MON", "TUE")
        // Forced to Upper Case for the Tactical Overlay aesthetic
        QString dayLabel = QLocale::c().toString(targetDate, "ddd").toUpper();

        hDebug() << "Date: " << dateKey << " is: " << dayLabel << "and has: " << calories << "kcal.";

        QVariantMap entry;
        entry["day"] = dayLabel;
        entry["calories"] = calories;
        historyData.append(entry);
    }
    hInfo() << "Successfully retrieved" << historyData.size() << "days of calorie history.";
    return historyData;
}

/**
 * @brief Retrieves all rank labels from the database.
 * Used to populate the UI rank cache and avoid hardcoded strings.
 * @return A map of rank_value (int) to rank_name (string).
 */
QVariantMap DatabaseManager::getRankLabels() {
    QVariantMap rankMap;
    QSqlQuery query("SELECT rank_level, rank_name FROM ranks ORDER BY rank_level ASC");

    if (!query.exec()) {
        hCritical() << "Failed to fetch rank labels:" << query.lastError().text();
        return rankMap;
    }

    while (query.next()) {
        QString value = query.value("rank_level").toString();
        QString name = query.value("rank_name").toString();
        rankMap.insert(value, name);
    }

    hInfo() << "Rank labels synchronized. Total entries:" << rankMap.size();
    return rankMap;
}

double DatabaseManager::getPowerScore(int startDay, int windowSize) {
    QSqlQuery query;
    const int rankMultiplierK = 3;

    // Segment calculation based on start of day to avoid hourly bias [Source 18]
    QString sql = QString(
                      "SELECT SUM("
                      "  CAST(h.calories_burned AS INTEGER) + "
                      "  (p.rank * %1) + "
                      "  h.met_score + "
                      "  (h.session_duration * h.session_speed)"
                      ") as segment_score "
                      "FROM session_history h "
                      "JOIN protocols p ON h.protocol_id = p.protocol_id "
                      "WHERE h.session_timestamp >= strftime('%s', 'now', '-%2 days', 'start of day') "
                      "AND h.session_timestamp <= strftime('%s', 'now', '-%3 days', '+1 day', 'start of day')")
                      .arg(rankMultiplierK)
                      .arg(startDay + windowSize)
                      .arg(startDay);

    if (query.exec(sql) && query.next()) {
        return query.value("segment_score").toDouble();
    }
    return 0.0;
}

int DatabaseManager::getImprovementPercentage() {
    // Segment A: T-0 to T-6 | Segment B: T-7 to T-13 [Source 19]
    double scoreA = getPowerScore(0, 7);
    double scoreB = getPowerScore(7, 7);

    hDebug() << "Evolution Metrics - ScoreA:" << scoreA << "| ScoreB:" << scoreB;

    if (scoreB <= 0.0) {
        return (scoreA > 0.0) ? 100 : 0; // 100% boost if starting from zero
    }

    // Ratio comparison: ((Current / Previous) - 1) * 100 [Source 21]
    double improvement = ((scoreA / scoreB) - 1.0) * 100.0;

    hInfo() << "Evolution Metrics - ScoreA:" << scoreA << "| ScoreB:" << scoreB
            << "| Delta:" << static_cast<int>(improvement) << "%";

    return static_cast<int>(improvement);
}

int DatabaseManager::getAverageEfficiency(int startDay, int windowSize) {
    QSqlQuery query;

    // Using the same rolling window logic as IMPROVEMENT to include "today"
    QString sql = QString(
                      "SELECT AVG(h.session_speed) as avg_speed "
                      "FROM session_history h "
                      "WHERE h.session_timestamp >= strftime('%s', 'now', '-%1 days', 'start of day') "
                      "AND h.session_timestamp < strftime('%s', 'now', '-%2 days', '+1 day', 'start of day');")
                      .arg(startDay + windowSize - 1)
                      .arg(startDay);

    if (query.exec(sql) && query.next()) {
        double avg = query.value("avg_speed").toDouble();
        // Efficiency is expressed as a percentage of the reference speed (1.0 = 100%)
        return static_cast<int>(avg * 100.0);
    }
    return 0;
}

int DatabaseManager::getEfficiency() {
    double effA = getAverageEfficiency(0, 7);
    double effB = getAverageEfficiency(7, 7);

    hDebug() << "Evolution Metrics - EfficiencyA:" << effA << " | EfficiencyB:" << effB;

    if (effB <= 0) {
        hDebug() << "No previous efficiency data";
        return (effA > 0) ? 100 : 0; // 100% boost if no previous data
    }

    // Trend = ((Current / Previous) - 1) * 100
    double trend = ((effA / effB) - 1.0) * 100.0;

    hDebug() << "Efficiency Sync | Current:" << effA << "% | Previous:" << effB
            << "% | Trend:" << static_cast<int>(trend) << "%";

    return static_cast<int>(trend);
}

int DatabaseManager::getAverageDailyCalories(int startDay, int windowSize) {
    QSqlQuery query;
    // Window: From 6 days ago (start of day) to the end of today (start of tomorrow)
    QString sql = QString(
                      "SELECT SUM(calories_burned) / 7.0 as avg_cal "
                      "FROM session_history "
                      "WHERE session_timestamp >= strftime('%s', 'now', '-%1 days', 'start of day') "
                      "AND session_timestamp < strftime('%s', 'now', '-%2 days', '+1 day', 'start of day')")
                      .arg(startDay + windowSize -1)
                      .arg(startDay);

    if (query.exec(sql) && query.next()) {
        double rawAvg = query.value("avg_cal").toDouble();
        return qRound(rawAvg/1000);
    }
    return 0;
}

/**
 * Calculates the daily session average for the current 7-day segment.
 */
double DatabaseManager::getAverageDailySessions(int startDay, int windowSize) {
    QSqlQuery query;
    // Counting all records in the 7-day window and dividing by the 7-day period
    QString sql = QString(
                      "SELECT COUNT(*) / 7.0 as avg_sessions "
                      "FROM session_history "
                      "WHERE session_timestamp >= strftime('%s', 'now', '-%1 days', 'start of day') "
                      "AND session_timestamp < strftime('%s', 'now', '-%2 days', '+1 day', 'start of day')")
                      .arg(startDay + windowSize -1)
                      .arg(startDay);

    if (query.exec(sql) && query.next()) {
        return query.value("avg_sessions").toDouble();
    }
    return 0.0;
}

int DatabaseManager::getProtocolIdByName(const QString &name) {
    QSqlQuery query;
    query.prepare("SELECT protocol_id FROM protocols WHERE protocol_name = :name");
    query.bindValue(":name", name);

    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }

    return -1; // Return -1 if the protocol does not exist in the master table
}

void DatabaseManager::runMigrations(int oldVersion) {
    QSqlQuery query;

    // --- SCHEMA 2 ---//
    if (oldVersion < 2) {
        hInfo() << "Starting Migration V2: Structure unit_type decoupling...";

        // Add the unit_type column to the mapping table
        // DEFAULT 1 (reps) ensures legacy protocols remain functional
        QString sql = "ALTER TABLE protocol_structure ADD COLUMN unit_type INTEGER DEFAULT 1";

        if (!query.exec(sql)) {
            hCritical() << "Migration V2 failed:" << query.lastError().text();
            return;
        } else {
            QFile file(":/qt/qml/org/aic/hyperhiit/res/init_data.json");
            if (!file.open(QIODevice::ReadOnly)) return;

            QByteArray jsonData = file.readAll();
            file.close();

            QJsonDocument doc = QJsonDocument::fromJson(jsonData);
            QJsonObject root = doc.object();

            QString versionStr = root["version"].toString();
            float version = versionStr.toFloat();

            if (version < MIN_JSON_VERSION) {
                hCritical() << "Incompatible Data Packet: Detected version" << version
                            << "but system requires at least" << MIN_JSON_VERSION;
                return;
            }

            QJsonArray protocolsArr = root["protocols"].toArray();


            QSqlQuery q;
            for (const QJsonValue &pVal : std::as_const(protocolsArr)) {
                QJsonObject pObj = pVal.toObject();
                QString protocolName = pObj["protocol_name"].toString();
                QJsonArray structure = pObj["structure"].toArray();

                // Retrieve the internal ID for this protocol
                hDebug() << "Upgrading " << protocolName;
                int protocolId = getProtocolIdByName(protocolName);
                if (protocolId == -1) continue;

                for (const QJsonValue &sVal : std::as_const(structure)) {
                    QJsonObject sObj = sVal.toObject();
                    QString moduleName = sObj["module"].toString();
                    int subsystem = sObj["subsystem"].toInt();
                    int sOrder = sObj["s_order"].toInt();
                    int unitId = resolveUnitType(sObj["unit"]); // Map "seconds" -> 0, "reps" -> 1

                    // Precise update using the composite key of the structure mapping
                    q.prepare("UPDATE protocol_structure SET unit_type = :unit "
                              "WHERE protocol_id = :pid AND subsystem = :sub AND s_order = :ord");
                    q.bindValue(":unit", unitId);
                    q.bindValue(":pid", protocolId);
                    q.bindValue(":sub", subsystem);
                    q.bindValue(":ord", sOrder);
                    q.exec();
                    // After executing the query
                    hDebug() << "UPDATE protocol_structure SET"
                                " unit_type = "
                             << unitId << " WHERE protocol_id = " << protocolId
                             << " AND subsystem = " << subsystem
                             << " AND s_order = " << sOrder;
                }
            }
            hInfo() << "Protocol units updated from JSON definition.";
        }

        // Update the internal SQLite version tracker
        if (query.exec("PRAGMA user_version = 2")) {
            hInfo() << "Migration V2 completed successfully. Schema synchronized.";
        }
    }

    // --- SCHEMA 3 ---//
    if (oldVersion < 3) {
        hInfo() << "Starting Migration V3: set modules.module_id autoincrement and name uniqueness";
        int moduleCount = 0;
        QString sql;

        QSqlQuery q;
        // Count unique modules by name before migration
        q.exec("SELECT COUNT(DISTINCT mod_name) AS total_modules FROM modules;");
        if (q.next()) {
            moduleCount = q.value(0).toInt();
        }

        // Report duplicates found in the current schema
        QString duplicateSql = "SELECT mod_name, COUNT(*) as occurrence "
                               "FROM modules GROUP BY mod_name HAVING occurrence > 1";

        q.finish();
        q.clear();

        // Open a transaction (all-or-nothing — data is never lost)
        if (!m_db.transaction()) {
            hCritical() << "Could not initiate database transaction for V3.";
            return;
        }

        bool success = true;

        // Search for a duplicate id's
        if (q.exec(duplicateSql)) {
            while (q.next()) {
                QString duplicateName = q.value("mod_name").toString();
                hWarning() << "Duplicate module detected:" << duplicateName
                << "(" << q.value("occurrence").toInt() << " instances found). "
                << "The system will consolidate these into a single unique entry.";

                query.prepare("SELECT module_id FROM modules WHERE mod_name = :name ORDER BY module_id ASC");
                query.bindValue(":name", duplicateName);

                if (query.exec() && query.next()) {
                    // The first ID (the lowest) will be our primary record
                    int survivorId = query.value(0).toInt();

                    // Iterate through the other higher IDs to remap their dependencies
                    while (query.next()) {
                        int redundantId = query.value(0).toInt();

                        // Update protocol structure to point to the survivor ID
                        QSqlQuery updateQuery(m_db);
                        updateQuery.prepare("UPDATE protocol_structure SET module_id = :survivor WHERE module_id = :old");
                        updateQuery.bindValue(":survivor", survivorId);
                        updateQuery.bindValue(":old", redundantId);

                        if (updateQuery.exec()) {
                            hInfo() << "Protocol reference updated for" << duplicateName
                                    << ": replacing ID" << redundantId << "with survivor ID" << survivorId;
                        } else {
                            hCritical() << "Failed to remap protocol references for ID:" << redundantId;
                        }
                    }
                }
            }
        }
        q.finish();
        q.clear();

        // Disable foreign-key checks (avoids cascade errors during the swap)
        if (success && !query.exec("PRAGMA foreign_keys = OFF")) {
            hCritical() << "Can't disable foreign_keys" << query.lastError().text();
            success = false;
        }

        // New table with the corrected schema
        sql = "CREATE TABLE IF NOT EXISTS modules_migration ("
                  "module_id        INTEGER PRIMARY KEY AUTOINCREMENT,"
                  "mod_name         VARCHAR(100) UNIQUE NOT NULL,"
                  "target_zone      VARCHAR(50),"
                  "difficulty       INT,"
                  "mod_description  TEXT,"
                  "mod_instructions TEXT,"
                  "mod_safety       TEXT,"
                  "mod_equipment    TEXT,"
                  "unit_type        INTEGER NOT NULL,"
                  "rep_time         FLOAT,"
                  "met_factor       FLOAT,"
                  "fatigue_rate     FLOAT"
                  ");";

        if (success && !query.exec(sql)) {
            hCritical() << "Failed to insert modules: " << query.lastError().text();
            success = false;
        }

        // Copy all rows — existing IDs are kept as-is, so no FK in
        // protocol_structure will break
        sql = "INSERT OR IGNORE INTO modules_migration "
                  "SELECT "
                  "module_id, "
                  "mod_name, "
                  "target_zone, "
                  "difficulty, "
                  "mod_description, "
                  "mod_instructions, "
                  "mod_safety, "
                  "mod_equipment, "
                  "unit_type, "
                  "rep_time, "
                  "met_factor, "
                  "fatigue_rate "
                  "FROM modules;";
        if (success && !query.exec(sql)) {
            hCritical() << "Failed to insert modules: " << query.lastError().text();
            success = false;
        }

        // Seed sqlite_sequence so the next auto-insert continues
        // from max(existing id) + 1, not from 1
        sql = "INSERT OR REPLACE INTO sqlite_sequence (name, seq) "
              "VALUES ('modules_migration', (SELECT MAX(module_id) FROM modules_migration));";
        if (success && !query.exec(sql)) {
            hCritical() << "Failed to insert table in sqlite_sequence: " << query.lastError().text();
            success = false;
        }

        query.finish();
        query.clear();

        // Remove old table
        if (success && !query.exec("DROP TABLE modules;")) {
            hCritical() << "Failed to delete old table: " << query.lastError().text();
            success = false;
        }
        // Rename to the production name
        if (success && !query.exec("ALTER TABLE modules_migration RENAME TO modules;")) {
            hCritical() << "Failed to rename new table: " << query.lastError().text();
            success = false;
        }

        if (success) {
            if (m_db.commit()){
                // Re-enable after the transaction
                query.exec("PRAGMA foreign_keys = ON;");

                // -- Quick sanity check: should return the same row count as before the migration
                query.exec("SELECT COUNT(*) AS total_modules FROM modules;");
                if (query.next()) {
                    if (moduleCount != query.value(0).toInt()) {
                        hCritical() << "Data integrity failure: row count mismatch with old " << moduleCount;
                    } else if (query.exec("PRAGMA user_version = 3")) {
                        // Update the internal SQLite version tracker
                        hInfo() << "Migration V3 completed successfully. Schema synchronized.";
                    }
                }
            } else {
                hCritical() << "Atomic commit failed. Reverting changes.";
                m_db.rollback();
                query.exec("PRAGMA foreign_keys = ON");
            }
        } else {
            hCritical() << "Migration V3 aborted due to SQL error:" << query.lastError().text();
            m_db.rollback();
            query.exec("PRAGMA foreign_keys = ON");
        }
    }

    // --- SCHEMA 4 ---//
    if (oldVersion < 4) {
        hInfo() << "Migrating database to version 4: Applying relational integrity constraints.";

        if (!m_db.transaction()) {
            hCritical() << "Could not initiate database transaction for V3.";
            return;
        }

        // 1. Create a temporary table with the new schema
        bool ok = query.exec("CREATE TABLE directives_protocols_new ("
                             "dir_id INTEGER, "
                             "protocol_id INTEGER, "
                             "PRIMARY KEY (dir_id, protocol_id), "
                             "FOREIGN KEY(dir_id) REFERENCES directives(dir_id) ON DELETE CASCADE, "
                             "FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id) ON DELETE CASCADE"
                             ")");

        if (!ok) {
            hCritical() << "Migration error during temporary table creation:" << query.lastError().text();
            m_db.rollback();
            return;
        }

        // 2. Transfer existing data ignoring any existing duplicates
        if (!query.exec("INSERT OR IGNORE INTO directives_protocols_new (dir_id, protocol_id) "
                        "SELECT dir_id, protocol_id FROM directives_protocols")) {
            hCritical() << "Migration error during temporary table insertion:" << query.lastError().text();
            m_db.rollback();
            return;
        }

        // 3. Replace the old table with the new structured version
        if (!query.exec("DROP TABLE directives_protocols")) {
            hCritical() << "Migration error during original table drop:" << query.lastError().text();
            m_db.rollback();
            return;
        }
        if (!query.exec("ALTER TABLE directives_protocols_new RENAME TO directives_protocols")) {
            hCritical() << "Migration error during temporary table renaming:" << query.lastError().text();
            m_db.rollback();
            return;
        }
        if (m_db.commit() && query.exec("PRAGMA user_version = 4")) {
            hInfo() << "Migration v4 completed successfully. Unique mapping and cascade rules are now active.";
        } else {
            hCritical() << "Migration error during commit:" << query.lastError().text();
            m_db.rollback();
            return;
        }
    }

}

QVariantList DatabaseManager::getSessionTotals(int sessionId) {
    QVariantList totalsList;
    QSqlQuery query;

    // 1. Resolve protocol_id from session
    query.prepare("SELECT protocol_id FROM session_history WHERE history_id = :id");
    query.bindValue(":id", sessionId);
    if (!query.exec() || !query.next()){
        hCritical() << "No protocol found for session" << sessionId;
        return totalsList;
    }
    int protocolId = query.value(0).toInt();
    hDebug() << "protocolId:" << protocolId;

    // 2. Aggregate quantities grouping by module and unit_type
    // We join with modules to get the human-readable name
    query.prepare("SELECT m.mod_name, SUM(ps.quantity) as total_qty, ps.unit_type "
                  "FROM protocol_structure ps "
                  "JOIN modules m ON ps.module_id = m.module_id "
                  "WHERE ps.protocol_id = :pid "
                  "GROUP BY ps.module_id, ps.unit_type "
                  "ORDER BY ps.s_order ASC");
    query.bindValue(":pid", protocolId);

    if (!query.exec()) {
        hCritical() << "Totals Aggregation Error:" << query.lastError().text();
        return totalsList;
    }

    const QStringList unitSymbols = {"s", "x", "b"}; // TODO: Get symbol from ModuleModel

    while (query.next()) {
        QVariantMap entry;
        entry["name"] = query.value("mod_name").toString().toUpper();
        entry["quantity"] = query.value("total_qty").toInt();
        entry["unit"] = unitSymbols.value(query.value("unit_type").toInt(), "x");

        totalsList.append(entry);
        hDebug() << "TOALS LIST:" << entry;
    }

    return totalsList;
}

QVariantList DatabaseManager::getSessionDetailedAnalysis(int historyId) {
    QVariantList analysisData;
    QSqlQuery query;

    // 1. Get current session metadata and the raw performance log (cumulative MS)
    query.prepare("SELECT protocol_id, modules_duration FROM session_history WHERE history_id = :id");
    query.bindValue(":id", historyId);
    if (!query.exec() || !query.next()) return analysisData;

    int protocolId = query.value("protocol_id").toInt();
    QStringList currentLog = query.value("modules_duration").toString().split(",");

    // 2. Fetch the "Ghost" log (the most recent previous session of the same protocol)
    query.prepare("SELECT modules_duration FROM session_history "
                  "WHERE protocol_id = :pid AND history_id < :hid "
                  "ORDER BY session_timestamp DESC LIMIT 1");
    query.bindValue(":pid", protocolId);
    query.bindValue(":hid", historyId);

    QStringList ghostLog;
    if (query.exec() && query.next()) {
        ghostLog = query.value("modules_duration").toString().split(",");
    }

    // 3. Fetch Protocol Structure joined with Module names and the specific unit_type
    query.prepare("SELECT ps.subsystem, ps.quantity, ps.unit_type, m.mod_name "
                  "FROM protocol_structure ps "
                  "JOIN modules m ON ps.module_id = m.module_id "
                  "WHERE ps.protocol_id = :pid "
                  "ORDER BY ps.subsystem ASC, ps.s_order ASC");
    query.bindValue(":pid", protocolId);

    if (!query.exec()) return analysisData;

    int currentSubId = -1;
    QVariantMap subsystemMap;
    QVariantList modulesInSubsystem;
    int moduleIdx = 0;

    const QStringList unitSymbols = {"s", "x", "b"}; // TODO: Get symbol from ModuleModel

    while (query.next()) {
        int subId = query.value("subsystem").toInt();

        // Detect subsystem transition
        if (subId != currentSubId) {
            if (currentSubId != -1) {
                subsystemMap["modulesModel"] = modulesInSubsystem;
                analysisData.append(subsystemMap);
            }
            currentSubId = subId;
            subsystemMap = QVariantMap();
            subsystemMap["subsystemId"] = subId;
            modulesInSubsystem = QVariantList();
        }

        // Calculate relative duration: Current Checkpoint - Previous Checkpoint
        int currentCP = (moduleIdx < currentLog.size()) ? currentLog[moduleIdx].toInt() : 0;
        int prevCP = (moduleIdx > 0) ? currentLog[moduleIdx - 1].toInt() : 0;
        int moduleDuration = currentCP - prevCP;

        // Calculate Delta against Ghost
        QString deltaText = "--:--";
        int diff = 0;
        if (!ghostLog.isEmpty() && moduleIdx < ghostLog.size()) {
            int gCurrentCP = ghostLog[moduleIdx].toInt();
            int gPrevCP = (moduleIdx > 0) ? ghostLog[moduleIdx - 1].toInt() : 0;
            int ghostDur = gCurrentCP - gPrevCP;
            diff = moduleDuration - ghostDur;
            deltaText = (diff > 0 ? "+" : "") + formatDuration(diff);
            deltaText = (diff == 0 ? " " : "") + deltaText;
            hDebug() << "moduleDuration:" << moduleDuration << " | ghostDur:" << ghostDur << " | diff:" << diff;
        }

        // Build the module object for the inner Repeater
        QVariantMap modEntry;
        modEntry["name"] = query.value("mod_name").toString().toUpper();
        modEntry["quantity"] = query.value("quantity").toInt();
        modEntry["unit"] = unitSymbols.value(query.value("unit_type").toInt(), "x");
        modEntry["time"] = formatDuration(moduleDuration);
        modEntry["delta"] = deltaText;
        modEntry["diff"] = diff;

        modulesInSubsystem.append(modEntry);
        moduleIdx++;
    }

    // Append final subsystem shard
    if (currentSubId != -1) {
        subsystemMap["modulesModel"] = modulesInSubsystem;
        analysisData.append(subsystemMap);
    }

    return analysisData;
}

QString DatabaseManager::formatDuration(int ms) {
    // 1. Determine sign: Only negative deltas get an explicit sign prefix
    // Positive deltas will be "painted" with a '+' or color in QML side.
    QString sign = (ms < 0) ? "-" : "";

    // 2. Use absolute value for calculations to ensure correct zero-padding (e.g., 00:05)
    // Removing qAbs here would cause issues like "00:-05" in negative deltas.
    int totalSecs = qAbs(ms) / 1000;
    int mins = totalSecs / 60;
    int secs = totalSecs % 60;

    // 3. Return formatted string [sign][mm]:[ss]
    return QString("%1%2:%3")
        .arg(sign)
        .arg(mins, 2, 10, QChar('0'))
        .arg(secs, 2, 10, QChar('0'));
}

QVariantMap DatabaseManager::getSessionSummaryMetrics(int historyId) {
    QVariantMap metrics;
    QSqlQuery query;

    // Fetch session telemetry joined with protocol metadata
    query.prepare("SELECT p.protocol_name, h.session_timestamp, h.protocol_id, "
                  "p.rank, p.module_count, h.session_duration, "
                  "h.calories_burned, h.session_speed, h.met_score "
                  "FROM session_history h "
                  "JOIN protocols p ON h.protocol_id = p.protocol_id "
                  "WHERE h.history_id = :id");
    query.bindValue(":id", historyId);

    if (!query.exec() || !query.next()) {
        hWarning() << "Failed to retrieve summary metrics for ID:" << historyId;
        return metrics;
    }

    // Protocol Name
    metrics["protocolName"] = query.value("protocol_name").toString();

    // Session Date: Convert Unix timestamp to "dd/MM/yyyy HH:mmh"
    qint64 timestamp = query.value("session_timestamp").toLongLong();
    QDateTime dateTime = QDateTime::fromSecsSinceEpoch(timestamp);
    metrics["sessionDate"] = dateTime.toString("dd/MM/yyyy HH:mm") + "h";

    int protocolId = query.value("protocol_id").toInt();
    int currentDuration = query.value("session_duration").toInt();
    double currentMetScore = query.value("met_score").toDouble();
    double currentSpeed = query.value("session_speed").toDouble();

    // Map values to the response object
    // RANK: Protocol difficulty level (NEWBIE, ADVANCED, ROOT)
    // metrics["rank"] = unitSymbols.value(query.value("rank").toInt(), "NEWBIE");
    metrics["rank"] = query.value("rank").toInt();

    // MODULE_COUNT: Total modules defined in the protocol
    metrics["moduleCount"] = query.value("module_count").toInt();

    // DURATION: Formatted time from the actual session duration (ms)
    int durationMs = query.value("session_duration").toInt();
    metrics["duration"] = formatDuration(durationMs);
    hDebug() << "durationMs: " << durationMs << " | metrics[duration]: " << metrics["duration"];

    // CALORIES: Total kcal burned (rounded for UX clarity)
    metrics["calories"] = qRound(query.value("calories_burned").toDouble()/1000);

    // Fetch "Ghost" session (the most recent previous session of the same protocol)
    query.prepare("SELECT session_duration, met_score, session_speed FROM session_history "
                  "WHERE protocol_id = :pid AND history_id < :hid "
                  "ORDER BY session_timestamp DESC LIMIT 1");
    query.bindValue(":pid", protocolId);
    query.bindValue(":hid", historyId);

    int prevDuration = 0;
    double prevMetScore = 0.0;
    double prevSpeed= 0.0;
    bool hasGhost = false;

    if (query.exec() && query.next()) {
        prevDuration = query.value("session_duration").toInt();
        prevMetScore = query.value("met_score").toDouble();
        prevSpeed = query.value("session_speed").toDouble();
        hasGhost = true;
    } else {
        hWarning() << "Failed to retrieve ghost summary metrics for ID:" << historyId; // WARNING: Fail if no Ghost Summary
    }

    // 3. Calculate Comparative Metrics

    // EFFICIENCY: Based on the stored speed index (prev_time / current_time)
    // 1.0 means consistent, >1.0 means faster than last time.
    // double efficiencyValue = (( currentSpeed * 100.0 ) / prevSpeed) - 100;
    double efficiencyValue = (( currentSpeed - prevSpeed ) / prevSpeed) * 100;
    metrics["efficiency"] = qRound(efficiencyValue);
    hDebug() << "currentSpeed:" << currentSpeed << " | prevSpeed:" << prevSpeed;

    // IMPROVEMENT: Delta between MET scores (Real mechanical work progression)
    // If no ghost exists, we show 0% or a base improvement.
    double improvementDelta = 0.0;
    if (hasGhost && prevMetScore > 0) {
        improvementDelta = ((currentMetScore - prevMetScore) / prevMetScore) * 100.0;
        hDebug() << "currentMetScore:" << currentMetScore << " | prevMetScore:" << prevMetScore;
    }
    metrics["improvement"] = improvementDelta;

    // TIME DIFFERENCE: Relative time gain/loss compared to the ghost
    metrics["hasGhost"] = hasGhost;

    if (hasGhost) {
        int timeDiff = currentDuration - prevDuration;
        hDebug() << "timeDiff: " << timeDiff;
        metrics["timeDiff"] = timeDiff;
        metrics["timeDiffString"] = formatDuration(timeDiff); // Signs handled by formatDuration
    } else {
        metrics["timeDiff"] = 0;
        metrics["timeDiffString"] = "";
    }

    return metrics;
}

void DatabaseManager::updatePersonalBest(int protocolId, int duration) {
    QSqlQuery query;

    // 1. Retrieve current Personal Best
    query.prepare("SELECT personal_best FROM protocols WHERE protocol_id = :id");
    query.bindValue(":id", protocolId);

    if (query.exec() && query.next()) {
        int currentPB = query.value(0).toInt();

        // 2. Logic: New duration is better if it's lower than current PB (AFAP logic)
        // We also check if currentPB is 0 (initial state)
        if (currentPB == 0 || duration < currentPB) {
            query.prepare("UPDATE protocols SET personal_best = :pb WHERE protocol_id = :id");
            query.bindValue(":pb", duration);
            query.bindValue(":id", protocolId);

            if (query.exec()) {
                hInfo() << "Achievement: New Personal Record for Protocol" << protocolId << ":" << duration << "ms";
            } else {
                hWarning() << "Failed to update Personal Record:" << query.lastError().text();
            }
        }
    }
}

/**
 * Fetches data from the system_config table.
 * Optimized for low-latency retrieval of system parameters.
 */
QString DatabaseManager::getConfig(const QString &key, const QString &defaultValue) {
    QSqlQuery query;
    query.prepare("SELECT config_value FROM system_config WHERE config_key = :key");
    query.bindValue(":key", key);

    if (query.exec() && query.next()) {
        QString value = query.value(0).toString();
        hDebug() << "Configuration retrieved | Key:" << key << "Value:" << value;
        return value;
    }

    hWarning() << "Configuration key not found. Using default | Key:" << key
               << " | SQL ERROR: " << query.lastError().text();
    return defaultValue;
}

/**
 * Updates or creates a configuration entry.
 * Uses 'INSERT OR REPLACE' to maintain a clean key-value store.
 */
void DatabaseManager::setConfig(const QString &key, const QString &value) {
    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO system_config (config_key, config_value) "
                  "VALUES (:key, :value)");
    query.bindValue(":key", key);
    query.bindValue(":value", value);

    if (query.exec()) {
        hInfo() << "Configuration synchronized | Key:" << key << "Value:" << value;
    } else {
        hWarning() << "Failed to sync configuration | Key:" << key << "Error:" << query.lastError().text();
    }
}

/*
 * Persists a directive to the SQL database.
 * Returns the record ID on success, or -1 on failure.
 */
int DatabaseManager::saveDirective(int id, const QString &name,
                                   const QString &description, const QString &icon,
                                   const QString &color) {
    Directive dir;
    dir.id          = id;
    dir.name        = name;
    dir.description = description;
    dir.icon        = icon;
    dir.color       = color;

    QSqlQuery query;
    bool isNew = (dir.id == 0);

    if (isNew) {
        // Prepare insert (ID is omitted to use AUTOINCREMENT)
        query.prepare("INSERT INTO directives (dir_name, dir_description, dir_icon, dir_color) "
                      "VALUES (:name, :desc, :icon, :color)");
    } else if (id > 0){
        // Prepare update for existing records
        query.prepare("UPDATE directives SET dir_name=:name, dir_description=:desc, "
                      "dir_icon=:icon, dir_color=:color WHERE dir_id=:id");
        hDebug() << QString("UPDATE directives SET dir_name='%1', dir_description='%2', dir_icon='%3', dir_color='%4' WHERE dir_id='%5'")
                        .arg(dir.name, dir.description, dir.icon, dir.color)
                        .arg(dir.id);
        query.bindValue(":id", dir.id);
    } else {
        hWarning() << "Save aborted: Invalid ID state (" << id << ")";
        return -1;
    }

    // Bind values using raw strings (Aesthetic policy: user-defined casing)
    query.bindValue(":name", dir.name);
    query.bindValue(":desc", dir.description);
    query.bindValue(":icon", dir.icon);
    query.bindValue(":color", dir.color);

    if (!query.exec()) {
        hCritical() << "Database Error: Failed to save directive ->" << query.lastError().text();
        return -1;
    }

    // Retrieve and return the ID (either generated or existing)
    if (isNew) {
        int newId = query.lastInsertId().toInt();
        hInfo() << "Database Sync: New directive created with ID:" << newId;
        return newId;
    }

    hInfo() << "Database Sync: Directive " << dir.id << " updated";
    return dir.id;
}

int DatabaseManager::saveProtocol(int id, const QString &name, int rank, const QList<int> &directiveIds) {
    QSqlQuery query;
    bool isNew = (id == 0);

    // 1. PERSIST PROTOCOL METADATA
    if (isNew) {
        // Defaulting duration and module count to 0 for a fresh protocol
        query.prepare("INSERT INTO protocols (protocol_name, rank, estimated_duration, module_count, personal_best) "
                      "VALUES (:name, :rank, 0, 0, 0)");
    } else if (id > 0) {
        query.prepare("UPDATE protocols SET protocol_name=:name, rank=:rank WHERE protocol_id=:id");
        query.bindValue(":id", id);
    } else {
        hWarning() << "Save aborted: Invalid ID state (" << id << ")";
        return -1;
    }


    query.bindValue(":name", name);
    query.bindValue(":rank", rank);

    if (!query.exec()) {
        hCritical() << "Protocol persistence failure:" << query.lastError().text();
        return -1;
    }

    int finalId = isNew ? query.lastInsertId().toInt() : id;

    // 2. CREATE SHARD MAPPING (Only for new protocols)
    if (!directiveIds.isEmpty()) {
        for (int dirId : directiveIds) {
            QSqlQuery mapQuery;
            hDebug() << "Inserting protocol on directive: " << dirId;
            mapQuery.prepare("INSERT OR IGNORE INTO directives_protocols (dir_id, protocol_id) VALUES (:dirId, :protoId)");
            mapQuery.bindValue(":dirId", dirId);
            mapQuery.bindValue(":protoId", finalId);

            if (!mapQuery.exec()) {
                hCritical() << "Relational mapping failure for protocol" << finalId << ":" << mapQuery.lastError().text();
            } else {
                hInfo() << "Protocol synchronized. ID:" << finalId << "linked to Directive:" << dirId;
            }
        }
    }

    return finalId;
}

int DatabaseManager::saveModule(const QVariantMap &moduleData) {
    if (!m_db.isOpen()) return -1;

    QSqlQuery query;
    int id = moduleData.value("id", -1).toInt();
    bool isNew = (id <= 0);

    if (isNew) {
        query.prepare("INSERT INTO modules (mod_name, target_zone, difficulty, "
                      "mod_description, mod_instructions, mod_safety, mod_equipment, "
                      "unit_type, rep_time, met_factor, fatigue_rate) "
                      "VALUES (:name, :target, :diff, :desc, :instr, :safe, :equip, :unit, :time, :met, :fatigue)");
    } else {
        query.prepare("UPDATE modules SET mod_name=:name, target_zone=:target, "
                      "difficulty=:diff, mod_description=:desc, mod_instructions=:instr, "
                      "mod_safety=:safe, mod_equipment=:equip, unit_type=:unit, "
                      "rep_time=:time, met_factor=:met, fatigue_rate=:fatigue "
                      "WHERE module_id=:id");
        query.bindValue(":id", id);
    }

    // Mapping fields from the QVariantMap shard
    query.bindValue(":name",    moduleData.value("name").toString());
    query.bindValue(":target",  moduleData.value("targetZone").toString());
    query.bindValue(":diff",    moduleData.value("difficulty").toInt());
    query.bindValue(":desc",    moduleData.value("description").toString());
    query.bindValue(":instr",   moduleData.value("instructions").toString());
    query.bindValue(":safe",    moduleData.value("safety").toString());
    query.bindValue(":equip",   moduleData.value("equipment").toString());
    query.bindValue(":unit",    moduleData.value("unitType").toInt());
    query.bindValue(":time",    moduleData.value("repTime").toDouble());
    query.bindValue(":met",     moduleData.value("metFactor").toDouble());
    query.bindValue(":fatigue", moduleData.value("fatigueRate").toDouble());

    if (!query.exec()) {
        hCritical() << "Module save failed:" << query.lastError().text();
        return -1;
    }

    return isNew ? query.lastInsertId().toInt() : id;
}

bool DatabaseManager::deleteModule(int moduleId) {
    if (!m_db.isOpen()) return false;

    QSqlQuery query;
    // Check for referential integrity or use ON DELETE CASCADE in schema
    query.prepare("DELETE FROM modules WHERE module_id = :id");
    query.bindValue(":id", moduleId);

    if (!query.exec()) {
        hCritical() << "Failed to delete module record:" << query.lastError().text();
        return false;
    }

    hInfo() << "Module record removed successfully. ID:" << moduleId;
    return true;
}

bool DatabaseManager::deleteDirective(int directiveId) {
    if (!m_db.isOpen()) return false;

    if (!m_db.transaction()) {
        hCritical() << "Failed to initialize transaction for directive removal.";
        return false;
    }

    QSqlQuery query;

    // 1. Integrity check: verify if any protocols are linked to this directive
    // We check the mapping table established in Level 02 architecture
    query.prepare("SELECT COUNT(*) FROM directives_protocols WHERE dir_id = :id");
    query.bindValue(":id", directiveId);

    if (query.exec() && query.next()) {
        int linkedProtocols = query.value(0).toInt();
        if (linkedProtocols > 0) {
            hWarning() << "Directive ID " << directiveId
                       << "is active in" << linkedProtocols << "protocols.";
            // 1. Remove all associations in the mapping table
            // This unlinks protocols, making them 'ORPHANS' in the Architect UI
            query.prepare("DELETE FROM directives_protocols WHERE dir_id = :id");
            query.bindValue(":id", directiveId);

            if (!query.exec()) {
                hCritical() << "Error clearing directive-protocol links:" << query.lastError().text();
                m_db.rollback();
                return false;
            }
        }
    }

    // 2. Proceed with record removal from the directives registry
    query.prepare("DELETE FROM directives WHERE dir_id = :id");
    query.bindValue(":id", directiveId);

    if (!query.exec()) {
        hCritical() << "Error removing directive record: " << query.lastError().text();
        m_db.rollback();

        return false;
    }

    if (m_db.commit()) {
        hInfo() << "Directive and its associations removed successfully. ID:" << directiveId;
        return true;
    }

    hCritical() << "Failed to commit directive removal transaction.";
    return false;
}

bool DatabaseManager::saveProtocolStructure(int protocolId, const QVariantList &structure) {
    if (protocolId <= 0) return false;

    m_db.transaction();
    QSqlQuery query;

    // 1. CLEAR EXISTING STRUCTURE
    // We perform a full wipe of the protocol mapping before re-inserting the new sequence
    query.prepare("DELETE FROM protocol_structure WHERE protocol_id = :id");
    query.bindValue(":id", protocolId);
    if (!query.exec()) {
        hCritical() << "Structure reset failure:" << query.lastError().text();
        m_db.rollback();
        return false;
    }

    int totalDuration = 0;
    int totalModules = 0;

    for (int i = 0; i < structure.size(); ++i) {
        hDebug() << "Subsystem Index [" << i << "]:" << structure.at(i);
    }

    // 2. ITERATE SUBSYSTEMS AND MODULES
    for (const QVariant &subVal : structure) {
        QVariantMap subsystem = subVal.toMap();
        int sOrder = 1;
        int subId = subsystem.value("subsystem_id").toInt();
        hDebug() << "Subsystem:" << subId;
        QVariantList modules = subsystem.value("modules").toList();

        for (const QVariant &modVal : std::as_const(modules)) {
            QVariantMap module = modVal.toMap();
            int moduleId = module.value("module_id").toInt();
            int quantity = module.value("quantity").toInt();
            int unitType = module.value("unit_type").toInt();
            hDebug() << "Module id:" << moduleId;

            // Insert mapping record
            query.prepare("INSERT INTO protocol_structure (protocol_id, subsystem, s_order, module_id, quantity, unit_type) "
                          "VALUES (:pId, :sub, :order, :mId, :qty, :unit)");
            query.bindValue(":pId", protocolId);
            query.bindValue(":sub", subId);
            query.bindValue(":order", sOrder++);
            query.bindValue(":mId", moduleId);
            query.bindValue(":qty", quantity);
            query.bindValue(":unit", unitType);

            if (!query.exec()) {
                hCritical() << "Module mapping failure:" << query.lastError().text();
                QSqlDatabase::database().rollback();
                return false;
            }

            // 3. METRIC RECALCULATION
            // We fetch the base rep_time to update the estimated duration of the mission
            QSqlQuery metaQuery;
            metaQuery.prepare("SELECT rep_time FROM modules WHERE module_id = :mId");
            metaQuery.bindValue(":mId", moduleId);
            if (metaQuery.exec() && metaQuery.next()) {
                totalDuration += static_cast<int>(quantity * metaQuery.value(0).toDouble());
            }
            totalModules++;
        }
    }

    // SYNC PROTOCOL METADATA
    // Update the main protocol record with the newly calculated execution metrics
    query.prepare("UPDATE protocols SET estimated_duration = :dur, module_count = :count WHERE protocol_id = :id");
    query.bindValue(":dur", totalDuration);
    query.bindValue(":count", totalModules);
    query.bindValue(":id", protocolId);

    if (!query.exec()) {
        hCritical() << "Protocol metadata sync failure:" << query.lastError().text();
        QSqlDatabase::database().rollback();
        return false;
    }

    // TODO: Calculate rep_time, fatigue_factor, etc.

    hInfo() << "Protocol structure synchronized. Modules:" << totalModules << "Duration:" << totalDuration << "s";
    return QSqlDatabase::database().commit();
}

bool DatabaseManager::hasProtocolHistory(int protocolId) {
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM session_history WHERE protocol_id = :id");
    query.bindValue(":id", protocolId);
    return query.exec() && query.next() && query.value(0).toInt() > 0;
}

bool DatabaseManager::clearProtocolHistory(int protocolId) {
    QSqlQuery query;
    query.prepare("DELETE FROM session_history WHERE protocol_id = :id");
    query.bindValue(":id", protocolId);
    if (query.exec()) {
        hInfo() << "History purged for protocol:" << protocolId;
        return true;
    }
    return false;
}

bool DatabaseManager::deleteProtocol(int protocolId) {
    if (protocolId <= 0) return false;

    hInfo() << "Starting atomic purge for protocol ID:" << protocolId;

    if (!m_db.transaction()) {
        hCritical() << "Failed to initialize deletion transaction.";
        return false;
    }

    QSqlQuery query;

    // 1. Clear session history (Telemetry records)
    // We use the existing logic to ensure consistency
    if (!clearProtocolHistory(protocolId)) {
        hWarning() << "Telemetry purge failed or no history found for protocol:" << protocolId;
        // We continue as history might be empty
    }

    // 2. Clear protocol structure (Sequence mapping)
    query.prepare("DELETE FROM protocol_structure WHERE protocol_id = :id");
    query.bindValue(":id", protocolId);
    if (!query.exec()) {
        hCritical() << "Failed to purge protocol structure:" << query.lastError().text();
        m_db.rollback();
        return false;
    }

    // 3. Delete metadata record (Main protocol entry)
    // Note: 'directives_protocols' links will be deleted via ON DELETE CASCADE in v4 schema
    query.prepare("DELETE FROM protocols WHERE protocol_id = :id");
    query.bindValue(":id", protocolId);
    if (!query.exec()) {
        hCritical() << "Failed to purge protocol metadata:" << query.lastError().text();
        m_db.rollback();
        return false;
    }

    if (m_db.commit()) {
        hInfo() << "Protocol purge sequence completed successfully for ID:" << protocolId;
        return true;
    }

    hCritical() << "Purge commit failure.";
    return false;
}