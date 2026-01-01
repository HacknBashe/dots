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
        "Development": "",
        "IDE": "",
        "TextEditor": "󰷈",

        // Terminal
        "TerminalEmulator": "",
        "ConsoleOnly": "",

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
        "firefox": "󰈹",
        "chromium": "",
        "google-chrome": "",
        "brave-browser": "󰖟",
        "code": "󰨞",
        "Code": "󰨞",
        "vscodium": "󰨞",
        "neovim": "",
        "nvim": "",
        "vim": "",
        "kitty": "󰄛",
        "Alacritty": "",
        "foot": "",
        "ghostty": "󰊠",
        "Ghostty": "󰊠",
        "thunar": "󰉋",
        "nautilus": "󰉋",
        "dolphin": "󰉋",
        "spotify": "󰓇",
        "Spotify": "󰓇",
        "discord": "󰙯",
        "Discord": "󰙯",
        "vesktop": "󰙯",
        "slack": "󰒱",
        "Slack": "󰒱",
        "telegram": "",
        "steam": "󰓓",
        "Steam": "󰓓",
        "obs": "󰑋",
        "gimp": "",
        "inkscape": "",
        "blender": "󰂫",
        "vlc": "󰕼",
        "mpv": "",
        "zathura": "",
        "evince": "",
        "libreoffice": "󰈙",
        "thunderbird": "󰇮"
    })

    // Default icon when nothing matches
    readonly property string defaultIcon: "󰣆"

    // Get icon for an app by its class name
    // First checks direct app mapping, then falls back to category lookup
    function getAppIcon(appClass) {
        if (!appClass) return defaultIcon;

        // Check direct app mapping first
        if (appIcons.hasOwnProperty(appClass)) {
            return appIcons[appClass];
        }

        // Try lowercase version
        const lowerClass = appClass.toLowerCase();
        if (appIcons.hasOwnProperty(lowerClass)) {
            return appIcons[lowerClass];
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
