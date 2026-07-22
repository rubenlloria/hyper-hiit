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
 * Represents the atomic unit of execution (Action or State like REST)
 * Optimized for real-time telemetry and <1ms latency
 */

#ifndef MODULEMODEL_H
#define MODULEMODEL_H

#include <QAbstractListModel>
#include <QStringList>

struct Module {
    int id;
    QString name;         // Aesthetic Persistence: UPPERCASE
    QString targetZone;   // e.g., FULL_BODY, CORE
    int difficulty;       // 1: Beginner | 2: Intermediate | 3: Advanced
    QString description;
    QString instructions;
    QString safety;
    QString equipment;
    int unitType;         // 0: SECONDS | 1: REPS
    double repTime;       // Base time per unit
    double metFactor;     // Metabolic efficiency
    double fatigueRate;   // Performance multiplier
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
        InstructionsRole,
        SafetyRole,
        EquipmentRole,
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
    Q_INVOKABLE void setModules(const QList<Module> &modules);
    void clear();

private:
    QList<Module> m_modules;

};

#endif // MODULEMODEL_H
