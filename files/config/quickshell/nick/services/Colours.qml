pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Color palette loaded from Nix-generated theme file (ANSI colors only)
Singleton {
    id: root

    // Semantic colors mapped to ANSI
    property color primary
    property color secondary
    property color tertiary
    property color quaternary
    property color quinary

    // Base colors
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

    // Load colors from theme file
    FileView {
        id: themeFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme-colors.json"

        onLoaded: {
            const colors = JSON.parse(text());
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

    // Helper to apply transparency layer
    function layer(c, layerLevel) {
        if (!transparencyEnabled)
            return c;
        if (layerLevel === 0)
            return Qt.alpha(c, transparencyBase);
        return Qt.alpha(c, transparencyLayers);
    }
}
