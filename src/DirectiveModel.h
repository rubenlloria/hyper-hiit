/****************************************************************************
** File: DirectiveModel.h
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

/**
 * [LEVEL_01] Directive Data Model.
 * High-level mission objectives (e.g., FAT_BURNING, STRENGTH_MATRIX) [Source 11, 14].
 * Optimized for Neural Sync and low-latency UI updates [Source 5, 28].
 */

#ifndef DIRECTIVEMODEL_H
#define DIRECTIVEMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QList>

struct Directive {
    int id;
    QString name;         // Aesthetic Persistence: UPPERCASE [Source 13]
    QString description;
    QString icon;         // Lucide glyph hex code [Source 14, 23]
    QString color;        // Hex neon color (e.g., #BF00FF) [Source 15, 23]
};

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

    explicit DirectiveModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setDirectives(const QList<Directive> &directives);

private:
    QList<Directive> m_directives;
};

#endif // DIRECTIVEMODEL_H
