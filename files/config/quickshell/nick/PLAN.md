# Quickshell Bar Implementation Plan

## Goal
Create a minimal Quickshell bar inspired by [caelestia-shell](https://github.com/caelestia-dots/shell), implementing features incrementally to ensure each works correctly before moving on.

## Current Structure
```
nick/
  shell.qml              # Entry point
  PLAN.md                # This file
  config/
    Appearance.qml       # Appearance settings singleton (rounding, spacing, fonts, animations)
    qmldir               # Module definition
  services/
    Colours.qml          # Color palette singleton (Catppuccin Mocha defaults)
    qmldir               # Module definition
  components/
    Anim.qml             # Animation helper with Material Design curves
    qmldir               # Module definition
  modules/
    bar/
      BarWindow.qml      # Layer shell window + multi-screen support
      Bar.qml            # Bar content (logo, workspace placeholder, clock)
      qmldir             # Module definition
```

## Reference Repository Structure
The caelestia-shell repository uses:
- `shell.qml` - Main entry point (ShellRoot)
- `modules/` - Contains bar, drawers, dashboard, launcher, etc.
- `components/` - Reusable UI components (animations, styled elements)
- `config/` - Configuration singletons (Appearance, BarConfig, etc.)
- `services/` - Backend services (Colours, Hypr, Audio, etc.)
- `utils/` - Utility functions and helpers

## Implementation Phases

### Phase 1: Basic Bar Shell [DONE]
Create a minimal vertical bar on the left side of the screen with:
- [x] Basic shell.qml entry point
- [x] Simple bar window positioned on left edge
- [x] Wayland layer shell integration (exclusive zone)
- [x] Basic appearance config (colors, sizing)
- [x] Multi-screen support via Variants
- [x] Placeholder content (logo, workspace indicator, clock)
- [ ] Show/hide animation (prepared but always visible currently)

### Phase 2: Basic Clock Widget [PARTIAL]
- [x] Clock component showing time (hours/minutes vertical)
- [ ] Material icon support
- [x] Basic text styling

### Phase 3: Workspace Indicator
- [ ] Hyprland IPC integration
- [ ] Workspace buttons with current indicator
- [ ] Click to switch workspaces

### Phase 4: Show/Hide Behavior
- [ ] Auto-hide when not hovered
- [ ] Smooth slide animation
- [ ] Hover detection near edge

### Phase 5: System Tray
- [ ] Basic system tray support
- [ ] Tray icon display

### Phase 6: Status Icons
- [ ] Battery indicator
- [ ] Network indicator
- [ ] Volume indicator

### Phase 7: Polish
- [ ] Theming/color system (dynamic Material 3 colors)
- [ ] Configuration file support (JSON config)
- [ ] Additional animations

---

## Running the Shell

To test the shell manually:
```bash
# Make sure the symlink exists (via home-manager rebuild)
# Then run:
quickshell -c nick
# or
qs -c nick
```

The config name "nick" matches the directory name in `~/.config/quickshell/nick/`.

**Note:** The files live in `~/.config/dots/files/config/quickshell/nick/` and are symlinked via home-manager to `~/.config/quickshell/nick/`.

---

## Key Implementation Notes

### Layer Shell Configuration
The bar uses Wayland layer shell for:
- Anchoring to screen edges
- Exclusive zone reservation (pushes windows away)
- Layer ordering (Top layer, above normal windows)

```qml
anchors {
    top: true
    bottom: true
    left: true
}
exclusiveZone: contentWidth  // Reserves space
WlrLayershell.layer: WlrLayer.Top
```

### Animation System
Uses Material Design 3 expressive curves:
- `standard: [0.2, 0, 0, 1, 1, 1]` - General purpose
- `emphasized: [...]` - Attention-drawing
- `expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]` - Spatial movements (slide in/out)

### Multi-Screen Support
Uses Quickshell's `Variants` component to create bar instances per screen:
```qml
Variants {
    model: Quickshell.screens
    PanelWindow {
        required property ShellScreen modelData
        screen: modelData
        // ...
    }
}
```

---

## Dependencies

- `quickshell` (git version recommended)
- `qt6-declarative`
- `CaskaydiaCove NF` font (for Nix logo icon)
- For later phases:
  - `brightnessctl` (brightness)
  - `networkmanager` (network status)
  - `Material Symbols Rounded` font (icons)

---

## Next Steps

1. **Test the basic bar** - Run `qs -c nick` to verify it displays
2. **Add Hyprland workspaces** - Integrate with Hyprland IPC for workspace indicators
3. **Implement auto-hide** - Add hover detection and slide animations
4. **Add status icons** - Battery, network, volume
