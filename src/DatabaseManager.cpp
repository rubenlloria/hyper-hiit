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

#include "DatabaseManager.h"

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {}

bool DatabaseManager::initDatabase() {
    // Locate the writable storage for the database file [1]
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);

    QString dbPath = path + "/hyperhiit_core.db";
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qDebug() << "ERROR: Failed to establish db connection.";
        return false;
    }

    return createTables();
}

bool DatabaseManager::createTables() {
    QSqlQuery q;

    // 1. Directives table
    QString createDirectives =
        "CREATE TABLE IF NOT EXISTS directives ("
        "directive_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "directive_name TEXT NOT NULL, "
        "directive_description TEXT, "
        "directive_icon TEXT, "
        "directive_color TEXT"
        ");";
    if (!q.exec(createDirectives)) {
        qDebug() << "ERROR: Failed to create directives table:" << q.lastError().text();
        return false;
    }

    /*
    // We use the English schema we discussed
    success &= q.exec("CREATE TABLE IF NOT EXISTS exercises (exercise_id INTEGER PRIMARY KEY, name TEXT UNIQUE)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS directives (directive_id INTEGER PRIMARY KEY, label TEXT UNIQUE)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS protocols (protocol_id INTEGER PRIMARY KEY, directive_id INTEGER, name TEXT, version INTEGER)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS subsystems (subsystem_id INTEGER PRIMARY KEY, protocol_id INTEGER, name TEXT, order_index INTEGER)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS protocol_steps (step_id INTEGER PRIMARY KEY, subsystem_id INTEGER, exercise_id INTEGER, reps_count INTEGER, order_index INTEGER)");
    */

    // 2. Protocols table: linked to directives
    QString createProtocols =
        "CREATE TABLE IF NOT EXISTS protocols ("
        "protocol_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "protocol_name TEXT NOT NULL, "
        "estimated_duration INTEGER, "
        "module_count INTEGER, "
        "rank TEXT, "
        "personal_best INTEGER"
        ");";

    if (q.exec(createProtocols)) {
        qDebug() << "ERROR: Failed to create protocols table:" << q.lastError().text();
        return false;
    }

    // 3. Mapping table: Implements the many-to-many relationship [6]
    QString createMapping =
        "CREATE TABLE IF NOT EXISTS directives_protocols_map ("
        "mapping_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "directive_id INTEGER, "
        "protocol_id INTEGER, "
        "FOREIGN KEY(directive_id) REFERENCES directives(directive_id), "
        "FOREIGN KEY(protocol_id) REFERENCES protocols(protocol_id)"
        ");";
    if (!q.exec(createMapping)) {
        qDebug() << "ERROR: Failed to create directives_protocols_map table:" << q.lastError().text();
        return false;
    }


    return true;
}

bool DatabaseManager::seedDatabase() {
    QSqlQuery q;

    //////////// DIRECTIVES ///////////////
    // --- Insert Primary Directive (FAT_BURNING) ---
    q.prepare("INSERT OR IGNORE INTO directives (directive_name, description, icon_glyph, neon_color) "
              "VALUES (:name, :desc, :icon, :color)");
    q.bindValue(":name", "FAT_BURNING");
    q.bindValue(":desc", "Metabolic acceleration protocol"); // Sentence case [7]
    q.bindValue(":icon", "\ue0d2"); // Lucide flame icon [7, 8]
    q.bindValue(":color", "#BF00FF"); // Fuchsia Neon constant [9]
    if (!q.exec()) return false;
    // Get the last inserted ID for mapping
    int fatBurnId = q.lastInsertId().toInt();
    qDebug() << "[CORE] Database seeded with FAT_BURNING directive.";

    //////////// PROTOCOLS ///////////////
    // Seed a test protocol (ARES_STRIKE) linked to FAT_BURNING (ID 1)
    q.prepare("INSERT OR IGNORE INTO protocols (protocol_name, estimated_duration, module_count, rank, personal_best) "
              "VALUES (:name, :duration, :count, :rank, :pb)");
    q.bindValue(":name", "ARES_STRIKE");
    q.bindValue(":duration", 1200); // 20 minutes in seconds [11]
    q.bindValue(":count", 8);
    q.bindValue(":rank", "ADVANCED");
    q.bindValue(":pb", 85);
    if (!q.exec()) return false;
    int aresStrikeId = q.lastInsertId().toInt();
    qDebug() << "[CORE] Database seeded with ARES_STRIKE protocol.";

/*
    // Insert initial directive
    q.exec("INSERT OR IGNORE INTO directives (label) VALUES ('FAT_BURN')");
    // Insert initial exercise
    q.exec("INSERT OR IGNORE INTO exercises (name) VALUES ('BURPEES')");
    // Insert test protocol: ARES_STRIKE
    q.exec("INSERT OR IGNORE INTO protocols (directive_id, name, version) VALUES (1, 'ARES_STRIKE', 1)");
*/


    // --- Create Mapping Relation ---
    // Link ARES_STRIKE to FAT_BURNING using the map table [6]
    q.prepare("INSERT OR IGNORE INTO directives_protocols_map (directive_id, protocol_id) "
              "VALUES (:dir_id, :prot_id)");
    q.bindValue(":dir_id", fatBurnId);
    q.bindValue(":prot_id", aresStrikeId);

    return q.exec();

    return true;
}
