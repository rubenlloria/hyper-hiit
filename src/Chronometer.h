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
    Q_PROPERTY(double progressValue READ progressValue NOTIFY progressValueChanged)

public:
    explicit Chronometer(QObject *parent = nullptr);

    int elapsedMs() const { return m_elapsedMs; }
    // Starts countdown from given seconds
    Q_INVOKABLE void start(int seconds);
    Q_INVOKABLE void stop();

    QString timeText() const { return m_timeText; }
    double progressValue() const { return m_progressValue; }

signals:
    void elapsedMsChanged();
    void timeTextChanged();
    void finished();
    void maxReached();
    void progressValueChanged();

private slots:
    void updateTime();

private:
    QTimer *m_timer;
    QElapsedTimer m_elapsedTimer;

    int m_totalTargetMs;
    int m_elapsedMs;
    QString m_timeText;

    double m_progressValue = 0.0;
    int m_elapsedTime = 0;
    int m_totalTime = 60000;
    bool m_maxReached = false;

    void formatTimeText(int totalMs);
};

#endif // CHRONOMETER_H
