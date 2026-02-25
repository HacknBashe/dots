pragma Singleton

import Quickshell

Singleton {
    id: root

    // Category to Nerd Font icon mapping
    // These map desktop entry categories to appropriate icons
    readonly property var categoryIcons: ({
            // Browsers & Web
            "WebBrowser": "󰖟",
            "Network": "󰖟",

            // Development
            "Development": "",
            "IDE": "",
            "TextEditor": "󰷈",

            // Terminal
            "TerminalEmulator": "",
            "ConsoleOnly": "",

            // Files
            "FileTools": "󰉋",
            "FileManager": "󰉋",
            "Filesystem": "󰉋",
            "FileTransfer": "󰉋",

            // Media
            "Audio": "󰝚",
            "Music": "󰝚",
            "Player": "󰝚",
            "Video": "󰕧",
            "AudioVideo": "󰕧",
            "AudioVideoEditing": "󰕧",
            "Recorder": "󰑊",

            // Graphics
            "Graphics": "󰋩",
            "2DGraphics": "󰋩",
            "RasterGraphics": "󰋩",

            // Games
            "Game": "󰊗",

            // Settings & System
            "Settings": "󰒓",
            "DesktopSettings": "󰒓",
            "HardwareSettings": "󰒓",
            "System": "󰒓",
            "Monitor": "󰍛",

            // Office & Productivity
            "Office": "󰈙",
            "Printing": "󰐪",

            // Utilities
            "Utility": "󰑣",
            "Archiving": "󰀼",
            "Compression": "󰀼",

            // Communication
            "Chat": "󰭹",
            "InstantMessaging": "󰭹",
            "Email": "󰇮",

            // Security
            "Security": "󰒃"
        })

    // App class/name to icon overrides for common apps
    readonly property var appIcons: ({
            // Browsers
            "firefox": "󰈹",

            // Development
            "code": "󰨞",
            "Code": "󰨞",
            "neovim": "",
            "nvim": "",
            "vim": "",
            "Godot": "",
            "godot": "",

            "blender": "",

            // Terminals (with common class name patterns)
            "ghostty": "󰊠",
            "Ghostty": "󰊠",
            "com.mitchellh.ghostty": "󰊠",

            // Media
            "spotify": "󰓇",
            "Spotify": "󰓇",

            // Communication
            "discord": "󰙯",
            "Discord": "󰙯",
            "vesktop": "󰙯",

            // Gaming
            "steam": "󰓓",
            "Steam": "󰓓",

            // VR
            "wivrn": "",
            "io.github.wivrn.wivrn": "",

            // Custom icons
            "qpwgraph": "󰡀"
        })

    // Default icon when nothing matches
    readonly property string defaultIcon: "󰣆"

    // Get icon for an app by its class name
    // First checks direct app mapping, then falls back to category lookup
    // If initialTitle is provided, tries it as a fallback (e.g., Godot debug windows)
    function getAppIcon(appClass, initialTitle) {
        if (!appClass)
            return defaultIcon;

        // Check direct app mapping first (exact match)
        if (appIcons.hasOwnProperty(appClass)) {
            return appIcons[appClass];
        }

        // Try lowercase version
        const lowerClass = appClass.toLowerCase();
        if (appIcons.hasOwnProperty(lowerClass)) {
            return appIcons[lowerClass];
        }

        // Try partial matching for reverse domain names (e.g., "com.mitchellh.ghostty" -> "ghostty")
        if (appClass.includes('.')) {
            const parts = appClass.split('.');
            const lastPart = parts[parts.length - 1];
            if (appIcons.hasOwnProperty(lastPart)) {
                return appIcons[lastPart];
            }
            if (appIcons.hasOwnProperty(lastPart.toLowerCase())) {
                return appIcons[lastPart.toLowerCase()];
            }
        }

        // Generic Steam game pattern (steam_app_APPID)
        // Check specific game overrides first (already checked above), then use generic gamepad icon
        if (appClass.startsWith("steam_app_")) {
            return "󰊗";  // Gamepad icon for all Steam games
        }

        // Try to get categories from desktop entry
        const entry = DesktopEntries.heuristicLookup(appClass);
        if (entry && entry.categories) {
            for (const [category, icon] of Object.entries(categoryIcons)) {
                if (entry.categories.includes(category)) {
                    return icon;
                }
            }
        }

        // Try initialTitle as a fallback (e.g., Godot debug windows have custom classes but initialTitle "Godot")
        if (initialTitle) {
            if (appIcons.hasOwnProperty(initialTitle)) return appIcons[initialTitle];
            if (appIcons.hasOwnProperty(initialTitle.toLowerCase())) return appIcons[initialTitle.toLowerCase()];
        }

        return defaultIcon;
    }

    // Get icon for a category directly
    function getCategoryIcon(category, fallback) {
        if (categoryIcons.hasOwnProperty(category)) {
            return categoryIcons[category];
        }
        return fallback || defaultIcon;
    }
}
