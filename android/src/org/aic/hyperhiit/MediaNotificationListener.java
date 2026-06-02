// MediaNotificationListener.java
// Minimal NotificationListenerService stub.
// Its sole purpose is to exist as a registered service so that
// MediaSessionManager.getActiveSessions() accepts our ComponentName
// and grants access without MEDIA_CONTENT_CONTROL (system-only).
package org.aic.hyperhiit;

import android.service.notification.NotificationListenerService;

public class MediaNotificationListener extends NotificationListenerService {
    // No implementation needed.
    // Registration in AndroidManifest.xml is sufficient.
}
