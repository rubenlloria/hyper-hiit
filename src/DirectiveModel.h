/****************************************************************************
** File: DirectiveModel.h
** Date: 25/3/2026
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

/**
 * [LEVEL_01] Directive Data Model.
 * High-level mission objectives (e.g., FAT_BURNING, STRENGTH_MATRIX)
 * Optimized for Neural Sync and low-latency UI updates
 */

#ifndef DIRECTIVEMODEL_H
#define DIRECTIVEMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QList>

class DatabaseManager;

struct Directive {
    int id;
    QString name;
    QString description;
    QString icon;         // Lucide glyph hex code
    QString color;        // Hex neon color (e.g., #BF00FF)
};

/**
 * @brief Manages the in-memory list of directives for the UI.
 * Provides high-speed access and synchronization with the database shard.
 */
class DirectiveModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum DirectiveRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        DescriptionRole,
        IconRole,
        ColorRole
    };

    explicit DirectiveModel(DatabaseManager *db, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @brief Updates the internal list and resets the model.
     */
    Q_INVOKABLE void setDirectives(const QList<Directive> &directives);

    /**
     * @brief Injects a new provisional directive entry into the model memory.
     */
    Q_INVOKABLE void insertNewDraft();

private:
    QList<Directive> m_directives;
    DatabaseManager *m_db = nullptr;
};

#endif // DIRECTIVEMODEL_H
