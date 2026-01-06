pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Combined configuration loaded from Nix-generated config file
// Includes both monitor settings and color palette
Singleton {
    id: root

    // Monitor configuration properties
    property string monitor1Name: ""
    property string monitor2Name: ""
    property string barMonitor: ""
    property string lockCommand: ""

    // Color palette - Semantic colors
    property color primary
    property color secondary
    property color tertiary
    property color quaternary
    property color quinary

    // Color palette - Base colors
    property color background
    property color foreground
    property color surface
    property color surfaceContainer
    property color textOnBackground
    property color textOnSurface
    property color textOnPrimary
    property color outline
    property color shadow

    // Transparency settings
    readonly property bool transparencyEnabled: true
    readonly property real transparencyBase: 0.7
    readonly property real transparencyLayers: 0.4

    // Load configuration from Nix-generated JSON file
    FileView {
        id: configFile
        path: Quickshell.env("HOME") + "/.config/quickshell/nix-config.json"

        onLoaded: {
            const config = JSON.parse(text());
            
            // Load monitor configuration
            const monitors = config.monitors;
            root.monitor1Name = monitors.monitor1Name;
            root.monitor2Name = monitors.monitor2Name;
            root.barMonitor = monitors.barMonitor;
            root.lockCommand = monitors.lockCommand;
            
            // Load color palette
            const colors = config.colors;
            // Semantic colors
            root.primary = colors.primary;
            root.secondary = colors.secondary;
            root.tertiary = colors.tertiary;
            root.quaternary = colors.quaternary;
            root.quinary = colors.quinary;

            // Base colors
            root.background = colors.background;
            root.foreground = colors.foreground;
            root.surface = colors.surface;
            root.surfaceContainer = colors.surfaceContainer;
            root.textOnBackground = colors.textOnBackground;
            root.textOnSurface = colors.textOnSurface;
            root.textOnPrimary = colors.textOnPrimary;
            root.outline = colors.outline;
            root.shadow = colors.shadow;
        }
    }

    // Helper function to apply transparency layer
    function layer(c, layerLevel) {
        if (!transparencyEnabled)
            return c;
        if (layerLevel === 0)
            return Qt.alpha(c, transparencyBase);
        return Qt.alpha(c, transparencyLayers);
    }
}
