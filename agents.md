# Quickshell Development Agents & Strategies

## How to Update This File

Just ask! You don't need to run any special command. Simply say "update agents.md with..." and the agent will update this file directly.

## Important: Never Run Quickshell

**CRITICAL:** AI agents should NEVER run quickshell directly.

**The user is ALWAYS running QuickShell with logs output to `/home/nick/.config/dots/quickshell.log`.**

Because QuickShell is already running, you never need to start it yourself. Simply read the log file to see current output.

When debugging quickshell issues:

1. Read the log file at `/home/nick/.config/dots/quickshell.log`
2. Make code changes as needed
3. The code changes are automatically applied
4. Read the updated logs

## Debugging Strategy

### Logging Quickshell Output

The user captures quickshell output to a file for analysis:

```bash
quickshell -c nick 2>&1 | tee ~/.config/dots/quickshell.log
```

This allows:

- Real-time viewing in terminal
- Complete output capture including DEBUG, WARN, ERROR messages
- File accessible to AI agents via Read tool at `/home/nick/.config/dots/quickshell.log`
- Preserves ANSI color codes for readability

### Console Logging Best Practices

Use `console.log()` liberally during development:

```qml
Process {
    id: myProcess
    command: ["some", "command"]

    onRunningChanged: {
        if (running) {
            console.log("Starting process with args:", command);
        }
    }

    onExited: (code) => {
        console.log("Process exited with code:", code);
    }
}
```

**Important:** Use arrow function syntax for signal handlers to avoid QML warnings:

- ✅ Good: `onExited: (code) => { ... }`
- ❌ Bad: `onExited: { console.log(exitCode); }` (parameter injection warning)

### Process Debugging Pattern

When a Process fails silently:

1. **Add logging at each stage:**

   ```qml
   Process {
       onRunningChanged: {
           if (running) console.log("Process starting...");
       }

       stdout: SplitParser {
           onRead: data => {
               console.log("stdout:", data);
           }
       }

       stderr: SplitParser {
           onRead: data => {
               console.log("stderr:", data);
           }
       }

       onExited: (code) => {
           console.log("Exit code:", code);
       }
   }
   ```

2. **Test command directly in terminal:**
   - Verify command works standalone
   - Check exit codes
   - Ensure full paths to binaries if needed

3. **Common gotchas:**
   - Wrong command syntax for the tool
   - Command uses different ID format than expected
   - Need full path to binary (e.g., `/etc/profiles/per-user/nick/bin/pulsemixer`)
   - Shell features not available (pipes, redirects) without wrapping in bash -c

### Data Parsing Issues

When parsing command output:

1. **Log the raw buffer:**

   ```qml
   onExited: {
       console.log("Raw buffer:", buffer);
       // Then parse...
   }
   ```

2. **Check for missing newlines:**
   - SplitParser without splitMarker may concatenate output
   - Commands may not separate lines as expected
   - Solution: Split by regex patterns instead of `\n`

3. **Example: Parsing concatenated output**

   ```qml
   // Bad: Assumes newlines exist
   let lines = buffer.split('\n');

   // Good: Split by known delimiter in data
   let entries = buffer.split(/Sink:\s+/).filter(s => s.trim());
   ```

## Common Patterns

### Reactive Properties from External Commands

Use `Hyprland.activeToplevel` instead of `Hyprland.focusedWindow` for reactive window tracking:

```qml
readonly property int activeSpecialWsId: {
    let wsId = Hyprland.activeToplevel?.workspace?.id ?? 0;
    return (wsId < 0) ? wsId : 0;
}
```

### Process Command Evaluation

Process commands are evaluated when `running` becomes true, so you can reference reactive properties:

```qml
Process {
    id: myProcess
    // Command evaluated when running is set to true
    command: ["wpctl", "set-default", sinkItem.modelData.id]
}

MouseArea {
    onClicked: {
        myProcess.running = true;  // Command built here with current values
    }
}
```

### Buffering Process Output

For commands with multi-line output:

```qml
Process {
    property string buffer: ""

    onRunningChanged: {
        if (running) buffer = "";  // Clear on start
    }

    stdout: SplitParser {
        onRead: data => {
            buffer += data;
        }
    }

    onExited: {
        // Parse complete buffer
    }
}
```

