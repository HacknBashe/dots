pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick

// Single persistent popout window that displays tray icon menus
// Content updates dynamically when hovering between different icons
PanelWindow {
    id: popout

    property SystemTrayItem trayItem: null
    property real targetY: 0
    property bool mouseInside: false
    property var barRef: null  // Reference to Bar for calling closeTrayPopout

    color: "transparent"
    visible: trayItem !== null && (trayItem.hasMenu ?? false)

    // Position from top, offset from left by bar width + gap
    anchors {
        top: true
        left: true
    }

    margins {
        left: 56  // Bar width (48) + gap (8)
        top: targetY
    }

    // Smooth position animation when moving between icons
    Behavior on margins.top {
        Anim {
            duration: Appearance.anim.small
        }
    }

    // Animate width to expand from left
    implicitWidth: popout.visible ? 200 : 0
    implicitHeight: contentRect.height

    Behavior on implicitWidth {
        Anim {
            duration: Appearance.anim.normal
            easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
        }
    }

    WlrLayershell.namespace: "nick-tray-popout"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Content
    Rectangle {
        id: contentRect
        color: Colours.surfaceContainer
        width: 200
        height: menuColumn.height
        radius: Appearance.rounding.small
        clip: true  // Clip content during animation

        QsMenuOpener {
            id: menuOpener
            menu: popout.trayItem?.menu ?? null
        }

        Column {
            id: menuColumn
            width: parent.width

            Repeater {
                model: menuOpener.children

                TrayMenuItem {
                    required property var modelData
                    menuEntry: modelData

                    onClicked: {
                        // Close popout when menu item is clicked
                        console.log("Menu item clicked, calling closeTrayPopout");
                        if (popout.barRef) {
                            popout.barRef.closeTrayPopout();
                        }
                    }
                }
            }
        }

        // Hover detection for keeping popout open (on top with high z-index)
        MouseArea {
            id: hoverArea
            anchors.fill: parent
            z: 1000  // Put on top of everything
            hoverEnabled: true
            propagateComposedEvents: true
            acceptedButtons: Qt.NoButton  // Don't intercept clicks

            onEntered: popout.mouseInside = true
            onExited: popout.mouseInside = false
        }
    }
}
