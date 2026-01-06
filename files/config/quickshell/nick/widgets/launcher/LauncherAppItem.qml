pragma ComponentBehavior: Bound

import "../config"
import "../services"
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

// Individual application item in the launcher
Rectangle {
    id: root

    required property var app
    required property bool isSelected

    signal clicked

    width: parent.width
    height: 60
    radius: Appearance.rounding.small
    color: isSelected ? Qt.alpha(NixConfig.primary, 0.15) : (mouseArea.containsMouse ? Qt.alpha(NixConfig.textOnBackground, 0.08) : "transparent")

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.small
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        spacing: Appearance.spacing.normal

        // App icon
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            radius: Appearance.rounding.small
            color: Qt.alpha(NixConfig.primary, 0.1)

            IconImage {
                anchors.fill: parent
                anchors.margins: 6
                source: Quickshell.iconPath(root.app.icon || "", "image-missing")
                smooth: true
            }
        }

        // App info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            // App name
            Text {
                Layout.fillWidth: true
                text: root.app.name || "Unknown"
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.normal
                font.bold: true
                color: NixConfig.textOnSurface
                elide: Text.ElideRight
            }

            // App description
            Text {
                Layout.fillWidth: true
                text: root.app.description || ""
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.small
                color: NixConfig.secondary
                elide: Text.ElideRight
                visible: text !== ""
                opacity: 0.8
            }
        }
    }
}
