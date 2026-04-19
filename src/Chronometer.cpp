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
    : QObject(parent),
    m_targetMs(0),
    m_timeText("00:00:00")
{
    m_timer = new QTimer(this);
    m_timer->setInterval(40);
    connect(m_timer, &QTimer::timeout, this, &Chronometer::updateTime);
}

void Chronometer::start(int mseconds) {
    // If mseconds is 0, we treat it as an infinite count-up
    m_targetMs = mseconds;
    m_targetReachedSent = false; // Reset the flag for the new unit/module
    m_elapsedMs = 0;
    m_elapsedTimer.start(); // Resets and starts the timer from 0
    m_timer->start();
    emit elapsedMsChanged();

    if (m_targetMs > 0) {
        qDebug() << "Chronometer started. Target set to:" << mseconds << "s";
    } else {
        qDebug() << "Chronometer started (Count-up mode)";
    }
}

void Chronometer::stop() {
    m_timer->stop();
}

void Chronometer::updateTime() {
    // Get the actual elapsed time since start() was called
    m_elapsedMs = static_cast<int>(m_elapsedTimer.elapsed());

    // Notify QML that the millisecond property has changed
    emit elapsedMsChanged();

    if (m_targetMs > 0)
        qDebug() << "[DEBUG]: Chronometer: Target: " << m_targetMs << "ms |  Elapsed" << m_elapsedMs << "ms | Sended: " << m_targetReachedSent;

    if (m_targetMs > 0 && m_elapsedMs >= m_targetMs && !m_targetReachedSent) {
        m_targetReachedSent = true; // Block further emissions for this cycle
        // m_timer->stop(); // Optional: Stop automatically on reach
        emit targetReached();
        qDebug() << "[DEBUG]: Chronometer: Target reached at" << m_targetMs << "ms";
    }

    // if (m_totalTime > 0) {
    //     m_progressValue = static_cast<double>(m_elapsedMs) / m_totalTime;
    // }

    // // Security límits
    // if (m_progressValue >= 1.0 && !m_maxReached) {
    //     // m_progressValue = 1.0;
    //     //stop();
    //     emit maxReached();
    //     m_maxReached = true;
    // }

    // // Update QML
    // emit progressValueChanged();

    // Update the text with the elapsed time
    formatTimeText(m_elapsedMs);
}

void Chronometer::formatTimeText(int totalMs) {
    int mins = (totalMs / 60000) % 60;
    int secs = (totalMs / 1000) % 60;
    int msecs = (totalMs % 1000) / 10;

    QString newTime  = QString("%1:%2:%3")
                     .arg(mins, 2, 10, QChar('0'))
                     .arg(secs, 2, 10, QChar('0'))
                     .arg(msecs, 2, 10, QChar('0'));

    if (m_timeText != newTime) {
        m_timeText = newTime;
        emit timeTextChanged();
    }
}
