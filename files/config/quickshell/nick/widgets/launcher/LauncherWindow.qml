pragma ComponentBehavior: Bound

import "../config"
import "../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

// Full-screen launcher overlay
Variants {
    id: variants
    model: Quickshell.screens

    // Function to toggle launcher on primary screen
    function toggleLauncher() {
        if (variants.instances.length > 0) {
            const firstScope = variants.instances[0];
            firstScope.launcherOpen = !firstScope.launcherOpen;
        }
    }

    // Function to close launcher
    function closeLauncher() {
        if (variants.instances.length > 0) {
            const firstScope = variants.instances[0];
            firstScope.launcherOpen = false;
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
                        scope.launcherOpen = false;
                    }
                }
            }
        }
    }
}
