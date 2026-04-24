/****************************************************************************
** File: Chronometer.h
** Date: 18/2/2026
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

#ifndef CHRONOMETER_H
#define CHRONOMETER_H

// #include "SystemManager.h"
#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QTimer>
#include <QElapsedTimer>

class Chronometer : public QObject
{
    Q_OBJECT
    // Property to bind the formatted time string to QML
    QML_ELEMENT  // WARNING: delete if not compile in the future
    Q_PROPERTY(int elapsedMs READ elapsedMs NOTIFY elapsedMsChanged)
    Q_PROPERTY(QString timeText READ timeText NOTIFY timeTextChanged)
    // Q_PROPERTY(double progressValue READ progressValue NOTIFY progressValueChanged)

public:
    explicit Chronometer(QObject *parent = nullptr);

    // Getters
    int elapsedMs() const { return m_elapsedMs; }
    QString timeText() const { return m_timeText; }

    /**
     * @brief Starts the timer sequence.
     * @param mseconds: If > 0, signals targetReached() upon completion.
     */
    Q_INVOKABLE void start(int mseconds);
    Q_INVOKABLE void startFrom(int startingMs, int targetMs);

    /**
     * @brief Halts the periodic update timer.
     */
    Q_INVOKABLE void stop();

    // double progressValue() const { return m_progressValue; }

signals:
    void elapsedMsChanged();
    void timeTextChanged();
    /**
     * @brief Emitted exactly once when elapsedMs >= targetMs.
     * Used for automated module transitions
     */
    void targetReached();

private slots:
    void updateTime();

private:
    // Core Timers
    QTimer *m_timer;
    QElapsedTimer m_elapsedTimer;

    // State Variables
    int m_targetMs; // Stores the limit in milliseconds
    int m_elapsedMs;
    int m_offsetMs;
    QString m_timeText;
    bool m_targetReachedSent; // Flag to ensure single emission per start() call

    // double m_progressValue = 0.0;
    // int m_elapsedTime = 0;
    // int m_totalTime = 60000;
    // bool m_maxReached = false;
    // int m_totalTargetMs;

    void formatTimeText(int totalMs);
};

#endif // CHRONOMETER_H
