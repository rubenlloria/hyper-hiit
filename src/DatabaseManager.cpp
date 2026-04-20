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

// #define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include <QFile>
#include "DatabaseManager.h"

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
            "module_id INTEGER PRIMARY KEY,"
            "mod_name VARCHAR(100),"
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
            "rank TEXT, "
            "personal_best INTEGER"
            ");";

    if (!q.exec(createProtocols)) {
        hCritical() << "Failed to create protocols table:" << q.lastError().text();
        return false;
    }

    // 4. Mapping directive_protocols table: Implements the many-to-many relationship
    QString createMapping =
        "CREATE TABLE IF NOT EXISTS directives_protocols ("
            "dp_mapping_id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "dir_id INTEGER, "
            "protocol_id INTEGER, "
            "FOREIGN KEY(dir_id) REFERENCES directives(dir_id), "
            "FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)"
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
            "UNIQUE (protocol_id, subsystem, s_order),"
            "FOREIGN KEY (protocol_id) REFERENCES protocols(protocol_id),"
            "FOREIGN KEY (module_id) REFERENCES modules(module_id)"
            ");";
    if (!q.exec(createStructure)) {
        hCritical() << "Failed to create protocol_structure table:" << q.lastError().text();
        return false;
    }
    hInfo() << "Tables created succesfully";
    return true;
}

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
        qWarning() << "Shard is empty. Neural Sync aborted.";
        return false;
    }

    QJsonDocument doc = QJsonDocument::fromJson(jsonData);
    QJsonObject root = doc.object();
    QJsonArray modulesArr = root["modules"].toArray();
    QJsonArray directivesArr = root["directives"].toArray();
    QJsonArray protocolsArr = root["protocols"].toArray();
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
            d.value("rank").toString(),
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
    qWarning() << "failed to GET active_directive_id.";
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
        qWarning() << "failed to SET active_directive_id: " << dirId;
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
        p.rank = q.value("rank").toString(); // newbie, advanced, or root [Source 26]
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
            p.rank = q.value("rank").toString();
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
QVariantList DatabaseManager::getProtocolStructure(int protocolId) {
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
            modQuery.prepare("SELECT m.mod_name, ps.quantity, m.unit_type "
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
                    switch (modQuery.value(2).toInt()) {
                    case 0:
                        mod["unit"] = "s.";
                        break;
                    case 1:
                        mod["unit"] = "x";
                        break;
                    case 2:
                        mod["unit"] = "b";
                        break;
                    default:
                        mod["type"] = "";
                        break;
                    }
                    modulesInSub.append(mod);
                    hDebug() << "\t" << mod["quantity"].toString() << mod["type"].toString() << " " << mod["name"].toString();
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
        "SELECT ps.subsystem, ps.quantity, "
        "m.mod_name, m.unit_type, m.rep_time, m.met_factor, m.fatigue_rate "
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
            subsystemMap["subsystemId"] = subId;
            moduleList = QVariantList();
        }

        QVariantMap mod;
        mod["module_name"] = query.value("mod_name").toString();
        mod["quantity"] = query.value("quantity").toInt();
        mod["unit_type"] = query.value("unit_type").toInt();
        mod["rep_time"] = query.value("rep_time").toFloat();
        mod["met_factor"] = query.value("met_factor").toFloat();
        mod["fatigue_rate"] = query.value("fatigue_rate").toFloat();
        moduleList.append(mod);
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
 * Extracts the mapping shard for Directive -> Protocol links.
 * Essential for the 'Master Cache' filtering strategy in v0.3 [Source 16].
 */
QMultiMap<int, int> DatabaseManager::getDirectiveProtocolMapping() {
    QMultiMap<int, int> map;
    QSqlQuery q("SELECT dir_id, protocol_id FROM directives_protocols");

    while (q.next()) {
        // MultiMap allows one Directive ID to point to multiple Protocol IDs
        map.insert(q.value("dir_id").toInt(), q.value("protocol_id").toInt());
    }
    return map;
}

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

int DatabaseManager::insertProtocol(const QString &name, int duration, int modules, const QString &rank, int pb) {
    QSqlQuery q;

    q.prepare("INSERT OR IGNORE INTO protocols (protocol_name, estimated_duration, module_count, rank, personal_best) "
              "VALUES (:name, :duration, :count, :rank, :pb)");
    q.bindValue(":name", name);
    q.bindValue(":duration", duration); // 20 minutes in seconds [11]
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
    // Prepare the structure insertion for the Protocol Matrix [4, 6]
    q.prepare("INSERT INTO protocol_structure (protocol_id, subsystem, s_order, module_id, quantity) "
              "VALUES (:prot_id, :subsystem, :s_order, :mod_id, :quantity)");

    for (const QJsonValue &val : std::as_const(structureArr)) {
        QJsonObject s = val.toObject();
        // Resolve the module name to its corresponding DB INTEGER ID
        QString moduleName = s.value("module").toString();

        if (nameToModuleId.contains(moduleName.toLower())) {
            q.bindValue(":prot_id", protocolId);
            q.bindValue(":subsystem", s.value("subsystem").toInt()); // LEVEL_03 Logic [7, 8]
            q.bindValue(":s_order", s.value("s_order").toInt());     // Execution sequence [6]
            q.bindValue(":mod_id", nameToModuleId[moduleName.toLower()]);   // Resolved Module ID [4]
            q.bindValue(":quantity", s.value("quantity").toInt());  // Reps or Seconds [9]

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
