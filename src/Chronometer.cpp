#include "Chronometer.h"
#include <QTime>

Chronometer::Chronometer(QObject *parent) : QObject(parent) {
    m_refreshTimer = new QTimer(this);
    connect(m_refreshTimer, &QTimer::timeout, this, &Chronometer::timeChanged);
}

void Chronometer::start() {
    m_timer.start();
    m_refreshTimer->start(100); // Update every 100ms
}

QString Chronometer::timeDisplay() const {
    if (!m_timer.isValid()) return "00:00.0";
    qint64 ms = m_timer.elapsed();
    return QTime::fromMSecsSinceStartOfDay(ms).toString("mm:ss.z").left(7);
}
