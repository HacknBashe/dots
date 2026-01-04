pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Base popout window component with consistent slide animation
PanelWindow {
    id: popout

    // Public properties
    property real targetIconCenterY: 0  // Y position of the icon center to align with
    property bool mouseInside: false
    property bool shouldBeOpen: false
    property int popoutWidth: 250
    property bool animateHeight: false  // Enable height animation for content switching
    property alias contentItem: contentLoader.sourceComponent

    color: "transparent"
    // Keep visible during slide animation
    visible: shouldBeOpen || contentRect.x > -contentRect.width

    // Position from top, offset from left by bar width + gap
    anchors {
        top: true
        left: true
    }

    margins {
        left: 48 + 7 * 2 - 1  // Bar width + padding.smaller * 2 - 1 (matches Menu positioning)
        top: 0
        bottom: 12  // Prevent popouts from going to the very bottom of the screen
    }

    // Fixed size - never changes to prevent Hyprland animations
    implicitWidth: popoutWidth
    implicitHeight: 2000  // Large fixed height, content positions itself inside

    WlrLayershell.namespace: "nick-popout"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Content
    Item {
        anchors.fill: parent

        Rectangle {
            id: contentRect
            color: Colours.layer(Colours.background, 0)
            width: popoutWidth
            height: Math.max(40, contentLoader.height)
            radius: Appearance.rounding.small
            // Square corners on left side, rounded on right
            topLeftRadius: 0
            bottomLeftRadius: 0
            clip: true

            // Vertically center the popout with the target icon
            y: Math.max(0, Math.min(parent.height - height, popout.targetIconCenterY - height / 2))

            // Slide animation
            x: popout.shouldBeOpen ? 0 : -width

            Behavior on x {
                Anim {
                    duration: Appearance.anim.normal
                    easing.bezierCurve: Appearance.anim.standard
                }
            }

            // Height animation (only when enabled, e.g., switching between menus)
            Behavior on height {
                enabled: popout.animateHeight
                Anim {
                    duration: Appearance.anim.normal
                    easing.bezierCurve: Appearance.anim.standard
                }
            }

            // Content loader
            Loader {
                id: contentLoader
                width: parent.width
            }

            // Hover detection for keeping popout open
            // HoverHandler doesn't block events like MouseArea does
            HoverHandler {
                id: hoverHandler

                onHoveredChanged: {
                    popout.mouseInside = hovered;
                }
            }
        }
    }
}
