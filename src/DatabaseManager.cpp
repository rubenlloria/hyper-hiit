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
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(path + "/hyper_hiit.db");

    if (!m_db.open()) {
        qDebug() << "DB Error:" << m_db.lastError().text();
        return false;
    }
    return createTables();
}

bool DatabaseManager::createTables() {
    QSqlQuery q;
    bool success = true;

    // We use the English schema we discussed
    success &= q.exec("CREATE TABLE IF NOT EXISTS exercises (exercise_id INTEGER PRIMARY KEY, name TEXT UNIQUE)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS directives (directive_id INTEGER PRIMARY KEY, label TEXT UNIQUE)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS protocols (protocol_id INTEGER PRIMARY KEY, directive_id INTEGER, name TEXT, version INTEGER)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS subsystems (subsystem_id INTEGER PRIMARY KEY, protocol_id INTEGER, name TEXT, order_index INTEGER)");
    success &= q.exec("CREATE TABLE IF NOT EXISTS protocol_steps (step_id INTEGER PRIMARY KEY, subsystem_id INTEGER, exercise_id INTEGER, reps_count INTEGER, order_index INTEGER)");

    return success;
}

bool DatabaseManager::seedDatabase() {
    QSqlQuery q;
    // Insert initial directive
    q.exec("INSERT OR IGNORE INTO directives (label) VALUES ('FAT_BURN')");
    // Insert initial exercise
    q.exec("INSERT OR IGNORE INTO exercises (name) VALUES ('BURPEES')");
    // Insert test protocol: ARES_STRIKE
    q.exec("INSERT OR IGNORE INTO protocols (directive_id, name, version) VALUES (1, 'ARES_STRIKE', 1)");

    qDebug() << "[CORE] Database seeded with ARES_STRIKE protocol.";
    return true;
}
