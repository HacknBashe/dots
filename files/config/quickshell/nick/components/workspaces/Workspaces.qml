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
    radius: Appearance.rounding.normal

    // Track active workspace
    readonly property int activeWsId: Hyprland.focusedWorkspace?.id ?? 1
    
    // Track active special workspace - check if active toplevel is in a special workspace
    readonly property int activeSpecialWsId: {
        let wsId = Hyprland.activeToplevel?.workspace?.id ?? 0;
        console.log("Active toplevel workspace ID:", wsId);
        // Special workspaces have negative IDs
        return (wsId < 0) ? wsId : 0;
    }

    // Build occupied workspaces map (using caelestia's approach with .values)
    readonly property var occupied: {
        // Hyprland.workspaces is a QML map, use .values to get array
        const values = Hyprland.workspaces.values || [];

        // Use reduce like caelestia does
        return values.reduce((acc, curr) => {
            acc[curr.id] = curr.lastIpcObject.windows > 0;
            return acc;
        }, {});
    }
    
    // Get list of special workspaces with windows
    readonly property var specialWorkspaces: {
        const values = Hyprland.workspaces.values || [];
        return values.filter(ws => ws.id < 0 && ws.lastIpcObject.windows > 0)
                     .sort((a, b) => b.id - a.id); // Sort by ID descending (most negative first)
    }

    readonly property int groupOffset: 0
    readonly property int shownWorkspaces: 10

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
            if (currentWsIdx < 0) return null;
            return workspaces.itemAt(currentWsIdx);
        }

        anchors.horizontalCenter: parent.horizontalCenter
        y: (activeItem?.y ?? 0) + Appearance.padding.normal
        z: 0
        visible: activeItem !== null

        width: 46
        height: activeItem?.height ?? 38
        radius: Appearance.rounding.full
        color: Colours.primary

        Behavior on y {
            Anim {
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }

        Behavior on height {
            Anim {
                duration: Appearance.anim.normal
                easing.bezierCurve: Appearance.anim.emphasized
            }
        }
    }
    
    // Special workspace active indicator pill (different color)
    Rectangle {
        id: specialActiveIndicator

        readonly property int currentSpecialIdx: {
            // Check if a special workspace is active (using monitor's specialWorkspace)
            if (root.activeSpecialWsId === 0) return -1;
            
            for (let i = 0; i < specialWorkspacesRepeater.count; i++) {
                let item = specialWorkspacesRepeater.itemAt(i);
                if (item && item.ws === root.activeSpecialWsId) {
                    return i;
                }
            }
            return -1;
        }
        
        readonly property var activeItem: {
            if (currentSpecialIdx < 0) return null;
            return specialWorkspacesRepeater.itemAt(currentSpecialIdx);
        }
        
        // Store last valid position to prevent flicker
        property real lastY: 0
        property real lastHeight: 38
        
        onActiveItemChanged: {
            if (activeItem !== null) {
                lastY = activeItem.y;
                lastHeight = activeItem.height;
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        y: lastY + Appearance.padding.normal
        z: 0
        visible: opacity > 0
        opacity: activeItem !== null ? 1 : 0

        width: 46
        height: lastHeight
        radius: Appearance.rounding.full
        color: Colours.secondary  // Different color for special workspaces
        
        scale: activeItem !== null ? 1 : 0.8
        
        // Fade and scale animation
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
        spacing: Appearance.spacing.small

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
                activeWsId: root.activeSpecialWsId
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
