/****************************************************************************
** File: ModuleModel.cpp
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

#include "ModuleModel.h"

ModuleModel::ModuleModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

/**
 * Returns the number of modules currently loaded in the matrix
 */
int ModuleModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_modules.count();
}

/**
 * Provides the data for the QML tactical overlay.
 */
QVariant ModuleModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_modules.count())
        return QVariant();

    const Module &module = m_modules.at(index.row());

    switch (role) {
    case IdRole:            return module.id;
    case NameRole:          return module.name;
    case TargetRole:        return module.targetZone;
    case DifficultyRole:    return module.difficulty;
    case DescriptionRole:   return module.description;
    case InstructionsRole:  return module.instructions;
    case SafetyRole:        return module.safety;
    case EquipmentRole:     return module.equipment;
    case UnitTypeRole:      return module.unitType;
    case RepTimeRole:       return module.repTime;
    case MetFactorRole:     return module.metFactor;
    case FatigueRateRole:   return module.fatigueRate;
    default:                return QVariant();
    }
}

/**
 * Defines the keys accessible from QML (e.g., model.name).
 */
QHash<int, QByteArray> ModuleModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole]           = "id";
    roles[NameRole]         = "name";
    roles[TargetRole]       = "targetZone";
    roles[DifficultyRole]   = "difficulty";
    roles[DescriptionRole]  = "description";
    roles[InstructionsRole] = "instructions";
    roles[SafetyRole]       = "safety";
    roles[EquipmentRole]    = "equipment";
    roles[UnitTypeRole]     = "unitType";
    roles[RepTimeRole]      = "repTime";
    roles[MetFactorRole]    = "metFactor";
    roles[FatigueRateRole]  = "fatigueRate";
    return roles;
}

/**
 * Populates the model and notifies the UI for a synchronized update
 */
void ModuleModel::setModules(const QList<Module> &modules)
{
    beginResetModel();
    m_modules = modules;
    endResetModel();
}

void ModuleModel::clear()
{
    beginResetModel();
    m_modules.clear();
    endResetModel();
}
