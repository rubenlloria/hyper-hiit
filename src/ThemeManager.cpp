/****************************************************************************
** File: ThemeManager.cpp
** Date: 22/2/2026
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

#include "ThemeManager.h"
#include <QDebug>
#include <QStandardPaths>
#include <QDir>

ThemeManager::ThemeManager(QObject *parent) : QObject(parent) {}

void ThemeManager::loadTheme(const QString &folderName) {
    // 1. Construir la ruta (puedes usar una ruta fija para pruebas ahora)
    QString path = QDir::currentPath() + "/themes/" + folderName;
    QFile file(path + "/theme.json");

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "No se pudo abrir el tema en:" << path;
        return;
    }

    // 2. Leer y parsear el JSON
    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject obj = doc.object();

    // 3. Actualizar la ruta base para las imágenes
    m_themePath = QUrl::fromLocalFile(path + "/");

    // 4. Avisar a QML
    emit themeDataLoaded(obj.toVariantMap());
    emit themeChanged();

    qDebug() << "Tema cargado correctamente:" << folderName;
}
