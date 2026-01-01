pragma Singleton

import Quickshell
import QtQuick

// Simplified colour palette - can be expanded later to use Material 3 dynamic colours
Singleton {
    id: root

    // Catppuccin Mocha inspired defaults - flattened palette
    // Note: Using "text" prefix instead of "on" to avoid QML signal handler conflict
    readonly property color background: "#1e1e2e"
    readonly property color surface: "#313244"
    readonly property color surfaceContainer: "#45475a"
    readonly property color primary: "#cba6f7"
    readonly property color secondary: "#f5c2e7"
    readonly property color textOnBackground: "#cdd6f4"
    readonly property color textOnSurface: "#cdd6f4"
    readonly property color textOnPrimary: "#1e1e2e"
    readonly property color outline: "#6c7086"
    readonly property color shadow: "#000000"

    // Transparency settings
    readonly property bool transparencyEnabled: false
    readonly property real transparencyBase: 0.85
    readonly property real transparencyLayers: 0.4

    // Helper to apply transparency layer
    function layer(c, layerLevel) {
        if (!transparencyEnabled) return c;
        if (layerLevel === 0) return Qt.alpha(c, transparencyBase);
        return Qt.alpha(c, transparencyLayers);
    }
}
