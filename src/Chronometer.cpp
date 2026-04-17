/****************************************************************************
** File: Chronometer.cpp
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

#include "Chronometer.h"
#include <QDebug>

Chronometer::Chronometer(QObject *parent)
    : QObject(parent), m_totalTargetMs(0), m_timeText("00:00:00")
{
    m_timer = new QTimer(this);
    m_timer->setInterval(40);
    connect(m_timer, &QTimer::timeout, this, &Chronometer::updateTime);
}

void Chronometer::start(int seconds) {
    // We ignore 'seconds' for now as we are counting UP from zero
    Q_UNUSED(seconds);

    m_elapsedTimer.start(); // Resets and starts the timer from 0
    m_timer->start();

    qDebug() << "Chronometer started (Count-up mode)";
}

void Chronometer::stop() {
    m_timer->stop();
}

void Chronometer::updateTime() {
    // Get the actual elapsed time since start() was called
    int elapsed = static_cast<int>(m_elapsedTimer.elapsed());

    if (m_totalTime > 0) {
        m_progressValue = static_cast<double>(elapsed) / m_totalTime;
    }

    // Security límits
    if (m_progressValue >= 1.0 && !m_maxReached) {
        // m_progressValue = 1.0;
        //stop();
        emit maxReached();
        m_maxReached = true;
    }

    // Update QML
    emit progressValueChanged();

    // Update the text with the elapsed time
    formatTimeText(elapsed);
}

void Chronometer::formatTimeText(int totalMs) {
    int mins = (totalMs / 60000) % 60;
    int secs = (totalMs / 1000) % 60;
    int msecs = (totalMs % 1000) / 10;

    m_timeText = QString("%1:%2:%3")
                     .arg(mins, 2, 10, QChar('0'))
                     .arg(secs, 2, 10, QChar('0'))
                     .arg(msecs, 2, 10, QChar('0'));

    emit timeTextChanged();
}
