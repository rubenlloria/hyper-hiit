package org.aic.hyperhiit;

import android.content.ComponentName;
import android.content.Context;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.os.Handler;
import android.os.Looper;
import android.service.notification.NotificationListenerService;
import android.util.Log;
import java.util.List;

/**
 * Notification Listener Service stub.
 *
 * Serves two purposes:
 *   1. Its registration in AndroidManifest.xml grants this app the right to call
 *      MediaSessionManager.getActiveSessions() without MEDIA_CONTENT_CONTROL.
 *   2. Once the system binds the service (onListenerConnected), it starts a
 *      400ms polling loop that pushes position/duration data to C++ via JNI.
 */
public class MediaNotificationListener extends NotificationListenerService {

    private static final String TAG             = "HYPER_HIIT";
    private static final int    UPDATE_INTERVAL = 400;

    private static Handler  mHandler;
    private static Runnable mPositionTask;
    private static MediaSessionManager mSessionManager;

    // -------------------------------------------------------------------------
    // Service lifecycle
    // -------------------------------------------------------------------------

    @Override
    public void onListenerConnected() {
        super.onListenerConnected();
        Log.i(TAG, "Notification Listener connected — starting position sync.");
        mSessionManager = (MediaSessionManager) getSystemService(Context.MEDIA_SESSION_SERVICE);
        mHandler = new Handler(Looper.getMainLooper());
        startPositionSync(this);
    }

    @Override
    public void onListenerDisconnected() {
        super.onListenerDisconnected();
        Log.w(TAG, "Notification Listener disconnected — stopping position sync.");
        stopPositionSync();
    }

    // -------------------------------------------------------------------------
    // Position polling
    // -------------------------------------------------------------------------

    /**
     * Starts the 400ms polling loop for playback position and duration.
     * Safe to call only after onListenerConnected, where the binding is active.
     */
    static void startPositionSync(Context context) {
        if (mPositionTask != null) return;
        if (mHandler == null) mHandler = new Handler(Looper.getMainLooper());

        mPositionTask = new Runnable() {
            @Override
            public void run() {
                try {
                    // ComponentName must point to this service — this is what grants access
                    List<MediaController> controllers = mSessionManager.getActiveSessions(
                        new ComponentName(context, MediaNotificationListener.class));

                    if (!controllers.isEmpty()) {
                        MediaController controller = controllers.get(0);
                        PlaybackState state    = controller.getPlaybackState();
                        MediaMetadata metadata = controller.getMetadata();

                        if (state != null && metadata != null) {
                            long pos = state.getPosition();
                            long dur = metadata.getLong(MediaMetadata.METADATA_KEY_DURATION);
                            Log.d(TAG, "Position telemetry: " + pos + "ms / " + dur + "ms");
                            MediaReceiverHelper.updatePositionNative(pos, dur);
                        }
                    } else {
                        Log.w(TAG, "No active media sessions found.");
                    }
                } catch (SecurityException e) {
                    // Should not happen inside onListenerConnected, but guard anyway
                    Log.e(TAG, "getActiveSessions failed — permission may have been revoked.");
                    stopPositionSync();
                } catch (Exception e) {
                    Log.e(TAG, "Position sync error: " + e.getMessage());
                } finally {
                    mHandler.postDelayed(this, UPDATE_INTERVAL);
                }
            }
        };

        mHandler.post(mPositionTask);
        Log.i(TAG, "Position sync loop started (" + UPDATE_INTERVAL + "ms interval).");
    }

    /**
     * Stops the polling loop and releases the Runnable reference.
     */
    static void stopPositionSync() {
        if (mHandler != null && mPositionTask != null) {
            mHandler.removeCallbacks(mPositionTask);
            mPositionTask = null;
            Log.i(TAG, "Position sync loop stopped.");
        }
    }
}