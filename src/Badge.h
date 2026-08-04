/****************************************************************************
** File: Badge.h
** Date: 19/5/2026
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
#ifndef BADGE_H
#define BADGE_H

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <functional>
#include "SystemLog.h"

/**
 * @brief Represents a single system Badge based on telemetry metrics.
 *
 * This class is data-agnostic and relies on an injected functional callback
 * to determine its unlocked state.
 */
class Badge : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString icon READ icon CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(bool unlocked READ unlocked NOTIFY unlockedChanged)

public:
    explicit Badge(QString name, QString icon, QString desc,
                         std::function<bool()> logic, QObject *parent = nullptr)
        : QObject(parent), m_name(name), m_icon(icon), m_description(desc),
        m_unlocked(false), m_checkLogic(logic) {}

    QString name() const { return m_name; }
    QString icon() const { return m_icon; }
    QString description() const { return m_description; }
    bool unlocked() const { return m_unlocked; }

    /**
     * @brief Resets the unlocked status to false.
     * This allows the UI to detect a false-to-true transition during synchronization,
     * triggering the highlight animations even if the badge was already earned.
     */
    Q_INVOKABLE void resetStatus() {
        if (m_unlocked) {
            m_unlocked = false;
            hInfo() << "Reset:" << m_name;
            emit unlockedChanged();
        }
    }

    /**
     * @brief Executes the injected logic to verify if the Badge is reached.
     * Only emits notification if the state transitions from locked to unlocked.
     */
    void updateState() {
        if (m_unlocked) return; // Optimization: Already achieved

        bool newState = m_checkLogic();
        if (newState != m_unlocked) {
            m_unlocked = newState;
            emit unlockedChanged();
        }
    }

signals:
    void unlockedChanged();

private:
    QString m_name;
    QString m_icon; // Lucide icon identifier
    QString m_description;
    bool m_unlocked;
    std::function<bool()> m_checkLogic;
};

#endif // BADGE_H
