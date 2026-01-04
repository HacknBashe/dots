pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../"
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    implicitWidth: 50
    implicitHeight: {
        // Base layout height plus minimal padding
        // The pill extends slightly beyond workspace items due to center-based positioning
        // We only need enough padding to accommodate the pill's radius on empty workspaces
        let baseHeight = layout.implicitHeight;

        // Add just enough padding for the pill to fit (half the pill padding on each side)
        return baseHeight + Appearance.padding.smaller * 2;
    }

    color: Colours.layer(Colours.surfaceContainer, 0)
    radius: Appearance.rounding.full
    topLeftRadius: Appearance.rounding.full
    topRightRadius: Appearance.rounding.full
    bottomLeftRadius: Appearance.rounding.full
    bottomRightRadius: Appearance.rounding.full

    // Track active workspace
    readonly property int activeWsId: Hyprland.focusedWorkspace?.id ?? 1

    // Build occupied workspaces map (using caelestia's approach with .values)
    // Also track toplevels to ensure reactivity when windows are created/destroyed
    readonly property var occupied: {
        // Track both workspaces and toplevels for proper reactivity
        const workspaceValues = Hyprland.workspaces.values || [];
        const toplevelValues = Hyprland.toplevels.values || [];

        // Create a map by counting actual toplevels per workspace
        const occupiedMap = {};
        toplevelValues.forEach(window => {
            const wsId = window.workspace?.id;
            if (wsId !== undefined && wsId !== null) {
                occupiedMap[wsId] = true;
            }
        });

        return occupiedMap;
    }

    // Get list of special workspaces - only show ones that have windows
    // Note: Empty special workspaces don't exist in Hyprland.workspaces.values
    readonly property var specialWorkspaces: {
        const values = Hyprland.workspaces.values || [];
        return values.filter(ws => ws.name.startsWith("special:") && ws.lastIpcObject.windows > 0).sort((a, b) => b.id - a.id);
    }

    // Track which special workspace is active for the highlight pill
    readonly property string activeSpecialWsName: Hyprland.focusedMonitor?.lastIpcObject?.specialWorkspace?.name ?? ""

    readonly property int groupOffset: 0
    readonly property int shownWorkspaces: 10

    // Force initial update after component loads
    Component.onCompleted: {
        // Refresh Hyprland data to ensure pill can find active workspace
        Hyprland.refreshWorkspaces();
    }

    // Listen to Hyprland events to refresh toplevels, workspaces, and monitors
    // This ensures lastIpcObject properties are populated for new windows/workspaces
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const n = event.name;
            if (n.endsWith("v2"))
                return;

            // Refresh when windows are opened/closed/moved
            if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                Hyprland.refreshToplevels();
                Hyprland.refreshWorkspaces();
            } else
            // Refresh monitors and workspaces when workspace/special workspace changes
            // This is exactly what caelestia does
            if (["workspace", "moveworkspace", "activespecial", "focusedmon"].includes(n)) {
                Hyprland.refreshWorkspaces();
                Hyprland.refreshMonitors();
            }
        }
    }

    // Regular workspace active indicator pill
    Rectangle {
        id: activeIndicator

        readonly property int currentWsIdx: {
            // Only highlight regular workspaces (1-10)
            if (activeWsId >= 1 && activeWsId <= root.shownWorkspaces) {
                return activeWsId - 1;
            }
            return -1;
        }

        readonly property var activeItem: {
            if (currentWsIdx < 0)
                return null;
            let item = workspaces.itemAt(currentWsIdx);
            // Access repeater count to ensure QML tracks this dependency
            // Without this, activeItem doesn't reactively update when workspaces are added/removed
            let _ = workspaces.count;
            // Force re-evaluation by checking the item exists and has valid geometry
            if (item && item.implicitHeight !== undefined)
                return item;
            return item;
        }

        // Store computed position to ensure it updates when activeItem changes
        property real targetY: {
            if (!activeItem)
                return 0;

            const itemY = activeItem.y;
            if (itemY === undefined || itemY === null)
                return 0;

            // Calculate workspace item's center in layout coordinates
            let itemCenterY = layout.y + itemY + (activeItem.implicitHeight / 2);

            // Position pill centered on the workspace item
            return itemCenterY - (targetHeight / 2);
        }

        property real targetHeight: {
            if (!activeItem)
                return root.implicitWidth;

            // Calculate height based on implicit height (final target, not animated value)
            let pillHeight = activeItem.implicitHeight + Appearance.padding.smaller * 2;

            // Ensure minimum circle size for empty workspaces
            return Math.max(pillHeight, root.implicitWidth);
        }

        anchors.horizontalCenter: parent.horizontalCenter
        y: targetY
        z: 0
        visible: activeItem !== null && targetHeight > 0

        width: root.implicitWidth
        height: targetHeight
        radius: Appearance.rounding.full
        color: Colours.primary

        Component.onCompleted: {
            // Force initial update
            y = targetY;
            height = targetHeight;
        }

        Behavior on y {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        Behavior on height {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }
    }

    // Special workspace active indicator pill (different color)
    Rectangle {
        id: specialActiveIndicator

        readonly property int currentSpecialIdx: {
            // Check if a special workspace is active by comparing workspace names
            if (root.activeSpecialWsName === "")
                return -1;

            for (let i = 0; i < specialWorkspacesRepeater.count; i++) {
                let item = specialWorkspacesRepeater.itemAt(i);
                if (item && item.wsName === root.activeSpecialWsName) {
                    return i;
                }
            }
            return -1;
        }

        readonly property var activeItem: {
            if (currentSpecialIdx < 0)
                return null;
            return specialWorkspacesRepeater.itemAt(currentSpecialIdx);
        }

        // Compute target position based on activeItem
        property real targetY: {
            if (!activeItem || activeItem.y === undefined)
                return 0;

            // Calculate workspace item's center in layout coordinates
            let itemCenterY = layout.y + activeItem.y + (activeItem.implicitHeight / 2);

            // Position pill centered on the workspace item
            return itemCenterY - (targetHeight / 2);
        }

        property real targetHeight: {
            if (!activeItem)
                return root.implicitWidth;

            // Calculate height based on implicit height (final target, not animated value)
            let pillHeight = activeItem.implicitHeight + Appearance.padding.smaller * 2;

            // Ensure minimum circle size for empty workspaces
            return Math.max(pillHeight, root.implicitWidth);
        }

        anchors.horizontalCenter: parent.horizontalCenter
        z: 0
        visible: opacity > 0
        opacity: activeItem !== null ? 1 : 0

        width: root.implicitWidth
        radius: Appearance.rounding.full
        color: Colours.secondary  // Different color for special workspaces

        scale: activeItem !== null ? 1 : 0.8

        // Track previous state to determine animation behavior
        property bool wasVisible: false
        property real storedY: 0
        property real storedHeight: root.implicitWidth
        property bool shouldAnimatePosition: false

        // Control position explicitly based on state
        y: storedY
        height: storedHeight

        onTargetYChanged: {
            if (activeItem !== null) {
                if (shouldAnimatePosition) {
                    // Animate to new position
                    storedY = targetY;
                } else {
                    // Snap immediately (disable behavior, update, re-enable)
                    yBehavior.enabled = false;
                    storedY = targetY;
                    yBehavior.enabled = shouldAnimatePosition;
                }
            }
        }

        onTargetHeightChanged: {
            if (activeItem !== null) {
                if (shouldAnimatePosition) {
                    storedHeight = targetHeight;
                } else {
                    heightBehavior.enabled = false;
                    storedHeight = targetHeight;
                    heightBehavior.enabled = shouldAnimatePosition;
                }
            }
        }

        onActiveItemChanged: {
            const nowVisible = activeItem !== null;

            if (wasVisible && !nowVisible) {
                // Fading out - keep current position
                shouldAnimatePosition = false;
            } else if (!wasVisible && nowVisible) {
                // Fading in from nothing - snap to position immediately
                shouldAnimatePosition = false;
                yBehavior.enabled = false;
                heightBehavior.enabled = false;
                storedY = targetY;
                storedHeight = targetHeight;
            } else if (wasVisible && nowVisible) {
                // Switching between special workspaces - animate
                shouldAnimatePosition = true;
                yBehavior.enabled = true;
                heightBehavior.enabled = true;
                storedY = targetY;
                storedHeight = targetHeight;
            }

            wasVisible = nowVisible;
        }

        // Y position animation - only animate when switching between special workspaces
        Behavior on y {
            id: yBehavior
            enabled: false  // Controlled manually
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        // Height animation - only animate when switching between special workspaces
        Behavior on height {
            id: heightBehavior
            enabled: false  // Controlled manually
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        // Fade and scale animation - always animate
        Behavior on opacity {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        Behavior on scale {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }
    }

    // Workspace items
    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Appearance.spacing.larger

        // Regular workspaces (1-10)
        Repeater {
            id: workspaces

            model: root.shownWorkspaces

            Workspace {
                required property int index

                wsId: index + 1
                activeWsId: root.activeWsId
                occupied: root.occupied
                groupOffset: root.groupOffset
            }
        }

        // Special workspaces (shown when they have windows)
        Repeater {
            id: specialWorkspacesRepeater

            model: root.specialWorkspaces

            Workspace {
                required property var modelData

                wsId: modelData.id
                wsName: modelData.name
                activeWsId: -1  // Not used for special workspaces
                activeSpecialWsName: root.activeSpecialWsName
                occupied: root.occupied
                groupOffset: root.groupOffset
                isSpecial: true
            }
        }
    }

    MouseArea {
        anchors.fill: layout
        onClicked: event => {
            const item = layout.childAt(event.x, event.y);
            if (item && item.ws) {
                Hyprland.dispatch(`workspace ${item.ws}`);
            }
        }
    }
}
