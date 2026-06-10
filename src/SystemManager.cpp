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

SystemManager::SystemManager(DatabaseManager *db, QObject *parent)
    : QObject(parent), m_systemReady(false) {
    if (!m_db) {
        hCritical() << "SystemManager initialized without Database access.";
    } else {
        loadSystemConfig();
    }
}

void SystemManager::loadSystemConfig() {
    if (!m_db) return;

    // Loading values from database with defaults
    m_systemScanline = (m_db->getConfig("system_scanline", "1") == "1");
    m_systemAudio = (m_db->getConfig("system_audio", "1") == "1");
    m_systemTheme = m_db->getConfig("system_theme", "0").toInt();

    emit systemScanlineChanged();
    emit systemAudioChanged();
    hDebug() << "systemThemeChanged";
    emit systemThemeChanged();
}

/**
 * Simulates system warm-up with a controlled delay for visual feedback.
 */
void SystemManager::setSystemReady(bool ready) {
    // [BOOT_DELAY]: 3s artificial latency for system warm-up simulation
    // Encapsulating this here keeps main.cpp focused on engine lifecycle
    // TODO: delete timer for a real time experience
    QTimer::singleShot(3000, this, [this, ready]() {
        if (m_systemReady!= ready) {
            m_systemReady= ready;
            emit systemReadyChanged();
            hInfo() << "System operational status changed to:" << ready;
        }
    });
}

void SystemManager::setSystemScanline(bool enabled) {
    hDebug() << QString("m_systemScanline: %1, enabled: %2").arg(m_systemScanline).arg(enabled);
    if (m_systemScanline == enabled) return;

    m_systemScanline = enabled;
    m_db->setConfig("system_scanline", enabled ? "1" : "0");
    emit systemScanlineChanged();
}

void SystemManager::setSystemAudio(bool enabled) {
    if (m_systemAudio == enabled) return;

    m_systemAudio = enabled;
    m_db->setConfig("system_audio", enabled ? "1" : "0");
    emit systemAudioChanged();
}

void SystemManager::setSystemTheme(int themeIndex) {
    if (m_systemTheme == themeIndex) return;

    m_systemTheme = themeIndex;
    m_db->setConfig("system_theme", QString::number(themeIndex));
    emit systemThemeChanged();
}

/**
 * Fetches global parameters (e.g., neon_theme, scanline_render) from DB.
 */
QString SystemManager::getConfig(const QString &key, const QString &defaultValue) {
    if (!m_db) {
        hWarning() << "Database not ready.";
        return defaultValue;
    }

    QString value = m_db->getConfig(key, defaultValue);
    hDebug() << "System parameter retrieved | Key:" << key << "Value:" << value;
    return value;
}

/**
 * Persists system environment settings directly to the configuration table.
 */
void SystemManager::setConfig(const QString &key, const QString &value) {
    // if (!m_db) {
    //     hWarning() << "Database not ready.";
    //     return;
    // }

    if        (key == "systemScanline") {
        setSystemScanline(value == "true");
    } else if (key == "systemAudio") {
        setSystemAudio(value == "true");
    } else if (key == "systemTheme") {
        setSystemTheme(value.toInt());
    } else {
        hWarning() << "Unknown configuration key received:" << key;
    }

    // m_db->setConfig(key, value);
    hInfo() << "System parameter synchronized | Key:" << key << "Value:" << value;
}

