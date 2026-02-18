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
