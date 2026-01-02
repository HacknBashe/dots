pragma ComponentBehavior: Bound

import "../config"
import "../services"
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property Notification notification

    // Track creation time for relative timestamp
    property date createdAt: new Date()
    property bool removing: false
    property bool justCreated: true
    
    // Unique instance ID to track which widget instance this is
    property string instanceId: {
        let random = Math.random().toString(36).substring(7);
        return root.notification.id + "-" + random;
    }
    
    width: 380
    // Height calculated from content
    height: contentColumn.implicitHeight + Appearance.padding.normal * 2
    
    // Clip content to prevent overflow during animations
    clip: true

    color: Colours.surfaceContainer
    radius: Appearance.rounding.normal
    border.width: 1
    border.color: Qt.alpha(Colours.outline, 0.2)  // Same subtle border for all
    
    // Disable all Behavior animations - ListView handles transitions
    Behavior on height { enabled: false }
    Behavior on width { enabled: false }
    Behavior on x { enabled: false }
    Behavior on y { enabled: false }
    Behavior on opacity { enabled: false }
    Behavior on scale { enabled: false }



    // Helper function to get urgency color
    function getUrgencyColor(urgency) {
        switch(urgency) {
            case NotificationUrgency.Critical: return "#f38ba8"; // Red
            case NotificationUrgency.Low: return Qt.alpha(Colours.outline, 0.5);
            default: return Qt.alpha(Colours.outline, 0.2);
        }
    }

    // Helper function to format relative time
    function formatRelativeTime() {
        let now = new Date();
        let diff = (now.getTime() - createdAt.getTime()) / 1000;  // seconds
        
        if (diff < 60) return "now";
        if (diff < 3600) return Math.floor(diff / 60) + "m";
        if (diff < 86400) return Math.floor(diff / 3600) + "h";
        return Math.floor(diff / 86400) + "d";
    }

    // Update relative time every minute
    property string relativeTime: formatRelativeTime()
    Timer {
        interval: 60000  // Update every minute
        running: true
        repeat: true
        onTriggered: root.relativeTime = root.formatRelativeTime()
    }

    // Main content column
    ColumnLayout {
        id: contentColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Appearance.padding.normal
        }

        spacing: Appearance.spacing.small
        
        // Disable all animations on the layout (only writable properties)
        Behavior on height { enabled: false }
        Behavior on width { enabled: false }
        
        onImplicitHeightChanged: {
            console.log("=== contentColumn implicitHeight CHANGED:", implicitHeight, "for notification:", root.notification.summary, "parent height:", root.height);
        }
        
        onHeightChanged: {
            console.log("=== contentColumn HEIGHT CHANGED:", height, "for notification:", root.notification.summary);
        }
        
        onWidthChanged: {
            console.log("=== contentColumn WIDTH CHANGED:", width, "for notification:", root.notification.summary);
        }

        // Top row: Icon, App Name, Close button, Timestamp
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            // App icon or default notification icon
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: Appearance.rounding.small
                color: !hasAppIcon ? Qt.alpha(Colours.primary, 0.2) : "transparent"
                
                property bool hasAppIcon: {
                    if (!root.notification) return false;
                    let icon = root.notification.appIcon;
                    let desktop = root.notification.desktopEntry;
                    let image = root.notification.image;
                    
                    // Has app icon if any of these are not empty
                    return (icon !== "" && icon !== undefined) || 
                           (desktop !== "" && desktop !== undefined) || 
                           (image !== "" && image !== undefined);
                }

                // App icon - uses IconImage with Quickshell.iconPath for theme resolution
                IconImage {
                    id: appIcon
                    anchors.centerIn: parent
                    implicitSize: 28
                    visible: parent.hasAppIcon
                    
                    source: {
                        if (!root.notification) return "";
                        
                        let appIconValue = root.notification.appIcon;
                        
                        // Check if appIcon is a URL (file://, http://, etc.)
                        let isUrl = appIconValue.startsWith("file://") || 
                                   appIconValue.startsWith("http://") || 
                                   appIconValue.startsWith("https://") ||
                                   appIconValue.startsWith("image://");
                        
                        // If it's a file:// URL to a chromium temp dir, skip it and use desktop entry
                        // These temp files are often deleted or don't exist
                        if (appIconValue.includes(".org.chromium.Chromium.") || 
                            appIconValue.includes("/tmp/") && appIconValue.includes("logo.png")) {
                            // Skip temp files, go straight to desktop entry
                            if (root.notification.desktopEntry !== "") {
                                let iconPath = Quickshell.iconPath(root.notification.desktopEntry, "");
                                if (iconPath !== "") {
                                    return iconPath;
                                }
                            }
                        }
                        
                        // Try appIcon
                        if (appIconValue !== "") {
                            if (isUrl) {
                                // For URLs, use directly
                                return appIconValue;
                            } else {
                                // For icon names, resolve through icon theme
                                let iconPath = Quickshell.iconPath(appIconValue, "");
                                if (iconPath !== "") {
                                    return iconPath;
                                }
                            }
                        }
                        
                        // Fall back to desktop entry name for icon resolution
                        if (root.notification.desktopEntry !== "") {
                            let iconPath = Quickshell.iconPath(root.notification.desktopEntry, "");
                            if (iconPath !== "") {
                                return iconPath;
                            }
                        }
                        
                        // Fall back to image field
                        if (root.notification.image !== "") {
                            return root.notification.image;
                        }
                        
                        return "";
                    }
                }

                // Fallback notification bell icon (or critical icon)
                Text {
                    anchors.centerIn: parent
                    text: (root.notification && root.notification.urgency === NotificationUrgency.Critical) ? "󱈸" : "󰂚"
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.larger
                    color: (root.notification && root.notification.urgency === NotificationUrgency.Critical) ? "#f38ba8" : Colours.primary
                    visible: !parent.hasAppIcon
                }
            }

            // App name
            Text {
                Layout.fillWidth: true
                text: root.notification.appName
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.normal
                color: Colours.secondary
                elide: Text.ElideRight
            }

            // Timestamp
            Text {
                text: root.relativeTime
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.small
                color: Colours.outline
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: Appearance.rounding.full
                color: closeMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"  // Close icon
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.normal
                    color: Colours.textOnSurface
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        root.notification.dismiss();
                        mouse.accepted = true;
                    }
                    
                    onPressed: mouse.accepted = true
                    onReleased: mouse.accepted = true
                }
            }
        }

        // Summary (title)
        Text {
            Layout.fillWidth: true
            text: root.notification.summary
            font.family: Appearance.font.sans
            font.pixelSize: Appearance.font.larger
            font.weight: Font.Bold
            color: root.notification.urgency === NotificationUrgency.Critical ? "#f38ba8" : Colours.primary
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            visible: text !== ""
        }

        // Body text
        Text {
            Layout.fillWidth: true
            text: root.notification.body
            font.family: Appearance.font.sans
            font.pixelSize: Appearance.font.normal
            color: Colours.textOnSurface
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
            textFormat: Text.PlainText  // Disable markup for security
            visible: text !== ""
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small
            visible: root.notification.actions.length > 0

            Repeater {
                model: root.notification.actions

                Rectangle {
                    required property var modelData

                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    Layout.maximumWidth: (root.width - Appearance.padding.normal * 2 - Appearance.spacing.small * (root.notification.actions.length - 1)) / root.notification.actions.length

                    radius: Appearance.rounding.small
                    color: actionMouseArea.containsMouse ? Qt.alpha(Colours.primary, 0.2) : Qt.alpha(Colours.surface, 0.5)
                    border.width: 1
                    border.color: Qt.alpha(Colours.primary, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData.text
                        font.family: Appearance.font.sans
                        font.pixelSize: Appearance.font.normal
                        color: Colours.primary
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: actionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            parent.modelData.invoke();
                            mouse.accepted = true;
                        }
                        
                        onPressed: mouse.accepted = true
                        onReleased: mouse.accepted = true
                    }
                }
            }
        }
    }

    // Removed full-widget hover MouseArea - was causing interference with close button
    // Individual buttons have their own hover states which is sufficient
}
