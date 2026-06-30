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

class DatabaseManager;

class SessionManager : public QObject {
    Q_OBJECT
    // Properties for real-time UI synchronization [Source 28]
    Q_PROPERTY(float totalCalories READ totalCalories NOTIFY telemetryChanged)
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(float userWeight READ userWeight WRITE setUserWeight NOTIFY userWeightChanged)
    Q_PROPERTY(int userHeight READ userHeight WRITE setUserHeight NOTIFY userHeightChanged)
    Q_PROPERTY(int userAge READ userAge WRITE setUserAge NOTIFY userAgeChanged)
    Q_PROPERTY(int userSex READ userSex WRITE setUserSex NOTIFY userSexChanged)
    Q_PROPERTY(int userRank READ userRank WRITE setUserRank NOTIFY userRankChanged)
    Q_PROPERTY(int activeModuleIndex READ activeModuleIndex WRITE setActiveModuleIndex NOTIFY activeModuleChanged)
    Q_PROPERTY(int activeSessionId READ activeSessionId)
    Q_PROPERTY(QVariantMap activeDirectiveInfo READ activeDirectiveInfo WRITE setActiveDirectiveInfo NOTIFY activeDirectiveInfoChanged)

public:
    explicit SessionManager(DatabaseManager *db, QObject *parent = nullptr);

    // Flow Control
    Q_INVOKABLE void startSession(int protocolId,  const QVariantList &executionList);
    Q_INVOKABLE void recordModuleCheckpoint(int index, int globalSeconds);
    Q_INVOKABLE QString getModulesLogString() const;
    Q_INVOKABLE int getStoredTime(int index) const;
    Q_INVOKABLE void updateSessionCalories();

    /**
     * @brief Persists the current session buffer to the SQL database.
     * Converts the checkpoint array into a serialized string for Level 4 storage [Source 13, 18].
     */
    void extracted(QStringList &telemetryList);

    Q_INVOKABLE int saveSession();

    // Invokable from QML when entering the Briefing or starting the session
    Q_INVOKABLE QList<int> loadLastSessionData(int protocolId);

    void loadUserConfig(); // Syncs local memory with DB values

    /**
     * @brief Updates or creates a user configuration entry.
     */
    Q_INVOKABLE void setConfig(const QString &key, const QString &value);

    float totalCalories() const { return m_totalCalories; }

    QString userName() const { return m_userName; }
    void setUserName(const QString &name);

    float userWeight() const { return m_userWeight; }
    void setUserWeight(float weight);

    int userHeight() const { return m_userHeight; }
    void setUserHeight(int height);

    int userAge() const { return m_userAge; }
    void setUserAge(int age);

    int userSex() const { return m_userSex; }
    void setUserSex(int sex);

    int userRank() const { return m_userRank; }
    void setUserRank(int Rank);

    int activeModuleIndex() const { return m_activeModuleIndex; }
    void setActiveModuleIndex(int index);
    int activeSessionId() const { return m_sessionId; }
    QVariantMap activeDirectiveInfo() const { return m_activeDirectiveInfo; }
    Q_INVOKABLE void setActiveDirectiveInfo(const QVariantMap &info);

signals:
    void telemetryChanged();
    void userNameChanged();
    void userWeightChanged();
    void userHeightChanged();
    void userAgeChanged();
    void userSexChanged();
    void userRankChanged();
    void activeModuleChanged();
    void sessionSaved();
    void activeDirectiveInfoChanged();

private:
    int m_protocolId;
    int m_sessionId;
    qint64 m_startTimestamp;
    int m_activeModuleIndex;
    float m_totalCalories;
    QString m_userName;
    float m_userWeight;
    int m_userHeight;
    int m_userAge;
    bool m_userIsMale; // DELETEME
    int m_userSex;
    int m_userRank;
    double m_totalMetScore;
    double m_speed;
    DatabaseManager *m_db = nullptr;
    QVariantList m_executionList;
    QList<float> m_moduleMetFactors;
    QList<int> m_moduleDurations; // Stores seconds per module index
    // Stores the checkpoints (ms) of the previous session for comparison
    QList<int> m_lastSessionDurations;
    QVariantMap m_activeDirectiveInfo;
};

#endif // SESSIONMANAGER_H
