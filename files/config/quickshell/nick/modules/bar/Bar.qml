pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import "../../components/workspaces"
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Main bar content - vertical layout
ColumnLayout {
    id: root

    // Signal to toggle the menu
    signal menuToggled()
    property bool menuOpen: false

    // Tray hover tracking
    property int hoveredTrayIndex: -1
    property SystemTrayItem hoveredTrayItem: null
    property real trayPopoutTargetY: 0

    spacing: Appearance.spacing.normal

    // Function to update tray hover state based on mouse Y position
    function updateTrayHover(mouseY) {
        let idx = calculateTrayIndex(mouseY);

        // Update if index changed OR if hoveredTrayItem was cleared (e.g., after menu click)
        if (idx !== hoveredTrayIndex || (idx >= 0 && hoveredTrayItem === null)) {
            hoveredTrayIndex = idx;

            if (idx >= 0 && idx < trayRepeater.count) {
                hoveredTrayItem = trayRepeater.itemAt(idx).modelData;

                // Calculate centered Y position for popout
                let trayStartY = traySection.y;
                let iconCenterY = trayStartY + (idx * (32 + Appearance.spacing.small)) + 16;

                // Estimate menu height (will be adjusted by popout based on actual content)
                let estimatedMenuHeight = 200;
                trayPopoutTargetY = iconCenterY - (estimatedMenuHeight / 2);

                // Clamp to screen bounds (with padding)
                trayPopoutTargetY = Math.max(16, Math.min(trayPopoutTargetY, root.height - estimatedMenuHeight - 16));
            } else {
                hoveredTrayItem = null;
            }
        }
    }

    // Function to calculate which tray icon (if any) is hovered
    function calculateTrayIndex(mouseY) {
        // Tray section Y position
        let trayStartY = traySection.y;
        let relativeY = mouseY - trayStartY;

        if (relativeY < 0)
            return -1;

        let iconHeight = 32;
        let iconSpacing = Appearance.spacing.small;
        let totalPerIcon = iconHeight + iconSpacing;

        let idx = Math.floor(relativeY / totalPerIcon);

        // Check if mouse is actually over icon (not in gap between icons)
        let yInIcon = relativeY % totalPerIcon;
        if (yInIcon > iconHeight)
            return -1;

        // Bounds check - use Repeater count
        if (idx < 0 || idx >= trayRepeater.count)
            return -1;

        return idx;
    }

    // Function to clear tray hover state
    function clearTrayHover() {
        console.log("clearTrayHover called");
        hoveredTrayIndex = -1;
        hoveredTrayItem = null;
    }

    // Function to close tray popout (called from menu item click)
    function closeTrayPopout() {
        console.log("closeTrayPopout called");
        hoveredTrayIndex = -1;
        hoveredTrayItem = null;
    }

    // Function to handle tray icon clicks
    function handleTrayClick(mouseY, button) {
        let idx = calculateTrayIndex(mouseY);
        if (idx >= 0 && idx < trayRepeater.count) {
            let item = trayRepeater.itemAt(idx).modelData;
            if (button === Qt.LeftButton) {
                item.activate();
            } else if (button === Qt.RightButton) {
                item.secondaryActivate();
            }
        }
    }

    // Top spacer to push content down a bit
    Item {
        Layout.preferredHeight: Appearance.padding.small
    }

    // Workspace indicator
    Workspaces {
        Layout.alignment: Qt.AlignHCenter
    }

    // Active window icon + title (rotated 90 degrees like caelestia)
    Item {
        id: activeWindowSection
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true
        Layout.minimumHeight: 100  // Ensure active window doesn't disappear

        readonly property string windowClass: Hyprland.activeToplevel?.lastIpcObject.class ?? ""
        readonly property string windowTitle: Hyprland.activeToplevel?.title ?? "Desktop"
        property bool showFirst: true
        // Available height for title = section height minus icon and spacing
        readonly property real availableTitleHeight: height - appIcon.height - Appearance.spacing.small

        implicitWidth: Math.max(appIcon.implicitWidth, titleContainer.width)

        onWindowTitleChanged: showFirst = !showFirst

        // App icon
        Text {
            id: appIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -(titleContainer.height + Appearance.spacing.small) / 2
            text: Icons.getAppIcon(activeWindowSection.windowClass)
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.large
            color: Colours.primary

            // Animate icon changes with scale
            property string lastIcon: text
            onTextChanged: {
                if (text !== lastIcon) {
                    iconAnim.restart();
                    lastIcon = text;
                }
            }

            scale: 1.0
            SequentialAnimation {
                id: iconAnim
                NumberAnimation {
                    target: appIcon
                    property: "scale"
                    to: 0
                    duration: Appearance.anim.small / 2
                }
                NumberAnimation {
                    target: appIcon
                    property: "scale"
                    to: 1
                    duration: Appearance.anim.small / 2
                }
            }
        }

        // Window title (rotated) - two texts for crossfade animation
        Item {
            id: titleContainer

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (appIcon.height + Appearance.spacing.small) / 2
            anchors.topMargin: Appearance.spacing.small

            width: activeWindowSection.showFirst ? windowText1.height : windowText2.height
            height: Math.min(activeWindowSection.showFirst ? windowText1.implicitWidth : windowText2.implicitWidth, activeWindowSection.availableTitleHeight)

            clip: true

            Behavior on height {
                Anim {
                    duration: Appearance.anim.normal
                }
            }

            Text {
                id: windowText1

                x: (parent.width - height) / 2
                y: parent.height

                text: activeWindowSection.showFirst ? activeWindowSection.windowTitle : text
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.large
                color: Colours.primary
                opacity: activeWindowSection.showFirst ? 1 : 0

                rotation: -90
                transformOrigin: Item.TopLeft

                Behavior on opacity {
                    Anim {
                        duration: Appearance.anim.normal
                    }
                }
            }

            Text {
                id: windowText2

                x: (parent.width - height) / 2
                y: parent.height

                text: activeWindowSection.showFirst ? text : activeWindowSection.windowTitle
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.large
                color: Colours.primary
                opacity: activeWindowSection.showFirst ? 0 : 1

                rotation: -90
                transformOrigin: Item.TopLeft

                Behavior on opacity {
                    Anim {
                        duration: Appearance.anim.normal
                    }
                }
            }
        }
    }

    // System tray section
    Column {
        id: traySection
        Layout.alignment: Qt.AlignHCenter
        spacing: Appearance.spacing.small

        Repeater {
            id: trayRepeater
            model: SystemTray.items

            Rectangle {
                required property SystemTrayItem modelData
                required property int index

                width: 32
                height: 32
                anchors.horizontalCenter: parent.horizontalCenter
                radius: Appearance.rounding.full
                color: "transparent"

                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: parent.modelData.icon
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }
    }

    // Clock section
    Column {
        Layout.alignment: Qt.AlignHCenter

        spacing: Appearance.spacing.small

        // Calendar icon
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "󰸗"
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.large
            color: Colours.secondary
        }

        // Time display (hh\nmm\nAP format - 12 hour with AM/PM, zero-padded)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: Time.format("hh\nmm\nAP")
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.larger
            color: Colours.secondary
            renderType: Text.NativeRendering
        }
    }

    // Volume widget
    Volume {
        Layout.alignment: Qt.AlignHCenter
    }

    // Bottom section - Nix logo button (opens menu)
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        Layout.bottomMargin: Appearance.padding.small

        Rectangle {
            id: nixButton
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Colours.surfaceContainer

            Text {
                anchors.centerIn: parent
                text: "󱄅"
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.large
                color: Colours.primary
            }

            MouseArea {
                id: nixMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.menuToggled()
            }

            // Hover overlay
            Rectangle {
                anchors.fill: parent
                radius: nixButton.radius
                color: nixMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"
            }
        }
    }
}
