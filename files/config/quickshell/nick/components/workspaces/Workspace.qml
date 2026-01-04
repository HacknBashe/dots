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

    readonly property int ws: wsId
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool hasWindows: isOccupied
    readonly property bool isActive: isSpecial ? (wsName === activeSpecialWsName) : (activeWsId === ws)

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

    // Hide empty workspaces (special workspaces only show when occupied)
    visible: isSpecial ? isOccupied : (isOccupied || activeWsId === ws)

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: visible ? implicitHeight : 0
    z: 20

    spacing: 0

    // Workspace number/letter
    Item {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: numberText.implicitWidth
        implicitHeight: numberText.implicitHeight

        Text {
            id: numberText
            anchors.centerIn: parent

            text: root.isSpecial ? root.specialLetter : root.ws
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.large
            color: root.isActive ? Colours.textOnPrimary : Colours.textOnSurface

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

        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 4

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

                implicitWidth: iconText.implicitWidth
                implicitHeight: iconText.implicitHeight

                Text {
                    id: iconText
                    anchors.centerIn: parent

                    text: Icons.getAppIcon(parent.windowClass)
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: root.isActive ? Colours.textOnPrimary : Colours.textOnSurface

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

    Behavior on Layout.preferredHeight {
        Anim {
            duration: Appearance.anim.small
            easing.bezierCurve: Appearance.anim.standard
        }
    }
}
