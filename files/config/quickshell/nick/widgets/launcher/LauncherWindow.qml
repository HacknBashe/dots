pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Full-screen launcher overlay
Variants {
    id: variants
    model: Quickshell.screens

    // Function to toggle launcher on active screen
    function toggleLauncher() {
        // Get the name of the currently focused monitor from Hyprland
        const focusedMonitorName = Hyprland.focusedMonitor?.name ?? "";
        
        // Find the launcher instance that matches the focused monitor
        const matchingInstance = variants.instances.find(
            inst => inst.modelData.name === focusedMonitorName
        );
        
        if (matchingInstance) {
            matchingInstance.launcherOpen = !matchingInstance.launcherOpen;
        }
    }

    // Function to close launcher on active screen
    function closeLauncher() {
        // Get the name of the currently focused monitor from Hyprland
        const focusedMonitorName = Hyprland.focusedMonitor?.name ?? "";
        
        // Find the launcher instance that matches the focused monitor
        const matchingInstance = variants.instances.find(
            inst => inst.modelData.name === focusedMonitorName
        );
        
        if (matchingInstance) {
            matchingInstance.launcherOpen = false;
        }
    }

    // Function to close all open launchers across all screens
    function closeAllLaunchers() {
        for (let i = 0; i < variants.instances.length; i++) {
            variants.instances[i].launcherOpen = false;
        }
    }

    Scope {
        id: scope

        required property ShellScreen modelData
        property bool launcherOpen: false
        property bool windowVisible: false

        // Timer to delay hiding the window until animation completes
        Timer {
            id: hideTimer
            interval: 400  // Match Appearance.anim.normal duration
            onTriggered: scope.windowVisible = false
        }

        // Show window immediately when opening, delay hiding when closing
        onLauncherOpenChanged: {
            if (launcherOpen) {
                hideTimer.stop();
                scope.windowVisible = true;
            } else {
                hideTimer.restart();
            }
        }

        // Launcher content window
        PanelWindow {
            id: launcherWindow

            screen: scope.modelData
            color: "transparent"
            visible: scope.windowVisible
            focusable: true

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "nick-launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: scope.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            // Center the launcher content
            Item {
                anchors.centerIn: parent

                LauncherContent {
                    id: launcher

                    anchors.centerIn: parent
                    open: scope.launcherOpen
                    screenHeight: launcherWindow.height

                    onCloseRequested: {
                        // Close all launchers across all screens
                        variants.closeAllLaunchers();
                    }
                }
            }
        }
    }
}
