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
    implicitHeight: layout.implicitHeight + Appearance.padding.normal * 2

    color: Colours.surfaceContainer
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
            // Force reactivity by accessing repeater count
            let _ = workspaces.count;
            // Force re-evaluation by checking the item exists and has valid geometry
            if (item && item.implicitHeight !== undefined)
                return item;
            return item;
        }

        // Check if active item is the last visible item in the layout
        readonly property bool isLastVisibleWorkspace: {
            if (!activeItem)
                return false;
            // Check if this is the last item by comparing y + height with layout height
            let itemBottom = activeItem.y + activeItem.height;
            return Math.abs(itemBottom - layout.height) < 1; // Within 1px tolerance
        }

        // Store computed position to ensure it updates when activeItem changes
        property real targetY: {
            if (!activeItem)
                return 0;

            // Wait for y to be defined (layout complete)
            const itemY = activeItem.y;
            if (itemY === undefined || itemY === null)
                return 0;

            // Check if this is the first visible workspace (y position is 0 in layout)
            if (itemY === 0) {
                // First visible workspace - pill should be flush at top (y=0)
                return 0;
            }
            // Check if this is the last visible workspace
            if (isLastVisibleWorkspace) {
                // Last visible - position so pill bottom is flush with container bottom
                return root.implicitHeight - targetHeight;
            }
            // For middle workspaces
            // If it's a perfect circle (empty workspace), center it on the item
            let baseHeight = activeItem.implicitHeight + Appearance.padding.smaller * 2;
            if (baseHeight < root.implicitWidth) {
                // Perfect circle - center on the workspace item
                return layout.y + itemY + (activeItem.implicitHeight / 2) - (root.implicitWidth / 2);
            }
            // Otherwise, position relative to layout with padding
            return layout.y + itemY - Appearance.padding.smaller;
        }

        property real targetHeight: {
            if (!activeItem)
                return root.implicitWidth;

            const itemY = activeItem.y;
            if (itemY === undefined || itemY === null)
                return root.implicitWidth;

            let baseHeight = activeItem.height + Appearance.padding.smaller * 2;

            // For empty workspaces (small height), make it a perfect circle
            if (baseHeight < root.implicitWidth) {
                baseHeight = root.implicitWidth; // Same as width for perfect circle
            }

            // Check if this is the first visible workspace
            if (itemY === 0) {
                // First visible - extend pill to cover padding area to reach top
                return Math.max(baseHeight, activeItem.height + layout.y + Appearance.padding.smaller);
            }
            // Check if this is the last visible workspace
            if (isLastVisibleWorkspace) {
                // Last visible - extend pill to cover padding area to reach bottom
                let remainingSpace = root.implicitHeight - (layout.y + itemY);
                return Math.max(baseHeight, remainingSpace + Appearance.padding.smaller);
            }
            // For middle workspaces, ensure minimum circle size
            return baseHeight;
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
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }

        Behavior on height {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.emphasized
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

        // Check if this special workspace is at the end of the layout (last visible item)
        readonly property bool isLastVisibleItem: {
            if (!activeItem)
                return false;
            let itemBottom = activeItem.y + activeItem.height;
            return Math.abs(itemBottom - layout.height) < 1;
        }

        // Compute target position based on activeItem
        property real targetY: {
            if (activeItem && activeItem.y !== undefined) {
                // Check if first visible item in layout (should be at top)
                if (activeItem.y === 0) {
                    return 0;
                }
                // Check if last visible item in layout (should be at bottom)
                if (isLastVisibleItem) {
                    return root.implicitHeight - targetHeight;
                }
                // Middle items - normal positioning with padding
                return layout.y + activeItem.y - Appearance.padding.smaller;
            }
            return 0;
        }

        property real targetHeight: {
            if (activeItem && activeItem.y !== undefined) {
                let baseHeight = activeItem.height + Appearance.padding.smaller * 2;

                // For empty/small items, make it a perfect circle
                if (baseHeight < root.implicitWidth) {
                    baseHeight = root.implicitWidth;
                }

                // First visible - extend to top
                if (activeItem.y === 0) {
                    return Math.max(baseHeight, activeItem.height + layout.y + Appearance.padding.smaller);
                }
                // Last visible - extend to bottom
                if (isLastVisibleItem) {
                    let remainingSpace = root.implicitHeight - (layout.y + activeItem.y);
                    return Math.max(baseHeight, remainingSpace + Appearance.padding.smaller);
                }
                // Middle items - ensure minimum circle size
                return baseHeight;
            }
            return root.implicitWidth; // Perfect circle for fallback
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
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }

        // Height animation - only animate when switching between special workspaces
        Behavior on height {
            id: heightBehavior
            enabled: false  // Controlled manually
            Anim {
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
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
