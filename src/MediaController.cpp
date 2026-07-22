/****************************************************************************
** File: MediaController.cpp
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

// #define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include "MediaController.h"
#include "SystemLog.h"

static MediaController* g_instance = nullptr;

/**
 * @brief Initializes the MediaController with default telemetry values.
 */
MediaController::MediaController(QObject *parent)
    : QObject(parent)
    , m_trackProgress(0.0)
    , m_isPlaying(false)
{
    g_instance = this;

    // Initialize the JNI BroadcastReceiver for Spotify (Push metadata)
    setupSpotifyListener();

    // Initializing media uplink...
    hInfo() << "Media Uplink service initialized.";
    // updateActiveMetadata();

}
#ifdef Q_OS_ANDROID

// JNI Implementation of the native Java method
extern "C" JNIEXPORT void JNICALL
Java_org_aic_hyperhiit_MediaReceiverHelper_updateMetadata(JNIEnv *env, jclass clazz, jstring artist, jstring track) {
    Q_UNUSED(clazz);

    QString artistStr = QJniObject(artist).toString();
    QString trackStr = QJniObject(track).toString();

    hDebug() << "Artist: " << artistStr.toUpper() << " | Title: " << trackStr.toUpper();

    if (g_instance) {
        g_instance->setTrackMetadata(artistStr + " - " + trackStr);
    }
}

/**
 * JNI callback for external playback state changes.
 */
extern "C" JNIEXPORT void JNICALL
Java_org_aic_hyperhiit_MediaReceiverHelper_updatePlaybackState(JNIEnv *env, jclass clazz, jboolean playing) {
    Q_UNUSED(env);
    Q_UNUSED(clazz);

    if (g_instance) {
        g_instance->setPlaying(playing);
    }
}

/**
 * JNI callback received from Java every 400ms.
 */
extern "C" JNIEXPORT void JNICALL
Java_org_aic_hyperhiit_MediaReceiverHelper_updatePositionNative(JNIEnv *env, jclass clazz, jlong position, jlong duration) {
    // WARNING: Missing Notification Access permission!
    Q_UNUSED(env);
    Q_UNUSED(clazz);

    static int logThrottle = 0;
    if (logThrottle++ % 5 == 0) {
        hDebug() << "JNI Position sync: " << position << "/" << duration << "ms";
    }

    if (g_instance) {
        // Use the robust expression verified in our tactical sync
        g_instance->setTrackProgress(static_cast<double>(position), static_cast<double>(duration));
    }
}

#endif

void MediaController::setTrackMetadata(QString metadata){
    hInfo() << "#### METADATA:" << metadata;
    m_trackMetadata = metadata;
    emit trackMetadataChanged();
}

// Helper setter to update state and emit signal
void MediaController::setPlaying(bool playing) {
    if (m_isPlaying != playing) {
        m_isPlaying = playing;
        hInfo() << "External Playback Sync ->" << (m_isPlaying ? "PLAYING" : "PAUSED");
        emit playbackStatusChanged();
    }
}

void MediaController::setTrackProgress(double position, double duration) {
    // Apply the verified logic for trackProgress
    m_trackProgress = (position > 0.0 && duration > 0.0)
                          ? (position / duration)
                          : 0.0;
    hDebug() << "m_trackProgress:" << m_trackProgress;

    // Ensure the HUD reflects the change instantly
    emit trackProgressChanged();
}


void MediaController::setupSpotifyListener() {
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    QJniObject::callStaticMethod<void>(
        "org/aic/hyperhiit/MediaReceiverHelper",
        "registerReceiver",
        "(Landroid/content/Context;)V",
        context.object()
        );
#endif
}
/**
 * @brief Toggles between play and pause states.
 */
void MediaController::togglePlayback() {
    int keyCode = -1;
#ifdef Q_OS_ANDROID
    // 1. Get the Android context and AudioManager service
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    QJniObject audioManager = context.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QJniObject::fromString("audio").object<jstring>()
        );

    // 2. Retrieve the integer constant for PLAY_PAUSE
    // Using getStaticField<int> to avoid the previous crash
    keyCode = QJniObject::getStaticField<int>(
        "android/view/KeyEvent",
        "KEYCODE_MEDIA_PLAY_PAUSE"
        );

    // 3. Construct and dispatch the key events (Action DOWN and Up)
    // This is what actually triggers the pause/play in Spotify or System Player
    if (audioManager.isValid()) {
        QJniObject downEvent("android/view/KeyEvent", "(II)V", 0, keyCode); // ACTION_DOWN
        audioManager.callMethod<void>("dispatchMediaKeyEvent", "(Landroid/view/KeyEvent;)V", downEvent.object());

        QJniObject upEvent("android/view/KeyEvent", "(II)V", 1, keyCode);   // ACTION_UP
        audioManager.callMethod<void>("dispatchMediaKeyEvent", "(Landroid/view/KeyEvent;)V", upEvent.object());
    }