## Tool-Specific Notes

### wpctl vs pulsemixer vs pactl

Different audio tools use different ID formats:

- **wpctl**: Numeric IDs (48, 90, 100)
  - Get sinks: `wpctl status | grep -A 100 'Sinks:'`
  - Set default: `wpctl set-default 90`
- **pulsemixer**: String IDs (sink-4591)
  - Get sinks: `pulsemixer --list-sinks`
  - No built-in set-default command
  - Use for getting volume: `pulsemixer --get-volume`
  - Use for setting volume: `pulsemixer --change-volume +5`

- **pactl**: May not be available in all environments

**Decision:** Use wpctl for defaults, pulsemixer for volume control.

## Code Formatting

**IMPORTANT:** Always format QML files after editing using qmlformat:

```bash
qmlformat -i /path/to/file.qml
```

The formatter is available via the `qt6.qtdeclarative` package which is installed with quickshell. Always run it after making changes to ensure consistent code style.

## Theme System

### Theme Configuration (`modules/theme.nix`)

**CRITICAL:** The `theme.nix` file contains colors and configuration for the **ENTIRE dots repository**, not just quickshell. Changes here affect:
- Quickshell UI
- Hyprland colors
- Terminal colors (Ghostty, Alacritty, etc.)
- GTK/Qt themes
- macOS Aerospace/JankyBorders
- Any other application that reads from the theme config

The theme uses Tokyo Night color scheme with **ANSI colors only** (base16 colors have been removed):

```nix
theme.colors = {
  background = "#1a1b26";
  foreground = "#c0caf5";
  
  # Standard ANSI colors
  default = {
    black = "#1b1d2b";
    red = "#ff757f";
    green = "#c3e88d";
    yellow = "#ffc777";
    blue = "#82aaff";
    magenta = "#c099ff";
    cyan = "#86e1fc";
    white = "#828bb8";
  };
  
  bright = {
    black = "#444a73";
    red = "#ff757f";
    green = "#c3e88d";
    yellow = "#ffc777";
    blue = "#82aaff";
    magenta = "#c099ff";
    cyan = "#86e1fc";
    white = "#c8d3f5";
  };
  
  # Custom indexed colors for special use cases
  indexed = {
    one = "#ff966c";    # Orange
    two = "#c53b53";    # Dark red
    three = "#ffb3d9";  # Pastel retrowave pink
    four = "#2f3549";   # Mid-tone background (for buttons, hover states)
  };
};
```

**Migration Complete:** All base16 color references have been migrated to ANSI equivalents across:
- GTK theme (`modules/home-manager/gtk.nix`)
- Qt theme (`modules/home-manager/qt.nix`)
- macOS Aerospace borders (`modules/darwin/aerospace.nix`)

### Quickshell Color System (`modules/home-manager/quickshell.nix`)

Quickshell reads colors from a JSON file generated by Nix at `~/.config/quickshell/theme-colors.json`. The mapping is defined in `quickshell.nix`:

```nix
themeColors = builtins.toJSON {
  # Semantic color names mapped to ANSI colors
  primary = config.theme.colors.default.magenta;     # Purple #c099ff
  secondary = config.theme.colors.indexed.three;     # Light pink #ffb3d9
  tertiary = config.theme.colors.indexed.one;        # Orange #ff966c
  quaternary = config.theme.colors.default.yellow;   # Yellow #ffc777
  quinary = config.theme.colors.default.green;       # Green #c3e88d
  
  # Base colors
  background = config.theme.colors.background;
  foreground = config.theme.colors.foreground;
  surface = config.theme.colors.default.black;
  surfaceContainer = "#2f334f";  # Middle ground between default.black and bright.black
  textOnBackground = config.theme.colors.foreground;
  textOnSurface = config.theme.colors.bright.white;
  textOnPrimary = config.theme.colors.background;
  outline = config.theme.colors.bright.black;
  shadow = config.theme.colors.default.black;
};
```

**Color Usage Philosophy:**
- Use ONLY colors from the theme system - no hardcoded colors
- Use semantic names (primary, secondary, etc.) not specific colors
- Match retrowave/Tokyo Night aesthetic with pastels and neons

