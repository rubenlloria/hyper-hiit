/****************************************************************************
** File: Chronometer.cpp
** Date: 22/02/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/

#define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include "SystemLog.h"
#include "Chronometer.h"

Chronometer::Chronometer(QObject *parent)
    : QObject(parent),
    m_targetMs(0),
    m_timeText("00:00:00")
{
    m_timer = new QTimer(this);
    m_timer->setInterval(40);
    connect(m_timer, &QTimer::timeout, this, &Chronometer::updateTime);
}

void Chronometer::start(int mSeconds) {
    // If mSeconds is 0, we treat it as an infinite count-up
    startFrom(0, mSeconds);
}

/**
 * Starts the chronometer from a specific time offset.
 * Vital for recovering module telemetry during session navigation.
 */
void Chronometer::startFrom(int startingMs, int targetMs) {
    m_targetMs = targetMs;
    m_offsetMs = startingMs; // Capture the recovery time
    m_targetReachedSent = false; // Reset the flag for the new unit/module
    m_elapsedMs = 0;
    m_startTimeRTC = QDateTime::currentMSecsSinceEpoch(); // Resets and starts the timer from now

    m_timer->start();
    emit elapsedMsChanged();

    if (m_targetMs > 0) {
        hDebug() << "Chronometer started from: " << m_offsetMs << ". Target set to:" << targetMs << "s";
    } else {
        hDebug() << "Chronometer started (Count-up mode)";
    }
}

void Chronometer::stop() {
    m_timer->stop();
}

void Chronometer::updateTime() {
    // Get the actual elapsed time since start() was called
    qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    m_elapsedMs = static_cast<int>(currentTime - m_startTimeRTC);
    m_elapsedMs += m_offsetMs;

    // Notify QML that the millisecond property has changed
    emit elapsedMsChanged();

    if (m_targetMs > 0 && m_elapsedMs >= m_targetMs && !m_targetReachedSent) {
        m_targetReachedSent = true; // Block further emissions for this cycle
        // m_timer->stop(); // Optional: Stop automatically on reach
        emit targetReached();
        hInfo() << "Target reached at" << m_targetMs << "ms";
    }

    // Update the text with the elapsed time
    formatTimeText(m_elapsedMs);
}

void Chronometer::formatTimeText(int totalMs) {
    int hours = (totalMs / 3600000);          // 3.600.000 ms = 1 hour
    int mins = (totalMs / 60000) % 60;
    int secs = (totalMs / 1000) % 60;
    int msecs = (totalMs % 1000) / 10;
    QString newTime = "";

    if  (hours > 0) {
        newTime  = QString("%1:%2:%3:%4")
              .arg(hours)
              .arg(mins, 2, 10, QChar('0'))
             .arg(secs, 2, 10, QChar('0'))
             .arg(msecs, 2, 10, QChar('0'));
    } else {
        newTime  = QString("%1:%2:%3")
            .arg(mins, 2, 10, QChar('0'))
            .arg(secs, 2, 10, QChar('0'))
            .arg(msecs, 2, 10, QChar('0'));
    }
    if (m_timeText != newTime) {
        m_timeText = newTime;

        emit timeTextChanged();
    }
}