#else
#endif
    m_isPlaying = !m_isPlaying;
    hInfo() << "Playback status toggled: (" << keyCode << ")" << (m_isPlaying ? "PLAYING" : "PAUSED");
    emit playbackStatusChanged();
}

/**
 * @brief Advances to the next track in the sequence.
 */
void MediaController::nextTrack() {
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    QJniObject audioManager = context.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QJniObject::fromString("audio").object<jstring>()
        );

    // Get the constant for the NEXT track command
    int keyCode = QJniObject::getStaticField<int>(
        "android/view/KeyEvent",
        "KEYCODE_MEDIA_NEXT"
        );

    if (audioManager.isValid()) {
        // Dispatch ACTION_DOWN (0) and ACTION_UP (1) to simulate a full click
        QJniObject downEvent("android/view/KeyEvent", "(II)V", 0, keyCode);
        audioManager.callMethod<void>("dispatchMediaKeyEvent", "(Landroid/view/KeyEvent;)V", downEvent.object());

        QJniObject upEvent("android/view/KeyEvent", "(II)V", 1, keyCode);
        audioManager.callMethod<void>("dispatchMediaKeyEvent", "(Landroid/view/KeyEvent;)V", upEvent.object());

        hInfo() << "Media command dispatched: SKIP_NEXT (" << keyCode << ")";
    }
#endif
    m_trackProgress = 0.0; // Reset progress for the new track
    hInfo() << "Advancing to next audio track.";
    emit trackProgressChanged();
}

/**
 * @brief Returns to the previous track or restarts current one.
 */
void MediaController::previousTrack() {
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    QJniObject audioManager = context.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QJniObject::fromString("audio").object<jstring>()
        );

    // Get the constant for the PREVIOUS track command
    int keyCode = QJniObject::getStaticField<int>(
        "android/view/KeyEvent",
        "KEYCODE_MEDIA_PREVIOUS"
        );

    if (audioManager.isValid()) {
        QJniObject downEvent("android/view/KeyEvent", "(II)V", 0, keyCode);
        audioManager.callMethod<void>("dispatchMediaKeyEvent", "(Landroid/view/KeyEvent;)V", downEvent.object());

        QJniObject upEvent("android/view/KeyEvent", "(II)V", 1, keyCode);
        audioManager.callMethod<void>("dispatchMediaKeyEvent", "(Landroid/view/KeyEvent;)V", upEvent.object());

        hInfo() << "Media command dispatched: SKIP_PREVIOUS (" << keyCode << ")";
    }
#endif
    m_trackProgress = 0.0;
    hInfo() << "Reverting to previous audio track.";
    emit trackProgressChanged();
}

/**
 * @brief Internal update for media telemetry.
 * Place for platform-specific API hooks (Android JNI / MPRIS).
 */
void MediaController::updateMediaTelemetry() {
    if (m_isPlaying) {
        // Logic to increment m_trackProgress based on real track duration
        // emit trackProgressChanged();
    }
}

void MediaController::updatePlaybackProgress() {
#ifdef Q_OS_ANDROID
    jlong position, duration;
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    QJniObject sessionManager = context.callObjectMethod(
        "getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
        QJniObject::fromString("media_session").object<jstring>());

    QJniObject controllers = sessionManager.callObjectMethod(
        "getActiveSessions", "(Landroid/content/ComponentName;)Ljava/util/List;", nullptr);

    QJniEnvironment env;
    if (env->ExceptionCheck()) { env->ExceptionClear(); return; }

    if (controllers.isValid() && controllers.callMethod<jint>("size") > 0) {
        QJniObject controller = controllers.callObjectMethod("get", "(I)Ljava/lang/Object;", 0);

        // 1. Get Position (ms)
        QJniObject playbackState = controller.callObjectMethod(
            "getPlaybackState", "()Landroid/media/session/PlaybackState;");
        if (playbackState.isValid()) {
            position = playbackState.callMethod<jlong>("getPosition");
        }

        // 2. Get Duration (ms)
        QJniObject metadata = controller.callObjectMethod(
            "getMetadata", "()Landroid/media/MediaMetadata;");
        if (metadata.isValid()) {
            duration = metadata.callMethod<jlong>(
                "getLong", "(Ljava/lang/String;)J",
                QJniObject::fromString("android.media.metadata.DURATION").object<jstring>());
        }

        m_trackProgress = (position > 0.0 && duration > 0.0)
                              ? ( static_cast<double>(position) / static_cast<double>(duration) )
                              : 0.0;

        emit trackProgressChanged(); // Notifica al HUD
    }
#endif
}
