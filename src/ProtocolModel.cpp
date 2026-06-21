/****************************************************************************
** File: ProtocolModel.cpp
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
 * [LEVEL_02] Protocol List Model Implementation.
 * Manages the mission sequence stream for the QML tactical overlay [Source 1, 11].
 * Optimized for Neural Sync and real-time metric visualization [Source 5, 27].
 */
// #define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL


#include "src/SystemLog.h"
#include "ProtocolModel.h"
#include "src/DatabaseManager.h"

ProtocolModel::ProtocolModel(DatabaseManager *db, QObject *parent)
    : QAbstractListModel(parent)
    , m_db(db)
{
    if (!m_db) {
        hCritical() << "ProtocolModel initialized without Database Uplink.";
    } else {
        hDebug() << "Protocol Shard Uplink established.";
    }
}

/**
 * Returns the number of protocols currently loaded in the shard [Source 15].
 */
int ProtocolModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_protocols.count();
}

/**
 * Maps database fields to QML roles for real-time visualization [Source 34].
 * Enforces Aesthetic Persistence for labels and mission names [Source 13, 26].
 */
QVariant ProtocolModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_protocols.count())
        return QVariant();

    const Protocol &protocol = m_protocols.at(index.row());

    switch (role) {
    case IdRole:          return protocol.id;
    case NameRole:        return protocol.name;
    case DurationRole:    return protocol.estimatedDuration;
    case ModuleCountRole: return protocol.moduleCount;
    case RankRole:        return protocol.rank;
    case PBRole:          return protocol.personalBest;
    default:              return QVariant();
    }
}

/**
 * Defines the role names accessible from the QML NeonProtocol component [Source 34].
 */
QHash<int, QByteArray> ProtocolModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole]          = "id";
    roles[NameRole]        = "name";
    roles[DurationRole]    = "duration";
    roles[ModuleCountRole] = "moduleCount";
    roles[RankRole]        = "rank";
    roles[PBRole]          = "personalBest";
    return roles;
}

/**
 * Updates the model and triggers a UI refresh [Source 5].
 */
void ProtocolModel::setProtocols(const QList<Protocol> &protocols)
{
    beginResetModel();
    m_protocols = protocols;
    hDebug() << m_protocols.size() << "protocols found";
    // Fetch the persistent scale from the configuration table
    QSqlQuery q;
    q.prepare("SELECT config_value FROM system_config WHERE config_key = 'protocol_max_duration'");
    if (q.exec() && q.next()) {
        m_maxDuration = q.value(0).toInt();
    } else {
        m_maxDuration = 1800; // Fallback to 30min if config is missing
    }

    endResetModel();
    emit maxDurationChanged();
}

void ProtocolModel::clear()
{
    beginResetModel();
    m_protocols.clear();
    endResetModel();
}

/**
 * Neural Sync: Executes the filter command from QML.
 * Updates the shard with protocols linked to the selected ID [Source 16, 28].
 */
void ProtocolModel::filterByDirective(int dirId) {
    if (!m_db) {
        hCritical() << "Database offline";
        return;
    }

    // Fetch only protocols linked to this directive via SQL Join [Source 16]
    QList<Protocol> filteredList = m_db->getProtocolsByDirective(dirId);
    hDebug() << "Filtered " << filteredList.size() << "protocols";
    setProtocols(filteredList);
}
