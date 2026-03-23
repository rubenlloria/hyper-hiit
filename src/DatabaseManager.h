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

#include <QObject>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QSqlError>
#include <QSqlQuery>

class DatabaseManager : public QObject {
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);

    Q_INVOKABLE bool restoreDatabase();
    bool initDatabase();
    bool seedDatabase();
    // bool restoreDatabase();


private:
    QSqlDatabase m_db;
    const QMap<QString, int> m_unitMap = {
        {"seconds", 0},
        {"reps",    1}
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
    int insertProtocol(const QString &name, int duration, int modules, const QString &rank, int pb);
    int resolveUnitType(const QJsonValue &unitValue);
    void linkProtocol(int protocolId, const QJsonArray &targetDirectives);
    void seedProtocolStructure(int protocolId, const QJsonArray &structureArr);
};

#endif
