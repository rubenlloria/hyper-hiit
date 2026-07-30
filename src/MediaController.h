/****************************************************************************
** File: MediaController.h
** Date: 27/5/2026
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
#ifndef MEDIACONTROLLER_H
#define MEDIACONTROLLER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <QGuiApplication>

#ifdef Q_OS_ANDROID
#include <QtCore/QJniObject>
#include <QtCore/QCoreApplication>
#endif

/**
 * @brief Manages audio synchronization and system media playback.
 * Provides telemetry for the magenta neon progress bar.
 */
class MediaController : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(double trackProgress READ trackProgress NOTIFY trackProgressChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playbackStatusChanged)
    Q_PROPERTY(QString trackMetadata READ trackMetadata NOTIFY trackMetadataChanged)
    // Reactive property for QML bindings — updates automatically when it changes
    Q_PROPERTY(bool notificationAccessGranted READ notificationAccessGranted NOTIFY notificationAccessGrantedChanged)

public:
    explicit MediaController(QObject *parent = nullptr);
    ~MediaController();

    bool notificationAccessGranted() const { return m_notificationAccessGranted; }
    double trackProgress() const { return m_trackProgress; }
    bool isPlaying() const { return m_isPlaying; }
    QString trackMetadata() const { return m_trackMetadata; }

    // void updateActiveMetadata();
    void setTrackMetadata(QString metadata);
    void setPlaying(bool playing); // Helper setter for JNI and internal sync
    void setTrackProgress(double position, double duration);

    void setupSpotifyListener();
    void teardownSpotifyListener();

    // Tactical playback commands exposed to the HUD
    Q_INVOKABLE void togglePlayback();
    Q_INVOKABLE void nextTrack();
    Q_INVOKABLE void previousTrack();
    Q_INVOKABLE void updatePlaybackProgress();

    // Notification access permission (required for Spotify uplink)
    Q_INVOKABLE void requestNotificationAccess();
    Q_INVOKABLE void refreshNotificationAccessStatus();

signals:
    void trackProgressChanged();
    void playbackStatusChanged();
    void trackMetadataChanged();
    void notificationAccessGrantedChanged();


private:
    double m_trackProgress;
    bool m_isPlaying;
    bool m_notificationAccessGranted = false;
#ifdef Q_OS_ANDROID
    QString m_trackMetadata = "WAITING FOR UPLINK...";
#else
    QString m_trackMetadata = "NOT AVAILABLE ON DESKTOP";
#endif

    // Internal sync with the OS media session
    void updateMediaTelemetry();
    bool queryNotificationAccessFromSystem() const;

};

#endif // MEDIACONTROLLER_H
