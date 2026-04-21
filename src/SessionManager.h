/****************************************************************************
** File: SessionManager.h
** Date: 21/4/2026
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
#ifndef SESSIONMANAGER_H
#define SESSIONMANAGER_H

#include <QObject>
#include <QDateTime>
#include <QList>

class SessionManager : public QObject {
    Q_OBJECT
    // Properties for real-time UI synchronization [Source 28]
    Q_PROPERTY(float totalCalories READ totalCalories NOTIFY telemetryChanged)
    Q_PROPERTY(int activeModuleIndex READ activeModuleIndex WRITE setActiveModuleIndex NOTIFY activeModuleChanged)

public:
    explicit SessionManager(QObject *parent = nullptr);

    // Flow Control
    Q_INVOKABLE void startSession(int protocolId, int moduleCount);
    Q_INVOKABLE void recordModuleTime(int index, int seconds);
    Q_INVOKABLE QString getModulesLogString() const;
    Q_INVOKABLE int getStoredTime(int index) const;

    float totalCalories() const { return m_totalCalories; }
    int activeModuleIndex() const { return m_activeModuleIndex; }
    void setActiveModuleIndex(int index);

signals:
    void telemetryChanged();
    void activeModuleChanged();

private:
    int m_protocolId;
    qint64 m_startTimestamp;
    int m_activeModuleIndex;
    float m_totalCalories;
    QList<int> m_moduleDurations; // Stores seconds per module index
};

#endif // SESSIONMANAGER_H
