pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import QtQuick

// Individual menu item component for tray popout menus
// Handles both regular items and separators
Item {
    id: root

    required property var menuEntry
    signal clicked

    width: 200
    height: menuEntry.isSeparator ? 8 : 36

    // Regular menu item
    Rectangle {
        id: itemBackground
        anchors.fill: parent
        visible: !root.menuEntry.isSeparator
        color: itemMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"
        radius: Appearance.rounding.small

        Behavior on color {
            Anim {
                duration: Appearance.anim.small
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Appearance.padding.small
            anchors.rightMargin: Appearance.padding.small
            spacing: Appearance.spacing.small

            // Icon
            Image {
                id: iconImage
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                source: root.menuEntry.icon ?? ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: source !== ""
            }

            // Text label
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.menuEntry.text ?? ""
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.normal
                color: root.menuEntry.enabled ? Colours.textOnBackground : Qt.alpha(Colours.textOnBackground, 0.5)
                elide: Text.ElideRight
                width: parent.width - (iconImage.visible ? iconImage.width + parent.spacing : 0)
            }
        }

        MouseArea {
            id: itemMouseArea
            anchors.fill: parent
            enabled: root.menuEntry.enabled
            hoverEnabled: true
            cursorShape: root.menuEntry.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (root.menuEntry.enabled) {
                    root.menuEntry.triggered();
                    root.clicked();
                }
            }
        }
    }

    // Separator
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - Appearance.padding.small * 2
        height: 1
        visible: root.menuEntry.isSeparator
        color: Qt.alpha(Colours.textOnBackground, 0.2)
    }
}
