import Quickshell
import Quickshell.Io
import "./modules/bar"
import "./modules/launcher"
import "./modules/notifications"

ShellRoot {
    BarWindow {
        id: barWindow
    }

    LauncherWindow {
        id: launcherWindow
    }

    NotificationWindow {
        id: notificationWindow
    }

    // File watcher for IPC toggle trigger
    FileView {
        id: ipcToggle
        path: "/tmp/quickshell-menu-toggle"
        watchChanges: true
        
        onFileChanged: {
            barWindow.toggleMenu()
        }
    }

    // File watcher for IPC close trigger
    FileView {
        id: ipcClose
        path: "/tmp/quickshell-menu-close"
        watchChanges: true
        
        onFileChanged: {
            barWindow.closeMenu()
        }
    }

    // File watcher for launcher toggle trigger
    FileView {
        id: launcherToggle
        path: "/tmp/quickshell-launcher-toggle"
        watchChanges: true
        
        onFileChanged: {
            launcherWindow.toggleLauncher()
        }
    }
}
