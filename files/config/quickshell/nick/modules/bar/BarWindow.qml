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
    model: Quickshell.screens

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

            // Hover detection for auto-hide (future feature)
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: window.isHovered = true
                onExited: window.isHovered = false

                // Pass through all events
                onPressed: mouse => mouse.accepted = false
                onReleased: mouse => mouse.accepted = false
                onClicked: mouse => mouse.accepted = false
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
    }
}
