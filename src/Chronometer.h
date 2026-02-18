#ifndef CHRONOMETER_H
#define CHRONOMETER_H

#include <QObject>
#include <QElapsedTimer>
#include <QTimer>

class Chronometer : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString timeDisplay READ timeDisplay NOTIFY timeChanged)

public:
    explicit Chronometer(QObject *parent = nullptr);
    Q_INVOKABLE void start();
    QString timeDisplay() const;

signals:
    void timeChanged();

private:
    QElapsedTimer m_timer;
    QTimer *m_refreshTimer;
};

#endif
