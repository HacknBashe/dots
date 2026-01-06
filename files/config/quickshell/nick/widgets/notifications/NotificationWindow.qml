pragma ComponentBehavior: Bound

import "../config"
import "../services"
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Notification window positioned at top-right of primary screen
// Note: Using a single window instead of Variants to avoid duplicate widget instances
PanelWindow {
    id: window

    // Use primary screen only
    screen: Quickshell.screens[0]
    color: "transparent"

    // Position at top-right
    anchors {
        top: true
        right: true
    }

    margins {
        top: Appearance.spacing.large
        right: Appearance.spacing.large
    }

    // Fixed size - never changes
    implicitWidth: 400
    // Use a very large fixed height instead of calculating from screen
    implicitHeight: 2000

    WlrLayershell.namespace: "nick-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // ListView to handle removal transitions properly
    ListView {
        id: notificationList

        // Position at top of window
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        spacing: Appearance.spacing.normal

        // Disable scrolling
        interactive: false

        model: Notifications.server.trackedNotifications

        // Transition for adding items - slide in from right
        add: Transition {
            NumberAnimation {
                property: "x"
                from: 400
                to: 0
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }

        // Transition for removing items - slide out to right
        remove: Transition {
            NumberAnimation {
                property: "x"
                to: 400
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }

        // Smooth movement when items are added/removed
        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }

        delegate: NotificationWidget {
            required property var modelData
            notification: modelData

            // ListView requires explicit width
            width: notificationList.width
        }
    }
}
