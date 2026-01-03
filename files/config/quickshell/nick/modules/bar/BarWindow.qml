pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Creates bar windows for each screen
Variants {
    id: variants
    model: Quickshell.screens

    // Function to toggle menu on primary screen
    function toggleMenu() {
        // Toggle on the first scope (primary screen)
        if (variants.instances.length > 0) {
            const firstScope = variants.instances[0];
            firstScope.menuOpen = !firstScope.menuOpen;
            firstScope.bar.menuOpen = firstScope.menuOpen;
        }
    }

    // Function to close menu on primary screen
    function closeMenu() {
        if (variants.instances.length > 0) {
            const firstScope = variants.instances[0];
            firstScope.menuOpen = false;
            firstScope.bar.menuOpen = false;
        }
    }

    Scope {
        id: scope

        required property ShellScreen modelData
        property bool menuOpen: false
        property bool menuMouseInside: false
        property alias bar: bar

        PanelWindow {
            id: window

            // Bar configuration
            readonly property int barWidth: 48
            readonly property int borderThickness: 4
            readonly property int contentWidth: barWidth + Appearance.padding.smaller * 2

            // Visibility state
            property bool shouldBeVisible: true
            property bool isHovered: false

            screen: scope.modelData
            color: "transparent"

            // Layer shell configuration
            anchors {
                top: true
                bottom: true
                left: true
            }

            // The exclusive zone reserves space on the left edge
            exclusiveZone: shouldBeVisible ? contentWidth : borderThickness
            implicitWidth: shouldBeVisible ? contentWidth : borderThickness

            WlrLayershell.namespace: "nick-bar"
            WlrLayershell.layer: WlrLayer.Top

            // Animate width changes
            Behavior on implicitWidth {
                Anim {
                    duration: Appearance.anim.normal
                    easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
                }
            }

            // Background
            Rectangle {
                id: background

                anchors.fill: parent
                color: Colours.background
                radius: 0
                border.width: 1
                border.color: Qt.alpha(Colours.outline, 0.2)
            }

            // Bar content
            Bar {
                id: bar

                anchors.fill: parent
                anchors.margins: Appearance.padding.smaller

                onOpenMenuRequested: {
                    scope.menuOpen = true;
                    bar.menuOpen = true;
                }
            }

            // Hover detection for auto-hide (future feature) and tray popout
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                propagateComposedEvents: true

                onEntered: window.isHovered = true
                onExited: {
                    window.isHovered = false;
                    clearTrayTimer.restart();
                    clearVolumeTimer.restart();
                    bar.clearNixButtonHover();
                    if (scope.menuOpen) {
                        clearMenuTimer.restart();
                    }
                }

                onPositionChanged: mouse => {
                    let prevTrayIdx = bar.hoveredTrayIndex;
                    let trayIdx = bar.calculateTrayIndex(mouse.y);
                    let overTray = trayIdx >= 0;
                    let volumeY = bar.volumeWidget.y;
                    let volumeHeight = bar.volumeWidget.height;
                    let overVolume = mouse.y >= volumeY && mouse.y <= volumeY + volumeHeight;

                    // Update hover states (this will open popouts if hovering)
                    bar.updateTrayHover(mouse.y);
                    bar.updateVolumeHover(mouse.y);
                    bar.updateNixButtonHover(mouse.y, scope.menuOpen);

                    // Tray timer logic: start timer if tray popout is open but mouse not over tray/popout
                    if (trayPopout.visible) {
                        if (overTray || trayPopout.mouseInside) {
                            clearTrayTimer.stop();
                            // If we switched to a different tray icon, the content already updated above
                        } else if (!clearTrayTimer.running) {
                            clearTrayTimer.start();
                        }
                    }

                    // Volume timer logic: start timer if volume popout is open but mouse not over volume/popout
                    if (volumePopout.visible) {
                        if (overVolume || volumePopout.mouseInside) {
                            clearVolumeTimer.stop();
                        } else if (!clearVolumeTimer.running) {
                            clearVolumeTimer.start();
                        }
                    }

                    // Menu close logic: start timer if menu is open but mouse not over button/menu
                    if (scope.menuOpen) {
                        if (bar.nixButtonHovered || scope.menuMouseInside) {
                            clearMenuTimer.stop();
                        } else if (!clearMenuTimer.running) {
                            clearMenuTimer.start();
                        }
                    }
                }

                onClicked: mouse => {
                    // Only handle clicks in the tray area
                    let idx = bar.calculateTrayIndex(mouse.y);
                    if (idx >= 0) {
                        bar.handleTrayClick(mouse.y, mouse.button);
                    } else {
                        // Let click propagate to underlying elements (like Nix button)
                        mouse.accepted = false;
                    }
                }

                onWheel: wheel => {
                    // Don't handle wheel events, let them propagate to underlying components (like Volume)
                    wheel.accepted = false;
                }
            }

            // Timer for tray popout clear delay
            Timer {
                id: clearTrayTimer
                interval: 150
                onTriggered: {
                    // Only clear if mouse not in popout
                    if (!trayPopout.mouseInside) {
                        bar.clearTrayHover();
                    }
                }
            }

            // Timer for volume popout clear delay
            Timer {
                id: clearVolumeTimer
                interval: 150
                onTriggered: {
                    // Only clear if mouse not in popout
                    if (!volumePopout.mouseInside) {
                        bar.clearVolumeHover();
                    }
                }
            }

            // Timer for menu close delay
            Timer {
                id: clearMenuTimer
                interval: 150
                onTriggered: {
                    // Close menu if mouse not over button and not over menu
                    if (!bar.nixButtonHovered && !scope.menuMouseInside) {
                        scope.menuOpen = false;
                        bar.menuOpen = false;
                    }
                }
            }
        }

        // Menu popup window
        PanelWindow {
            id: menuWindow

            screen: scope.modelData
            color: "transparent"

            anchors {
                left: true
                bottom: true
                top: true
            }

            margins {
                left: 60
                bottom: 20
                top: 20
            }

            width: menu.width
            height: menu.height

            // Stay visible during animation
            visible: scope.menuOpen || menu.x > -menu.width

            WlrLayershell.namespace: "nick-menu"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: KeyboardFocus.Exclusive
            
            // Use Hyprland focus grab to ensure keyboard input is captured
            HyprlandFocusGrab {
                active: scope.menuOpen
                windows: [menuWindow]
            }

            Menu {
                id: menu

                anchors.bottom: parent.bottom
                // Animate x position for slide effect (account for left extension)
                x: scope.menuOpen ? 0 : -menu.width

                Behavior on x {
                    Anim {
                        duration: Appearance.anim.normal
                        easing.type: Easing.OutCubic  // Smooth deceleration without overshoot
                    }
                }

                open: scope.menuOpen
                onCloseRequested: {
                    scope.menuOpen = false;
                    bar.menuOpen = false;
                }
            }

            // MouseArea to track menu hover
            // Note: This MouseArea is behind the menu content (no z-index) so hover events reach buttons
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                acceptedButtons: Qt.NoButton

                onEntered: {
                    scope.menuMouseInside = true;
                    clearMenuTimer.stop();
                }
                onExited: {
                    scope.menuMouseInside = false;
                    clearMenuTimer.restart();
                }
            }
        }

        // Single tray popout instance
        TrayPopout {
            id: trayPopout
            screen: scope.modelData
            trayItem: bar.hoveredTrayItem
            targetIconCenterY: bar.trayIconCenterY
            barRef: bar

            // When mouse leaves popout, start clear timer
            onMouseInsideChanged: {
                if (!mouseInside && visible) {
                    clearTrayTimer.restart();
                } else {
                    clearTrayTimer.stop();
                }
            }
        }

        VolumePopout {
            id: volumePopout
            screen: scope.modelData
            targetIconCenterY: bar.volumeIconCenterY
            barMouseInside: bar.volumeHovered

            // When mouse leaves popout, start clear timer
            onMouseInsideChanged: {
                if (!mouseInside && visible) {
                    clearVolumeTimer.restart();
                } else {
                    clearVolumeTimer.stop();
                }
            }
        }
    }
}
