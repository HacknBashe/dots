# Quickshell Notifications Guide

## Overview

Your Quickshell configuration now includes a complete notification system that displays desktop notifications in the top-right corner of your screen.

## Features

- ✅ **Icon theme support** - Properly displays app icons (Firefox, Brave, etc.)
- ✅ **Auto-dismiss** - Respects notification timeout (defaults to 5s)
- ✅ **Manual dismiss** - Click X to close anytime
- ✅ **Action buttons** - Shows buttons for notifications with actions
- ✅ **Urgency levels** - Visual indicators (red border for critical)
- ✅ **Relative timestamps** - Shows "now", "2m", "5h", etc.
- ✅ **Smooth animations** - Material Design slide/fade effects
- ✅ **Multi-monitor** - Works across all screens

## Testing Notifications

Use the `qsnot` command to send test notifications:

```bash
# Basic notification
qsnot "Hello" "World"

# With custom timeout (10 seconds)
qsnot "Important" "This stays longer" "dialog-information" 10000

# Different icon types
qsnot "Info" "Information message" "dialog-information"
qsnot "Warning" "Warning message" "dialog-warning"
qsnot "Error" "Error message" "dialog-error"
qsnot "Success" "Success message" "emblem-default"

# Firefox icon
qsnot "Firefox" "Download complete" "firefox"

# No icon (shows bell)
qsnot "No Icon" "This shows a bell" ""
```

## Browser Notifications

### Firefox
Firefox should work out of the box. If not:
1. Open Firefox settings
2. Go to Privacy & Security
3. Under Permissions → Notifications
4. Ensure notifications are enabled

### Brave/Chrome/Chromium

Brave and Chrome-based browsers use their own notification system by default. To fix:

**Method 1: Using the flag (Recommended)**
```bash
# Run the fix script
fix-brave-notifications
```

This will guide you through enabling native notifications.

**Method 2: Manual flag setting**
1. Open Brave/Chrome
2. Go to: `brave://flags` or `chrome://flags`
3. Search for: "native notifications"
4. Enable: "Enable native notifications"
5. Restart browser

**Method 3: Command line**
```bash
# Launch with native notifications enabled
brave --enable-features=NativeNotifications

# Or add to your shell alias:
alias brave='brave --enable-features=NativeNotifications'
```

**Method 4: Desktop file (Permanent)**
```bash
# Edit your desktop file
nano ~/.local/share/applications/brave-browser.desktop

# Change Exec lines from:
Exec=brave-browser %U

# To:
Exec=brave-browser --enable-features=NativeNotifications %U
```

### Other Browsers

**Chromium-based browsers** (Edge, Vivaldi, Opera, etc.):
- Use the same `--enable-features=NativeNotifications` flag
- Or enable via flags page

## Notification Properties

When an app sends a notification, it can include:

- **App name** - Shown in header
- **App icon** - Displayed as icon (or bell if missing)
- **Summary** - Bold title text
- **Body** - Main message content
- **Actions** - Buttons for user interaction
- **Urgency** - Low, Normal, or Critical
- **Timeout** - How long before auto-dismiss

## Troubleshooting

### Icons not showing
- **Fixed!** Icons now use IconImage which resolves icon theme names
- Should work for: firefox, brave, dialog-information, etc.

### Browser notifications not appearing
- Check if browser is using native notifications (see above)
- Test with: `qsnot "Test" "From quickshell"`
- Check quickshell logs: `tail -f ~/.config/dots/quickshell.log`

### Notifications not auto-dismissing
- Check notification timeout value
- Default is 5 seconds if not specified
- Critical notifications respect their timeout

### No notifications at all
- Ensure Quickshell is running: `ps aux | grep quickshell`
- Check D-Bus session: `busctl --user list | grep Notifications`
- Should show: `org.freedesktop.Notifications`

## Technical Details

### Architecture

```
services/Notifications.qml
  └─ NotificationServer (D-Bus service)
      └─ Tracks incoming notifications
      └─ Sets up auto-dismiss timers

components/NotificationWidget.qml
  └─ Individual notification card UI
      └─ IconImage for app icon (theme resolution)
      └─ Action buttons
      └─ Close button

modules/notifications/NotificationWindow.qml
  └─ Container window
      └─ Positioned top-right
      └─ Stacks notifications vertically
```

### D-Bus Service

Quickshell provides: `org.freedesktop.Notifications`

This is the standard freedesktop notification specification, meaning any application that sends desktop notifications will work with your Quickshell setup.

### Notification Flow

1. App sends notification via D-Bus
2. Quickshell NotificationServer receives it
3. Notification tracked (appears in UI)
4. Auto-dismiss timer started
5. User can manually dismiss or wait for timeout
6. Notification closed and removed from stack

## Customization

### Change Default Timeout

Edit `services/Notifications.qml`:
```qml
let timeout = notification.expireTimeout > 0 
    ? notification.expireTimeout * 1000 
    : 5000;  // Change this value (milliseconds)
```

### Change Notification Position

Edit `modules/notifications/NotificationWindow.qml`:
```qml
anchors {
    top: true      // Change to bottom: true for bottom-right
    right: true    // Change to left: true for left side
}
```

### Change Urgency Colors

Edit `components/NotificationWidget.qml`:
```qml
function getUrgencyColor(urgency) {
    switch(urgency) {
        case NotificationUrgency.Critical: return "#f38ba8"; // Red
        case NotificationUrgency.Low: return Qt.alpha(Colours.outline, 0.5);
        default: return Qt.alpha(Colours.outline, 0.2);
    }
}
```

## Files

- `services/Notifications.qml` - Notification server singleton
- `services/qmldir` - Service registration
- `components/NotificationWidget.qml` - Notification card component
- `components/qmldir` - Component registration
- `modules/notifications/NotificationWindow.qml` - Container window
- `modules/notifications/qmldir` - Module registration
- `shell.qml` - Shell entry point (includes NotificationWindow)

## Commands

- `qsnot <summary> [body] [icon] [timeout]` - Send test notification
- `fix-brave-notifications` - Guide to fix Brave notifications
