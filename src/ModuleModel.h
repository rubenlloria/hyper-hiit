/****************************************************************************
** File: ModuleModel.h
** Date: 24/3/2026
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

/**
 * [LEVEL_04] Module Data Model.
 * Represents the atomic unit of execution (Action or State like REST) [Source 12, 13].
 * Optimized for real-time telemetry and <1ms latency [Source 28].
 */

#ifndef MODULEMODEL_H
#define MODULEMODEL_H

#include <QAbstractListModel>
#include <QStringList>

struct Module {
    int id;
    QString name;         // Aesthetic Persistence: UPPERCASE [Source 13]
    QString targetZone;   // e.g., FULL_BODY, CORE [Source 53]
    int difficulty;       // 1: Beginner | 2: Intermediate | 3: Advanced [Source 13]
    QString description;
    int unitType;         // 0: SECONDS | 1: REPS [Source 17]
    double repTime;       // Base time per unit [Source 18]
    double metFactor;     // Metabolic efficiency [Source 19]
    double fatigueRate;   // Performance multiplier [Source 18]
};

class ModuleModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ModuleRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        TargetRole,
        DifficultyRole,
        DescriptionRole,
        UnitTypeRole,
        RepTimeRole,
        MetFactorRole,
        FatigueRateRole
    };

    explicit ModuleModel(QObject *parent = nullptr);

    // QAbstractListModel interface implementation
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Data handling
    void setModules(const QList<Module> &modules);
    void clear();

private:
    QList<Module> m_modules;

};

#endif // MODULEMODEL_H