**Current Color Assignments:**
- CPU bars: Primary (purple)
- GPU bars: Tertiary (orange)
- RAM bars: Quaternary (yellow)
- Disk bars: Quinary (green)
- Clock/Volume: Secondary (light pink)
- Weather icon: Primary
- Weather condition: Secondary
- All bar icons/text match their bar colors

### Accessing Colors in QML (`services/Colours.qml`)

Colors are loaded from the JSON file via a singleton:

```qml
import "../../services"

Text {
    color: Colours.primary  // Use semantic names
}
```

After changing theme.nix, rebuild with:
```bash
sudo nixos-rebuild switch --flake .#meraxes
```

## Project Structure

```
nick/
├── components/       # Reusable UI components
│   ├── workspaces/  # Workspace indicator (with fixed animations!)
│   └── Volume.qml   # Volume widget with device detection
├── config/          # Theme and appearance
│   └── Appearance.qml  # Font sizes, spacing, animation durations
├── modules/
│   └── bar/        # Main bar components
│       ├── Bar.qml           # Bar content layout
│       ├── BarWindow.qml     # Window management
│       ├── Menu.qml          # Calendar, weather, performance stats, media controls
│       ├── VolumePopout.qml  # Audio device selector
│       └── TrayPopout.qml    # System tray menus
├── services/        # Singletons
│   ├── Colours.qml       # Theme color singleton
│   ├── SystemUsage.qml   # CPU/GPU/RAM/Disk monitoring
│   ├── Weather.qml       # Weather data
│   └── qmldir            # Service registration
└── shell.qml       # Entry point
```

### Module Registration

Components in subdirectories need `qmldir` files:

```
# modules/bar/qmldir
module bar
BarWindow 1.0 BarWindow.qml
VolumePopout 1.0 VolumePopout.qml
```

Without this, components won't be available even if imported.

## Key Features & Fixes

### Workspace Widget
- **Fixed animation stuttering** - Root cause was pill using `activeItem.height` (animated) instead of `implicitHeight` (target)
- Center-based positioning, simplified from ~100 lines to ~35 lines
- All animations 200ms with standard easing
- 15px workspace spacing
- Color fade animations on workspace text

### Volume Widget
- Increased icon/text sizes (icon: 32px, text: 18px)
- Device detection with icons (headset, bluetooth, soundbar, steam link, HDMI)
- Device icon positioned above percentage
- Hover effects match system tray

### Menu System
- Interactive Nix button with scale animation and color inversion
- Keyboard navigation (arrows, enter, escape) for power buttons
- 5 power buttons: Lock, Suspend, Logout, Restart, Power
- Calendar with month navigation that resets to current month on open
- Weather widget (40% width)
- Performance stats widget (60% width) with CPU/GPU/RAM/Disk bars
- Now playing media controls with album art

### System Tray
- 40px icon size with 4px spacing
- Rounded corner hover backgrounds (`Qt.alpha(Colours.textOnBackground, 0.08)`)
- Proper click handling with z-ordering fix

### SystemUsage Service
- Monitors CPU, GPU (NVIDIA/AMD/Intel), RAM, Disk usage and temps
- Uses `StdioCollector` with `onStreamFinished` pattern (from Caelestia)
- Automatic GPU type detection
- Temperature fallback to `/sys/class/thermal/` when sensors unavailable
- Updates every 3 seconds

## Animation Patterns

### Fade-in from Center (No Position Animation)

For pills/indicators that should appear in place:

```qml
Rectangle {
    opacity: isActive ? 1 : 0
    scale: isActive ? 1 : 0.8
    visible: opacity > 0

    // Instant position changes
    Behavior on y { enabled: false }
    Behavior on height { enabled: false }

    // Smooth fade/scale
    Behavior on opacity {
        Anim { duration: Appearance.anim.small }
    }
    Behavior on scale {
        Anim { duration: Appearance.anim.small }
    }
}
```

### Preventing Flicker on State Change

Store last valid position to avoid jumps during fade-out:

```qml
Rectangle {
    property real lastY: 0
    property var activeItem: null

    onActiveItemChanged: {
        if (activeItem !== null) {
            lastY = activeItem.y;
        }
    }

    y: lastY  // Stays at last position even when activeItem becomes null
    opacity: activeItem !== null ? 1 : 0
}
```
