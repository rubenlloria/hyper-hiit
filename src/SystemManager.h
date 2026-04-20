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

#ifndef hDebug
#ifdef HH_DEBUG
#define hDebug() qDebug() << "[DEBUG]: " << Q_FUNC_INFO
#else
#define hDebug() if(false) qDebug()
#endif
#endif

#ifndef hInfo
#ifdef HH_INFO
#define hInfo() qInfo() << "[INFO]: " << Q_FUNC_INFO
#else
#define hInfo() if(false) qInfo()
#endif
#endif

#ifndef hWarning
#ifdef HH_WARNING
#define hWarning() qCritical() << "[WARNING]: " << Q_FUNC_INFO
#else
#define hWarning() if(false) qCritical()
#endif
#endif

#ifndef hCritical
#ifdef HH_CRITICAL
#define hCritical() qCritical() << "[DEBUG]: " << Q_FUNC_INFO
#else
#define hCritical() if(false) qCritical()
#endif
#endif

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
