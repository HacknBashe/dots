pragma ComponentBehavior: Bound

import "../config"
import "../services"
import "../shared"
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick

// Single persistent popout window that displays tray icon menus
// Content updates dynamically when hovering between different icons
BarPopout {
    id: popout

    property SystemTrayItem trayItem: null
    property var barRef: null  // Reference to Bar for calling closeTrayPopout

    // Cache the trayItem to keep menu items visible during slide-out animation
    property SystemTrayItem cachedTrayItem: null
    property bool isTransitioning: false

    shouldBeOpen: trayItem !== null && (trayItem.hasMenu ?? false)
    popoutWidth: 200

    // Update cache and handle animations when tray item changes
    onTrayItemChanged: {
        if (trayItem !== null && (trayItem.hasMenu ?? false)) {
            // If switching between different valid tray items, enable animations
            if (cachedTrayItem !== null && trayItem !== cachedTrayItem) {
                // Enable height and position animations immediately
                animateHeight = true;

                // Update cache immediately so height recalculates right away
                cachedTrayItem = trayItem;

                // Trigger crossfade animation
                isTransitioning = true;
                fadeInTimer.restart();
            } else {
                animateHeight = false;
                // First time opening or same item, update immediately
                cachedTrayItem = trayItem;
            }
        }
    }

    Timer {
        id: heightAnimationTimer
        interval: Appearance.anim.normal + 50  // Animation duration + buffer
        onTriggered: popout.animateHeight = false
    }

    // Fade back in after brief delay to let content update
    Timer {
        id: fadeInTimer
        interval: Appearance.anim.small / 2  // Brief delay (100ms)
        onTriggered: {
            popout.isTransitioning = false;
            heightAnimationTimer.restart();
        }
    }

    contentItem: Component {
        Item {
            width: parent.width
            height: Math.max(40, menuColumn.height + 16)

            QsMenuOpener {
                id: menuOpener
                menu: popout.cachedTrayItem?.menu ?? null
            }

            Column {
                id: menuColumn
                anchors.centerIn: parent
                width: parent.width
                spacing: 0

                // Fade out when transitioning, fade back in when new content loads
                opacity: popout.isTransitioning ? 0 : 1

                Behavior on opacity {
                    Anim {
                        duration: Appearance.anim.small
                        easing.bezierCurve: Appearance.anim.standard
                    }
                }

                Repeater {
                    model: menuOpener.children

                    BarTrayMenuItem {
                        required property var modelData
                        menuEntry: modelData

                        onClicked: {
                            // Close popout when menu item is clicked
                            if (popout.barRef) {
                                popout.barRef.closeTrayPopout();
                            }
                        }
                    }
                }
            }
        }
    }
}
