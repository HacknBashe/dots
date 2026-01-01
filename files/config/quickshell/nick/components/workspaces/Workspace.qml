import "../../config"
import "../../services"
import "../"
import Quickshell.Hyprland
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

    readonly property int ws: wsId
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool hasWindows: isOccupied
    
    // Map special workspace names to letters
    readonly property string specialLetter: {
        if (!isSpecial) return "";
        if (wsName.includes("player")) return "P";
        if (wsName.includes("notes") || wsName.includes("Notes")) return "N";
        if (wsName.includes("movie")) return "M";
        return "S";  // Default for other special workspaces
    }

    // Hide empty workspaces (special workspaces only show when occupied)
    visible: isSpecial ? isOccupied : (isOccupied || activeWsId === ws)

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: visible ? implicitHeight : 0

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
            color: (root.activeWsId === root.ws) ? Colours.textOnPrimary : Colours.textOnSurface
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
            model: {
                // Use .values to get reactive array like caelestia does
                const toplevels = Hyprland.toplevels.values || [];
                return toplevels.filter(window => window.workspace?.id === root.ws);
            }

            Item {
                required property var modelData

                implicitWidth: iconText.implicitWidth
                implicitHeight: iconText.implicitHeight

                Text {
                    id: iconText
                    anchors.centerIn: parent

                    text: Icons.getAppIcon(parent.modelData.lastIpcObject.class)
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: (root.activeWsId === root.ws) ? Colours.textOnPrimary : Colours.textOnSurface
                }
            }
        }
    }

    Behavior on Layout.preferredHeight {
        Anim {
            duration: Appearance.anim.normal
        }
    }
}
