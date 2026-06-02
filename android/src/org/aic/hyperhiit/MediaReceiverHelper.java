package org.aic.hyperhiit;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import android.media.session.MediaController;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.os.Handler;
import android.os.Looper;
import java.util.List;

/**
 * Helper class to intercept Spotify broadcast intents.
 * Synchronizes metadata updates directly with the C++ core.
 */
public class MediaReceiverHelper {
    private static BroadcastReceiver mReceiver;

    private static final String SPOTIFY_META_CHANGED = "com.spotify.music.metadatachanged";
    private static final String SPOTIFY_PLAYBACK_CHANGED = "com.spotify.music.playbackstatechanged";

    // Manage position
    private static final Handler mHandler = new Handler(Looper.getMainLooper());
    private static Runnable mPositionTask;
    private static final int UPDATE_INTERVAL = 400; // 400ms request

    // Native method to send data back to MediaController.cpp
    public static native void updateMetadata(String artist, String track);
    public static native void updatePlaybackState(boolean playing);

    // Native callback for position sync
    public static native void updatePositionNative(long position, long duration);

    public static void startPositionSync(Context context) {
        if (mPositionTask != null) return;

        MediaSessionManager sessionManager = (MediaSessionManager)
            context.getSystemService(Context.MEDIA_SESSION_SERVICE);

        mPositionTask = new Runnable() {
            @Override
            public void run() {
                try {
                    List<MediaController> controllers = sessionManager.getActiveSessions(null);
                    if (!controllers.isEmpty()) {
                        MediaController controller = controllers.get(0);

                        // Get metrics
                        long pos = controller.getPlaybackState().getPosition();
                        long dur = controller.getMetadata().getLong("android.media.metadata.DURATION");
                        Log.d("HYPER_HIIT", "Position telemetery sent: " + pos + "ms");

                        // Push to C++
                        updatePositionNative(pos, dur);
                    } else {
                        Log.w("HYPER_HIIT", "No active media sessions found.");
                    }
                } catch (SecurityException e) {
                    // Fail-safe if permission is missing
                    Log.e("HYPER_HIIT", "Missing Notification Access permission!");
                } finally {
                    mHandler.postDelayed(this, UPDATE_INTERVAL);
                }
            }
        };
        mHandler.post(mPositionTask);
    }

    // Metadata managing
    public static void registerReceiver(Context context) {
        mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();

                if (action.equals(SPOTIFY_META_CHANGED)) {
                    String artist = intent.getStringExtra("artist");
                    String track = intent.getStringExtra("track");

                    if (artist != null && track != null) {
                        Log.d("HYPER_HIIT", "Spotify Sync: " + artist + " - " + track);
                        // Trigger the native C++ callback
                        updateMetadata(artist.toUpperCase(), track.toUpperCase());
                    }
                }
                else if (action.equals(SPOTIFY_PLAYBACK_CHANGED)) {
                    // Extract the "playing" boolean from Spotify's broadcast
                    boolean isPlaying = intent.getBooleanExtra("playing", false);
                    updatePlaybackState(isPlaying);
                }
            }
        };

        IntentFilter filter = new IntentFilter();
        filter.addAction(SPOTIFY_META_CHANGED);
        filter.addAction(SPOTIFY_PLAYBACK_CHANGED);

        // In Android 14+, receivers must specify export behavior
        context.registerReceiver(mReceiver, filter, Context.RECEIVER_EXPORTED);
    }
}
