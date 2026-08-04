/****************************************************************************
** File: AchievementManager.h
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
#ifndef ACHIEVEMENTMANAGER_H
#define ACHIEVEMENTMANAGER_H


#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include "DatabaseManager.h"

class Achievement;

/**
 * @brief Orchestrates the achievement matrix and runs tactical telemetry checks.
 */
class AchievementManager : public QObject {
    Q_OBJECT
    QML_ELEMENT // Unified registration for Qt 6 modules

    Q_PROPERTY(QList<QObject*> achievements READ achievements CONSTANT)

public:
    explicit AchievementManager(DatabaseManager *db, QObject *parent = nullptr);

    /**
     * @brief Iterates through all achievements and updates their status.
     */
    Q_INVOKABLE void runTacticalCheck();

    QList<QObject*> achievements() const { return m_achievements; }

private:
    DatabaseManager *m_db;
    QList<QObject*> m_achievements;
    void initMatrix();
};

#endif // ACHIEVEMENTMANAGER_H
