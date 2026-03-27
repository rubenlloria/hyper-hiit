/****************************************************************************
** File: SystemManager.cpp
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
#include "SystemManager.h"
#include <QTimer>

SystemManager::SystemManager(QObject *parent)
    : QObject(parent), m_isSystemReady(false) {}

bool SystemManager::isSystemReady() const {
    return m_isSystemReady;
}

void SystemManager::setSystemReady(bool ready) {
    // [BOOT_DELAY]: 3s artificial latency for system warm-up simulation
    // Encapsulating this here keeps main.cpp focused on engine lifecycle
    QTimer::singleShot(3000, this, [this, ready]() {
        if (m_isSystemReady!= ready) {
            m_isSystemReady= ready;
            emit systemReadyChanged();
            qDebug() << "isSystemReady: " << ready;
        }
    });
}
