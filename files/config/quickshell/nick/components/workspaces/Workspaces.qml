pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../"
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: 64
    implicitHeight: {
        // Base layout height plus minimal padding
        let baseHeight = mainLayout.implicitHeight;
        return baseHeight + Appearance.padding.small * 2;
    }

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

    // Track workspaces that are animating out (ghosts)
    property var animatingOutMon1: []
    property var animatingOutMon2: []

    // Timer to clean up finished animations
    Timer {
        id: cleanupTimer
        interval: Appearance.anim.small + 50 // Slightly longer than animation
        repeat: false
        onTriggered: {
            console.log("Cleanup: removing ghosts");
            animatingOutMon1 = [];
            animatingOutMon2 = [];
        }
    }

    // Get current "real" workspaces for monitor 1
    readonly property var currentMonitor1Workspaces: {
        const values = Hyprland.workspaces.values || [];
        const wsIds = [];

        for (let i = 1; i <= root.shownWorkspaces; i++) {
            const ws = values.find(w => w.id === i);
            if (ws && ws.lastIpcObject?.monitor === "DP-3") {
                wsIds.push(i);
            } else if (!ws && i === activeWsId && Hyprland.focusedMonitor?.name === "DP-3") {
                wsIds.push(i);
            }
        }

        return wsIds;
    }

    // Get current "real" workspaces for monitor 2
    readonly property var currentMonitor2Workspaces: {
        const values = Hyprland.workspaces.values || [];
        const wsIds = [];

        for (let i = 1; i <= root.shownWorkspaces; i++) {
            const ws = values.find(w => w.id === i);
            if (ws && ws.lastIpcObject?.monitor === "HDMI-A-5") {
                wsIds.push(i);
            } else if (!ws && i === activeWsId && Hyprland.focusedMonitor?.name === "HDMI-A-5") {
                wsIds.push(i);
            }
        }

        return wsIds;
    }

    property var previousMonitor1Workspaces: []
    property var previousMonitor2Workspaces: []

    // Final workspace lists including ghosts
    readonly property var monitor1Workspaces: {
        const combined = new Set([...currentMonitor1Workspaces, ...animatingOutMon1]);
        return Array.from(combined).sort((a, b) => a - b);
    }

    readonly property var monitor2Workspaces: {
        const combined = new Set([...currentMonitor2Workspaces, ...animatingOutMon2]);
        return Array.from(combined).sort((a, b) => a - b);
    }

    // Watch for changes and update ghost lists
    onCurrentMonitor1WorkspacesChanged: {
        console.log("Monitor 1 workspaces changed:", JSON.stringify(currentMonitor1Workspaces));

        // Find removed workspaces
        const removed = previousMonitor1Workspaces.filter(id => !currentMonitor1Workspaces.includes(id));
        if (removed.length > 0) {
            console.log("Monitor 1 removed:", JSON.stringify(removed));
            animatingOutMon1 = removed;
            cleanupTimer.restart();
        }

        previousMonitor1Workspaces = currentMonitor1Workspaces;
    }

    onCurrentMonitor2WorkspacesChanged: {
        console.log("Monitor 2 workspaces changed:", JSON.stringify(currentMonitor2Workspaces));

        // Find removed workspaces
        const removed = previousMonitor2Workspaces.filter(id => !currentMonitor2Workspaces.includes(id));
        if (removed.length > 0) {
            console.log("Monitor 2 removed:", JSON.stringify(removed));
            animatingOutMon2 = removed;
            cleanupTimer.restart();
        }

        previousMonitor2Workspaces = currentMonitor2Workspaces;
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

    // Background for column 1
    Rectangle {
        id: column1Background
        x: regularWorkspacesRow.x + column1Container.x
        y: regularWorkspacesRow.y + column1Container.y
        width: 30
        height: column1.implicitHeight + Appearance.padding.small * 2
        color: Colours.layer(Colours.surfaceContainer, 0)
        radius: Appearance.rounding.full
        z: 0
        visible: column1Repeater.count > 0

        Behavior on height {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        Behavior on y {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }
    }

    // Background for column 2
    Rectangle {
        id: column2Background
        x: regularWorkspacesRow.x + column2Container.x
        y: regularWorkspacesRow.y + column2Container.y
        width: 30
        height: column2.implicitHeight + Appearance.padding.small * 2
        color: Colours.layer(Colours.surfaceContainer, 0)
        radius: Appearance.rounding.full
        z: 0
        visible: column2Repeater.count > 0

        Behavior on height {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        Behavior on y {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }
    }

    // Background for special workspaces
    Rectangle {
        id: specialBackground
        x: specialWorkspacesContainer.x
        y: specialWorkspacesContainer.y
        width: 30
        height: specialWorkspacesColumn.implicitHeight + Appearance.padding.small * 2
        color: Colours.layer(Colours.surfaceContainer, 0)
        radius: Appearance.rounding.full
        z: 0
        visible: specialWorkspacesRepeater.count > 0

        Behavior on height {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }

        Behavior on y {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
        }
    }

    // Main layout container
    ColumnLayout {
        id: mainLayout

        anchors.centerIn: parent
        spacing: Appearance.spacing.larger
        z: 10

        // Regular workspaces - two columns side by side
        RowLayout {
            id: regularWorkspacesRow

            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            // Column 1: Monitor 1 (DP-3) workspaces
            Item {
                id: column1Container
                Layout.preferredWidth: 30
                Layout.preferredHeight: column1.implicitHeight
                visible: column1Repeater.count > 0

                ColumnLayout {
                    id: column1

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Appearance.spacing.larger

                    Repeater {
                        id: column1Repeater

                        model: root.monitor1Workspaces

                        Workspace {
                            id: workspaceItem
                            required property int modelData

                            // Check if this workspace is "real" or a ghost animating out
                            readonly property bool _isGhost: {
                                const values = Hyprland.workspaces.values || [];
                                const workspace = values.find(w => w.id === modelData);

                                // Ghost if workspace doesn't exist on DP-3 and isn't active on DP-3
                                if (workspace && workspace.lastIpcObject?.monitor === "DP-3") {
                                    return false;
                                }
                                if (modelData === root.activeWsId && Hyprland.focusedMonitor?.name === "DP-3") {
                                    return false;
                                }
                                return true;
                            }

                            wsId: modelData
                            activeWsId: root.activeWsId
                            occupied: root.occupied
                            groupOffset: root.groupOffset
                            isGhost: _isGhost

                            // Store the target height
                            readonly property real targetHeight: _isGhost ? 0 : implicitHeight

                            // Explicitly set height and animate it
                            Layout.preferredHeight: targetHeight

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: Appearance.anim.small
                                    easing.type: Easing.Bezier
                                    easing.bezierCurve: Appearance.anim.standard
                                }
                            }
                        }
                    }
                }
            }

            // Column 2: Monitor 2 (HDMI-A-5) workspaces
            Item {
                id: column2Container
                Layout.preferredWidth: 30
                Layout.preferredHeight: column2.implicitHeight
                visible: column2Repeater.count > 0

                ColumnLayout {
                    id: column2

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Appearance.spacing.larger

                    Repeater {
                        id: column2Repeater

                        model: root.monitor2Workspaces

                        Workspace {
                            id: workspaceItem
                            required property int modelData

                            // Check if this workspace is "real" or a ghost animating out
                            readonly property bool _isGhost: {
                                const values = Hyprland.workspaces.values || [];
                                const workspace = values.find(w => w.id === modelData);

                                // Ghost if workspace doesn't exist on HDMI-A-5 and isn't active on HDMI-A-5
                                if (workspace && workspace.lastIpcObject?.monitor === "HDMI-A-5") {
                                    return false;
                                }
                                if (modelData === root.activeWsId && Hyprland.focusedMonitor?.name === "HDMI-A-5") {
                                    return false;
                                }
                                return true;
                            }

                            wsId: modelData
                            activeWsId: root.activeWsId
                            occupied: root.occupied
                            groupOffset: root.groupOffset
                            isGhost: _isGhost

                            // Store the target height
                            readonly property real targetHeight: _isGhost ? 0 : implicitHeight

                            // Explicitly set height and animate it
                            Layout.preferredHeight: targetHeight

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: Appearance.anim.small
                                    easing.type: Easing.Bezier
                                    easing.bezierCurve: Appearance.anim.standard
                                }
                            }
                        }
                    }
                }
            }
        }

        // Special workspaces - vertical column centered below
        Item {
            id: specialWorkspacesContainer
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 30
            Layout.preferredHeight: specialWorkspacesColumn.implicitHeight
            visible: specialWorkspacesRepeater.count > 0

            ColumnLayout {
                id: specialWorkspacesColumn

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Appearance.spacing.larger

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
        }
    }

    // Regular workspace active indicator pill
    Rectangle {
        id: activeIndicator

        // Determine which column and index contains the active workspace
        readonly property var activeColumn: {
            if (activeWsId < 1 || activeWsId > root.shownWorkspaces)
                return null;

            // Check column 1
            const col1Idx = root.monitor1Workspaces.indexOf(activeWsId);
            if (col1Idx >= 0) {
                return {
                    column: column1,
                    repeater: column1Repeater,
                    index: col1Idx,
                    container: column1Container
                };
            }

            // Check column 2
            const col2Idx = root.monitor2Workspaces.indexOf(activeWsId);
            if (col2Idx >= 0) {
                return {
                    column: column2,
                    repeater: column2Repeater,
                    index: col2Idx,
                    container: column2Container
                };
            }

            return null;
        }

        readonly property var activeItem: {
            if (!activeColumn)
                return null;

            let item = activeColumn.repeater.itemAt(activeColumn.index);
            // Access repeater count to ensure QML tracks this dependency
            let _ = activeColumn.repeater.count;
            // Force re-evaluation by checking the item exists and has valid geometry
            if (item && item.implicitHeight !== undefined)
                return item;
            return item;
        }

        // Store computed position to ensure it updates when activeItem changes
        property real targetX: {
            if (!activeItem || !activeColumn)
                return 0;

            // Get container's X position relative to root
            const containerX = activeColumn.container.x;
            if (containerX === undefined || containerX === null)
                return 0;

            // Get container's width
            const containerWidth = activeColumn.container.width || 30;

            // Center pill on the container
            return regularWorkspacesRow.x + containerX + (containerWidth / 2) - (width / 2);
        }

        property real targetY: {
            if (!activeItem || !activeColumn)
                return 0;

            const itemY = activeItem.y;
            if (itemY === undefined || itemY === null)
                return 0;

            // Calculate workspace item's center in absolute coordinates
            // Account for: regularWorkspacesRow -> container -> column -> item
            // The container has padding.small on top, and column is vertically centered in container
            let itemCenterY = regularWorkspacesRow.y + activeColumn.container.y + Appearance.padding.small + activeColumn.column.y + itemY + (activeItem.implicitHeight / 2);

            // Position pill centered on the workspace item
            return itemCenterY - (targetHeight / 2);
        }

        property real targetHeight: {
            if (!activeItem)
                return targetWidth;

            // Calculate height based on implicit height (final target, not animated value)
            let pillHeight = activeItem.implicitHeight + Appearance.padding.small * 2;

            // Ensure minimum circle size for empty workspaces
            return Math.max(pillHeight, targetWidth);
        }

        property real targetWidth: {
            // Use container's width (fixed at 30)
            if (!activeItem || !activeColumn)
                return 30;

            return activeColumn.container.width || 30;
        }

        x: targetX
        y: targetY
        z: 5
        visible: activeItem !== null && targetHeight > 0

        width: targetWidth
        height: targetHeight
        radius: Appearance.rounding.full
        color: Colours.primary

        Component.onCompleted: {
            // Force initial update
            x = targetX;
            y = targetY;
            height = targetHeight;
        }

        Behavior on x {
            Anim {
                duration: Appearance.anim.small
                easing.bezierCurve: Appearance.anim.standard
            }
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
        property real targetX: {
            // Center horizontally on the special workspaces container
            if (!specialWorkspacesContainer)
                return 0;

            const containerX = specialWorkspacesContainer.x;
            const containerWidth = specialWorkspacesContainer.width || 30;

            return containerX + (containerWidth / 2) - (width / 2);
        }

        property real targetY: {
            if (!activeItem || activeItem.y === undefined)
                return 0;

            // Calculate workspace item's center in absolute coordinates
            // Account for: container -> column -> item
            // The container has padding.small on top, and column is vertically centered in container
            let itemCenterY = specialWorkspacesContainer.y + Appearance.padding.small + specialWorkspacesColumn.y + activeItem.y + (activeItem.implicitHeight / 2);

            // Position pill centered on the workspace item
            return itemCenterY - (targetHeight / 2);
        }

        property real targetHeight: {
            if (!activeItem)
                return targetWidth;

            // Calculate height based on implicit height (final target, not animated value)
            let pillHeight = activeItem.implicitHeight + Appearance.padding.small * 2;

            // Ensure minimum circle size for empty workspaces
            return Math.max(pillHeight, targetWidth);
        }

        property real targetWidth: {
            // Use container's width (fixed at 30)
            return specialWorkspacesContainer ? specialWorkspacesContainer.width : 30;
        }

        x: targetX
        z: 5
        visible: opacity > 0
        opacity: activeItem !== null ? 1 : 0

        width: targetWidth
        radius: Appearance.rounding.full
        color: Colours.secondary  // Different color for special workspaces

        scale: activeItem !== null ? 1 : 0.8

        // Track previous state to determine animation behavior
        property bool wasVisible: false
        property real storedY: 0
        property real storedHeight: 25
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
    MouseArea {
        anchors.fill: mainLayout
        onClicked: event => {
            // Check regular workspaces in both columns
            let item = column1.childAt(event.x - column1.x, event.y - column1.y);
            if (!item) {
                item = column2.childAt(event.x - column2.x, event.y - column2.y);
            }
            // Check special workspaces
            if (!item) {
                item = specialWorkspacesColumn.childAt(event.x - specialWorkspacesColumn.x, event.y - specialWorkspacesColumn.y);
            }

            if (item && item.ws) {
                Hyprland.dispatch(`workspace ${item.ws}`);
            }
        }
    }
}
