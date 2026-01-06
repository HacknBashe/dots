import "../../config"
import "../../services"
import "../"
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property int wsId
    required property int activeWsId
    required property var occupied
    required property int groupOffset
    property bool isSpecial: false
    property string wsName: ""
    property string activeSpecialWsName: ""  // For special workspaces
    property bool isGhost: false  // Set by parent when animating out

    // Signal when removal animation completes
    signal removalAnimationComplete()

    readonly property int ws: wsId
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool hasWindows: isOccupied
    readonly property bool isActive: isSpecial ? (wsName === activeSpecialWsName) : (activeWsId === ws)

    // Track if this is a newly created workspace to enable entrance animation
    property bool _isNewlyCreated: true

    Component.onCompleted: {
        // On next frame, mark as no longer new to trigger entrance animation
        Qt.callLater(() => {
            _isNewlyCreated = false;
        });
    }

    // Map special workspace names to letters
    readonly property string specialLetter: {
        if (!isSpecial)
            return "";
        if (wsName.includes("player"))
            return "P";
        if (wsName.includes("notes") || wsName.includes("Notes"))
            return "N";
        if (wsName.includes("movie"))
            return "M";
        return "S";  // Default for other special workspaces
    }

    anchors.left: parent.left
    anchors.right: parent.right
    Layout.alignment: Qt.AlignHCenter
    z: 20

    spacing: 0
    clip: true

    // Animate opacity with height for smoother appearance
    // New workspaces start at 0 opacity and animate in
    opacity: {
        if (_isNewlyCreated && !isGhost) {
            return 0;  // Start invisible for new items
        }
        return isGhost ? 0 : 1;
    }

    // Animate scale slightly for a nicer effect
    // New workspaces start scaled down and animate in
    scale: {
        if (_isNewlyCreated && !isGhost) {
            return 0.8;  // Start scaled down for new items
        }
        return isGhost ? 0.8 : 1.0;
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim.small
            easing.type: Easing.Linear
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Appearance.anim.small
            easing.type: Easing.Bezier
            easing.bezierCurve: Appearance.anim.standard
        }
    }

    // Detect when removal animation completes
    onOpacityChanged: {
        if (isGhost && opacity <= 0.01) {
            // Animation finished - notify parent
            console.log("Workspace", wsId, "emitting removalAnimationComplete signal - opacity:", opacity);
            removalAnimationComplete();
            console.log("Workspace", wsId, "signal emitted");
        }
    }

    // Workspace number/letter
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 5
        anchors.left: root.left
        anchors.right: root.right
        implicitHeight: numberText.implicitHeight

        Text {
            id: numberText
            width: root.width
            anchors.left: root.left
            anchors.right: root.right
            horizontalAlignment: Text.AlignHCenter

            text: root.isSpecial ? root.specialLetter : root.ws
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.large
            color: root.isActive ? NixConfig.textOnPrimary : NixConfig.textOnSurface

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.small
                    easing.type: Easing.Linear
                }
            }
        }
    }

    // Window icons - vertical stack
    Column {
        id: windows

        anchors.left: root.left
        anchors.right: root.right
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 4
        Layout.bottomMargin: 5

        visible: root.hasWindows
        spacing: 2

        Repeater {
            id: windowRepeater

            // Filter toplevels for this workspace
            // Force re-evaluation when toplevels.values changes
            model: {
                // Access values to trigger reactivity
                const toplevels = Hyprland.toplevels.values;
                if (!toplevels)
                    return [];

                // Filter for this workspace
                const filtered = toplevels.filter(window => window.workspace?.id === root.ws);

                // Force a new array to trigger model updates
                // But include a timestamp/counter to force re-render
                return filtered.map(w => w);
            }

            Item {
                required property var modelData
                required property int index

                property var windowId: modelData?.address || null

                // Directly compute windowClass from Hyprland.toplevels, making it reactive
                // Workspaces.qml listens to Hyprland events and calls refreshToplevels()
                // when windows open, which populates lastIpcObject.class
                readonly property string windowClass: {
                    if (!windowId)
                        return "";

                    // Always re-query to get the latest data
                    // This makes the property reactive to Hyprland.toplevels changes
                    const toplevels = Hyprland.toplevels.values || [];
                    const window = toplevels.find(w => w.address === windowId);

                    if (!window)
                        return "";

                    // Try lastIpcObject.class
                    const cls = window.lastIpcObject?.class;
                    if (cls)
                        return cls;

                    // Fallback to empty
                    return "";
                }

                implicitHeight: iconText.implicitHeight
                width: root.width

                Text {
                    id: iconText
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Icons.getAppIcon(parent.windowClass)
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: root.isActive ? NixConfig.textOnPrimary : NixConfig.textOnSurface

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.anim.small
                            easing.type: Easing.Linear
                        }
                    }
                }
            }
        }
    }
}
