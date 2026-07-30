package org.aic.hyperhiit;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import android.os.Build;
import android.provider.Settings;

/**
 * Helper class to intercept Spotify broadcast intents.
 * Synchronizes metadata and playback state updates directly with the C++ core.
 *
 * Architecture:
 *   - Metadata (artist/track) and playback state (playing/paused) are received
 *     via Spotify broadcast intents (push model).
 *   - Playback position and duration are polled inside MediaNotificationListener,
 *     which holds an active Notification Listener binding and can safely call
 *     getActiveSessions() without a SecurityException.
 */
public class MediaReceiverHelper {

    private static final String TAG = "HYPER_HIIT";
    private static final String SPOTIFY_META_CHANGED     = "com.spotify.music.metadatachanged";
    private static final String SPOTIFY_PLAYBACK_CHANGED = "com.spotify.music.playbackstatechanged";

    // Static reference to prevent garbage collection by the Android runtime
    private static BroadcastReceiver mReceiver;

    // -------------------------------------------------------------------------
    // Native callbacks — implemented in MediaController.cpp
    // -------------------------------------------------------------------------

    /** Sends artist and track title to the C++ layer. */
    public static native void updateMetadata(String artist, String track);

    /** Notifies the C++ layer of a playback state change. */
    public static native void updatePlaybackState(boolean playing);

    /** Pushes position and duration (ms) to the C++ layer. Called from MediaNotificationListener. */
    public static native void updatePositionNative(long position, long duration);

    // -------------------------------------------------------------------------
    // Position sync — delegated to MediaNotificationListener
    // -------------------------------------------------------------------------

    /**
     * Starts the position polling loop.
     * Delegates to MediaNotificationListener, which holds an active
     * Notification Listener binding and can safely call getActiveSessions().
     *
     * Must be called after the listener service has connected
     * (i.e. from onListenerConnected).
     */
    public static void startPositionSync(Context context) {
        MediaNotificationListener.startPositionSync(context);
    }

    /**
     * Stops the position polling loop.
     */
    public static void stopPositionSync() {
        MediaNotificationListener.stopPositionSync();
    }

    // -------------------------------------------------------------------------
    // Metadata sync — Spotify broadcast receiver (push model)
    // -------------------------------------------------------------------------

    /**
     * Registers a BroadcastReceiver to intercept Spotify metadata and
     * playback state intents. Forwards data to C++ via JNI native callbacks.
     *
     * On Android 14+, RECEIVER_EXPORTED is required for third-party broadcasts.
     */
    public static void registerReceiver(Context context) {
        mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                if (action == null) return;

                if (action.equals(SPOTIFY_META_CHANGED)) {
                    String artist = intent.getStringExtra("artist");
                    String track  = intent.getStringExtra("track");
                    if (artist != null && track != null) {
                        Log.d(TAG, "Spotify metadata sync: " + artist + " - " + track);
                        updateMetadata(artist.toUpperCase(), track.toUpperCase());
                    }
                } else if (action.equals(SPOTIFY_PLAYBACK_CHANGED)) {
                    boolean isPlaying = intent.getBooleanExtra("playing", false);
                    Log.d(TAG, "Spotify playback state sync: " + (isPlaying ? "PLAYING" : "PAUSED"));
                    updatePlaybackState(isPlaying);
                }
            }
        };

        IntentFilter filter = new IntentFilter();
        filter.addAction(SPOTIFY_META_CHANGED);
        filter.addAction(SPOTIFY_PLAYBACK_CHANGED);

        // RECEIVER_EXPORTED required for receiving broadcasts from Spotify (third-party app)
        context.registerReceiver(mReceiver, filter, Context.RECEIVER_EXPORTED);
        Log.i(TAG, "Spotify broadcast receiver registered.");
    }

    /**
     * Unregisters the Spotify BroadcastReceiver.
     * Must be called on app shutdown (from MediaController's destructor) to avoid
     * a dangling receiver reference after the native/Qt runtime has been torn down.
     */
    public static void unregisterReceiver(Context context) {
        if (mReceiver == null) return;
        try {
            context.unregisterReceiver(mReceiver);
            Log.i(TAG, "Spotify broadcast receiver unregistered.");
        } catch (IllegalArgumentException e) {
            // Ja estava desregistrat o mai es va arribar a adjuntar — segur d'ignorar.
            Log.w(TAG, "unregisterReceiver: receiver was not registered.");
        } finally {
            mReceiver = null;
        }
    }

    /**
     * Checks whether the user has granted notification access for the Spotify
     * uplink listener (org.aic.hyperhiit.MediaNotificationListener).
     */
    public static boolean isNotificationAccessGranted(Context context) {
        String enabledListeners = Settings.Secure.getString(
            context.getContentResolver(), "enabled_notification_listeners");
        if (enabledListeners == null) return false;

        String myListener = context.getPackageName() + "/" + MediaNotificationListener.class.getName();
        return enabledListeners.contains(myListener);
    }

    /**
     * Opens the system settings screen where the user can grant access.
     * On Android 11+ (API 30), it jumps directly to this app's toggle;
     * on earlier versions, it opens the general "Notification access" list.
     */
    public static void openNotificationAccessSettings(Context context) {
        Intent intent = new Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            ComponentName component = new ComponentName(context, MediaNotificationListener.class);
            intent.putExtra(Settings.EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME,
                    component.flattenToString());
        }

        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }
}