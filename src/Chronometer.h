#ifndef CHRONOMETER_H
#define CHRONOMETER_H

#include <QObject>
#include <QTimer>
#include <QElapsedTimer>

class Chronometer : public QObject
{
    Q_OBJECT
    // Property to bind the formatted time string to QML
    Q_PROPERTY(QString timeText READ timeText NOTIFY timeTextChanged)

public:
    explicit Chronometer(QObject *parent = nullptr);

    // Starts countdown from given seconds
    Q_INVOKABLE void start(int seconds);
    Q_INVOKABLE void stop();

    QString timeText() const { return m_timeText; }

signals:
    void timeTextChanged();
    void finished();

private slots:
    void updateTime();

private:
    QTimer *m_timer;
    QElapsedTimer m_elapsedTimer;

    int m_totalTargetMs;
    QString m_timeText;

    void formatTimeText(int totalMs);
};

#endif // CHRONOMETER_H
