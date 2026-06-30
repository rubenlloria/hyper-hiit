/****************************************************************************
** File: DirectiveModel.cpp
** Date: 25/3/2026
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

#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include "DirectiveModel.h"
#include "DatabaseManager.h"
#include "SystemLog.h"

DirectiveModel::DirectiveModel(DatabaseManager *db, QObject *parent)
    : QAbstractListModel(parent)
    , m_db(db)
{
    if (!m_db) {
        hCritical() << "DirectiveModel initialized without Database Uplink.";
    } else {
        hDebug() << "Directive Shard Uplink established.";
    }
}

int DirectiveModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_directives.count();
}

/**
 * Provides directive data to the NeonAccordion [Source 85, 88].
 * Enforces Aesthetic Persistence (UPPERCASE) for mission names [Source 13].
 */
QVariant DirectiveModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_directives.count())
        return QVariant();

    const Directive &directive = m_directives.at(index.row());

    switch (role) {
    case IdRole:          return directive.id;
    case NameRole:        return directive.name;
    case DescriptionRole: return directive.description;
    case IconRole:        return directive.icon;
    case ColorRole:       return directive.color;
    default:              return QVariant();
    }
}

QHash<int, QByteArray> DirectiveModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole]          = "id";
    roles[NameRole]        = "name";
    roles[DescriptionRole] = "description";
    roles[IconRole]        = "icon";
    roles[ColorRole]       = "color";
    return roles;
}

void DirectiveModel::setDirectives(const QList<Directive> &directives)
{
    beginResetModel();
    m_directives = directives;
    endResetModel();
}

void DirectiveModel::insertNewDraft() {
    beginInsertRows(QModelIndex(), m_directives.count(), m_directives.count());

    Directive newDir;
    newDir.id = -1; // Flag per a SQL
    newDir.name = "NEW_DIRECTIVE";
    newDir.description = "NEW_DESCRIPTION";
    newDir.icon = "\ue0d2";
    newDir.color = "#00FFFF"; // Color per defecte

    m_directives.append(newDir);
    endInsertRows();
    hInfo() << "New directive draft initialized in C++ model memory.";
}
