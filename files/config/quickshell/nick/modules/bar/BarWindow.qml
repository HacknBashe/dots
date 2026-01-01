pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import Quickshell
import Quickshell.Wayland
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
        }
    }

    // Function to close menu on primary screen
    function closeMenu() {
        if (variants.instances.length > 0) {
            const firstScope = variants.instances[0];
            firstScope.menuOpen = false;
        }
    }

    Scope {
        id: scope

        required property ShellScreen modelData
        property bool menuOpen: false

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
                radius: Appearance.rounding.normal
                // Remove rounding on left side (screen edge)
                topLeftRadius: 0
                bottomLeftRadius: 0
                border.width: 1
                border.color: Qt.alpha(Colours.outline, 0.2)
            }

            // Bar content
            Bar {
                id: bar

                anchors.fill: parent
                anchors.margins: Appearance.padding.smaller

                menuOpen: Qt.binding(() => scope.menuOpen)
                onMenuToggled: scope.menuOpen = !scope.menuOpen
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
                }

                onPositionChanged: mouse => {
                    bar.updateTrayHover(mouse.y);

                    // Reset clear timer if over popout
                    if (trayPopout.visible && trayPopout.mouseInside) {
                        clearTrayTimer.stop();
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
        }

        // Invisible overlay to close menu when clicking outside
        PanelWindow {
            id: menuOverlay

            screen: scope.modelData
            color: "transparent"
            visible: scope.menuOpen

            // Full screen
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "nick-menu-overlay"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            MouseArea {
                anchors.fill: parent
                onClicked: scope.menuOpen = false
            }
        }

        // Menu popup window
        PanelWindow {
            id: menuWindow

            screen: scope.modelData
            color: "transparent"

            // Position anchored to bottom, offset from left by bar width
            anchors {
                bottom: true
                left: true
            }

            margins {
                left: window.contentWidth + Appearance.spacing.normal
                bottom: Appearance.spacing.normal
            }

            // Menu dimensions - animate width for slide effect
            implicitWidth: scope.menuOpen ? menu.width : 0
            implicitHeight: menu.height

            visible: implicitWidth > 0

            WlrLayershell.namespace: "nick-menu"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Behavior on implicitWidth {
                Anim {
                    duration: Appearance.anim.normal
                    easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
                }
            }

            Menu {
                id: menu

                anchors.left: parent.left
                anchors.bottom: parent.bottom

                open: scope.menuOpen
                onCloseRequested: scope.menuOpen = false
            }
        }

        // Single tray popout instance
        TrayPopout {
            id: trayPopout
            screen: scope.modelData
            trayItem: bar.hoveredTrayItem
            targetY: bar.trayPopoutTargetY
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
    }
}
