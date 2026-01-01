import Quickshell
import Quickshell.Io
import "./modules/bar"

ShellRoot {
    BarWindow {
        id: barWindow
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
}
