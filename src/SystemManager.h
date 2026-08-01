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

#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include "DatabaseManager.h"
#include "SystemLog.h"
#include <QObject>
#include <QTimer>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <qjniobject.h>
#endif

class SystemManager : public QObject {
    Q_OBJECT
    // Property for global system status synchronization
    Q_PROPERTY(bool systemReady READ systemReady WRITE setSystemReady NOTIFY systemReadyChanged)
    Q_PROPERTY(bool systemScanline READ systemScanline WRITE setSystemScanline NOTIFY systemScanlineChanged)
    Q_PROPERTY(bool systemAudio READ systemAudio WRITE setSystemAudio NOTIFY systemAudioChanged)
    Q_PROPERTY(bool exitConfirm READ exitConfirm WRITE setExitConfirm NOTIFY exitConfirmChanged)
    Q_PROPERTY(bool systemLanguage READ systemLanguage WRITE setSystemLanguage NOTIFY systemLanguageChanged)
    Q_PROPERTY(int systemTheme READ systemTheme WRITE setSystemTheme NOTIFY systemThemeChanged)

public:
    explicit SystemManager(DatabaseManager *db, QObject *parent = nullptr);

    void loadSystemConfig();

    bool systemReady() const { return m_systemReady; }
    void setSystemReady(bool ready);

    bool systemScanline() const { return m_systemScanline; }
    void setSystemScanline(bool enabled);

    bool systemAudio() const { return m_systemAudio; }
    void setSystemAudio(bool enabled);

    bool exitConfirm() const { return m_exitConfirm; }
    void setExitConfirm(bool enabled);

    bool systemLanguage() const { return m_systemLanguage; }
    void setSystemLanguage(bool enabled);

    int systemTheme() const { return m_systemTheme; }
    void setSystemTheme(int themeIndex);

    // --- System Configuration Uplink ---

    /**
     * @brief Retrieves a system-wide setting from the persistent store.
     * @param key Unique identifier for the parameter.
     * @param defaultValue Fallback if key is not found.
     */
    Q_INVOKABLE QString getConfig(const QString &key, const QString &defaultValue = "");

    /**
     * @brief Updates or creates a global system configuration entry.
     */
    Q_INVOKABLE void setConfig(const QString &key, const QString &value);

    /**
     * @brief Converts a unit type integer into its string representation.
     * @param unitType The integer ID (0: seconds, 1: reps, 2: breaths, 3: meters).
     * @param useFullAbbreviation If true, returns 'sec.' instead of 's'.
     * @return The formatted string label.
     */
    Q_INVOKABLE static QString getUnitLabel(int unitType, bool useFullAbbreviation = false);

    /**
     * @brief Manages the Android window flag to keep the screen active.
     * @param enabled If true, sets FLAG_KEEP_SCREEN_ON.
     */
    Q_INVOKABLE void keepScreenOn(bool enabled);

signals:
    void systemReadyChanged();
    void systemScanlineChanged();
    void systemAudioChanged();
    void exitConfirmChanged();
    void systemLanguageChanged();
    void systemThemeChanged();

private:
    DatabaseManager *m_db; // Database reference
    bool m_systemReady;
    bool m_systemScanline;
    bool m_systemAudio;
    bool m_exitConfirm;
    bool m_systemLanguage;
    int m_systemTheme;
};

#endif // SYSTEMMANAGER_H
