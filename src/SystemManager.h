/****************************************************************************
** File: SystemManager.h
** Date: 15/3/2026
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

#ifndef SYSTEMMANAGER_H
#define SYSTEMMANAGER_H

#include <QObject>
#include <QDebug>

class SystemManager : public QObject {
    Q_OBJECT
    // Propietat per controlar l'estat global des del HUD
    Q_PROPERTY(bool isSystemReady READ isSystemReady NOTIFY systemReadyChanged)

public:
    explicit SystemManager(QObject *parent = nullptr);

    bool isSystemReady() const;

    // Mètode per activar el sistema des del nucli C++
    void setSystemReady(bool ready);

signals:
    void systemReadyChanged();

private:
    bool m_isSystemReady;
};

#endif // SYSTEMMANAGER_H
