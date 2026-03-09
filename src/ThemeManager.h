/****************************************************************************
** File: ThemeManager.h
** Date: 22/02/2026
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

#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QUrl>

class ThemeManager : public QObject {
    Q_OBJECT
    // Propiedad para que QML sepa la ruta base de las imágenes
    Q_PROPERTY(QUrl themePath READ themePath NOTIFY themeChanged)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    // Función que llamaremos desde el menú de configuración
    Q_INVOKABLE void loadTheme(const QString &folderName);

    QUrl themePath() const { return m_themePath; }

signals:
    void themeChanged();
    // Señal que envía todos los colores del JSON a QML de una vez
    void themeDataLoaded(QVariantMap data);

private:
    QUrl m_themePath;
};

#endif // THEMEMANAGER_H
