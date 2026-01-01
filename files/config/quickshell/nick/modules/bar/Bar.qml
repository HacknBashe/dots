pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Main bar content - vertical layout
ColumnLayout {
    id: root

    // Signal to toggle the menu
    signal menuToggled()
    property bool menuOpen: false

    spacing: Appearance.spacing.normal

    // Top spacer to push content down a bit
    Item {
        Layout.preferredHeight: Appearance.padding.small
    }

    // Active window icon + title (rotated 90 degrees like caelestia)
    Item {
        id: activeWindowSection
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true

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
                    iconAnim.restart()
                    lastIcon = text
                }
            }

            scale: 1.0
            SequentialAnimation {
                id: iconAnim
                NumberAnimation { target: appIcon; property: "scale"; to: 0; duration: Appearance.anim.small / 2 }
                NumberAnimation { target: appIcon; property: "scale"; to: 1; duration: Appearance.anim.small / 2 }
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
            height: Math.min(
                activeWindowSection.showFirst ? windowText1.implicitWidth : windowText2.implicitWidth,
                activeWindowSection.availableTitleHeight
            )

            clip: true

            Behavior on height {
                Anim { duration: Appearance.anim.normal }
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
                    Anim { duration: Appearance.anim.normal }
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
                    Anim { duration: Appearance.anim.normal }
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

        // Time display (h\nmm\nAP format - 12 hour with AM/PM)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: Time.format("h\nmm\nAP")
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.larger
            color: Colours.secondary
            renderType: Text.NativeRendering
        }
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
