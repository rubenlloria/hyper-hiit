/****************************************************************************
** File: ProtocolModel.h
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
 * [LEVEL_02] Protocol Data Model.
 * Manages mission sequences and handles real-time metric calculations [Source 9, 12].
 * Enforces Aesthetic Persistence and low-latency synchronization [Source 5, 13].
 */

#ifndef PROTOCOLMODEL_H
#define PROTOCOLMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QList>

class DatabaseManager;

struct Protocol {
    int id;
    QString name;           // Aesthetic Persistence: UPPERCASE
    int estimatedDuration;  // Σ (quantity * base_time)
    int moduleCount;        // Total entries in protocol_structure
    int rank;           // 1=NEWBIE, 2=ADVANCED, or 3=ROOT
    int personalBest;       // PB marker for efficiency bar
};

class ProtocolModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int maxDuration READ maxDuration NOTIFY maxDurationChanged)

public:
    enum ProtocolRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        DurationRole,
        ModuleCountRole,
        RankRole,
        PBRole
    };

    explicit ProtocolModel(DatabaseManager *db, QObject *parent = nullptr);

    // QAbstractListModel interface implementation
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE int maxDuration() const { return m_maxDuration; }

    // Data handling
    void setProtocols(const QList<Protocol> &protocols);
    void clear();

    /**
     * @brief Filters the protocols shown in the HUD based on the active Directive.
     * Marked Q_INVOKABLE so it can be called from Dashboard.qml [Source 11].
     */
    Q_INVOKABLE void filterByDirective(int dirId);

    /**
     * @brief Injects a temporary draft protocol into the model memory.
     */
    Q_INVOKABLE void insertNewDraft();

    /**
     * @brief Neural Sync: Resets the model to display every protocol in the registry.
     * Accessible via QML for the 'ALL' tactical filter.
     */
    Q_INVOKABLE void showAll();

    /**
     * @brief Neural Sync: Filters the model to display only unassigned (orphan) protocols.
     * Accessible via QML for the 'ORPHAN' management mode.
     */
    Q_INVOKABLE void showOrphans();

signals:
    /**
     * Notifies the HUD when the global duration scale changes.
     * Required for real-time relative bar updates [Source 5, 27].
     */
    void maxDurationChanged();

private:
    QList<Protocol> m_protocols;
    DatabaseManager *m_db = nullptr;
    int m_maxDuration;
};

#endif // PROTOCOLMODEL_H
