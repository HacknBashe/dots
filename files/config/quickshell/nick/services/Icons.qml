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
            "TerminalEmulator": "",
            "ConsoleOnly": "",

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
            "chromium": "",
            "google-chrome": "",
            "brave-browser": "󰖟",
            "brave": "󰖟",

            // Development
            "code": "󰨞",
            "Code": "󰨞",
            "vscodium": "󰨞",
            "neovim": "",
            "nvim": "",
            "vim": "",
            "jetbrains-idea": "",
            "jetbrains-pycharm": "",
            "Godot": "",
            "godot": "",

            // Terminals (with common class name patterns)
            "kitty": "󰄛",
            "Alacritty": "",
            "alacritty": "",
            "foot": "",
            "ghostty": "󰊠",
            "Ghostty": "󰊠",
            "com.mitchellh.ghostty": "󰊠",
            "org.wezfurlong.wezterm": "",
            "wezterm": "",

            // File managers
            "thunar": "󰉋",
            "Thunar": "󰉋",
            "nautilus": "󰉋",
            "dolphin": "󰉋",
            "org.kde.dolphin": "󰉋",
            "pcmanfm": "󰉋",

            // Media
            "spotify": "󰓇",
            "Spotify": "󰓇",
            "vlc": "󰕼",
            "mpv": "",

            // Communication
            "discord": "󰙯",
            "Discord": "󰙯",
            "vesktop": "󰙯",
            "slack": "󰒱",
            "Slack": "󰒱",
            "telegram": "",
            "signal": "󰭹",

            // Gaming
            "steam": "󰓓",
            "Steam": "󰓓",
            "lutris": "󰊗",
            "heroic": "󰊗",

            // VR
            "wivrn": "",
            "io.github.wivrn.wivrn": "",

            // Recording/Streaming
            "obs": "󰑋",
            "com.obsproject.Studio": "󰑋",

            // Graphics
            "gimp": "",
            "org.gimp.GIMP": "",
            "inkscape": "",
            "org.inkscape.Inkscape": "",
            "blender": "󰂫",
            "krita": "󰋩",

            // Viewers
            "zathura": "",
            "evince": "",
            "org.gnome.Evince": "",
            "okular": "",

            // Office
            "libreoffice": "󰈙",
            "thunderbird": "󰇮",

            // System
            "pavucontrol": "󰕾",
            "blueman-manager": "󰂯"
        })

    // Default icon when nothing matches
    readonly property string defaultIcon: "󰣆"

    // Get icon for an app by its class name
    // First checks direct app mapping, then falls back to category lookup
    function getAppIcon(appClass) {
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
