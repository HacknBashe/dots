# Quickshell Development Agents & Strategies

## Debugging Strategy

### Logging Quickshell Output
When debugging complex issues, capture full output to a file for analysis:

```bash
quickshell -c nick 2>&1 | tee ~/.config/dots/quickshell.log
```

This allows:
- Real-time viewing in terminal
- Complete output capture including DEBUG, WARN, ERROR messages
- File accessible to AI agents via Read tool
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

## Project Structure

```
nick/
├── components/       # Reusable UI components
│   ├── workspaces/  # Workspace indicator
│   └── Volume.qml   # Volume widget
├── config/          # Theme and appearance
├── modules/
│   └── bar/        # Main bar components
│       ├── Bar.qml           # Bar content layout
│       ├── BarWindow.qml     # Window management
│       ├── VolumePopout.qml  # Audio device selector
│       └── TrayPopout.qml    # System tray menus
├── services/        # Singletons (Colours, etc)
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
