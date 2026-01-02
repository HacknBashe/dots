pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // The notification server instance
    property NotificationServer server: NotificationServer {
        // Enable capabilities we support
        actionsSupported: true
        imageSupported: true
        bodySupported: true
        bodyMarkupSupported: false  // Keep markup disabled for safety
        bodyImagesSupported: false
        bodyHyperlinksSupported: false
        actionIconsSupported: true
        persistenceSupported: true
        inlineReplySupported: false
        keepOnReload: true

        // Handle incoming notifications
        onNotification: notification => {
            console.log("=== NEW NOTIFICATION:", notification.summary);
            console.log("    appIcon:", notification.appIcon);
            console.log("    desktopEntry:", notification.desktopEntry);
            console.log("    image:", notification.image);
            console.log("    urgency:", notification.urgency);
            
            // Track the notification so it appears in trackedNotifications
            notification.tracked = true;
            
            // Set up auto-dismiss timer
            let timeout = notification.expireTimeout > 0 
                ? notification.expireTimeout * 1000 
                : 5000;  // Default 5 seconds
            
            // Create a timer component for this notification
            let timer = notificationDismissTimer.createObject(root, {
                notification: notification,
                interval: timeout
            });
            timer.start();
        }
    }

    // Helper component for notification dismiss timers
    Component {
        id: notificationDismissTimer
        
        Timer {
            property var notification: null
            
            running: false
            repeat: false
            
            onTriggered: {
                if (notification !== null && notification.tracked) {
                    try {
                        notification.expire();
                    } catch (e) {
                        // Notification already closed
                    }
                }
                destroy();
            }
        }
    }
}
