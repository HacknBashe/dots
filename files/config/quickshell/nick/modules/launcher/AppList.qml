pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import QtQuick
import QtQuick.Controls

// Scrollable list of applications
Item {
    id: root

    property var apps: []
    property int currentIndex: 0
    property int maxVisible: 8

    signal appSelected(var app)

    // Update current index when apps list changes
    onAppsChanged: {
        if (currentIndex >= apps.length) {
            currentIndex = Math.max(0, apps.length - 1);
        }
    }

    // Calculate visible height
    implicitHeight: Math.min(apps.length, maxVisible) * 60 + Appearance.spacing.smaller * (Math.min(apps.length, maxVisible) - 1)

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: Appearance.rounding.small
    }

    // Scrollable list view
    ListView {
        id: listView

        anchors.fill: parent
        clip: true
        spacing: Appearance.spacing.smaller

        model: root.apps
        currentIndex: root.currentIndex

        // Smooth scrolling
        highlightMoveDuration: Appearance.anim.small
        highlightMoveVelocity: -1

        delegate: AppItem {
            required property var modelData
            required property int index

            app: modelData
            isSelected: index === root.currentIndex

            onClicked: {
                root.currentIndex = index;
                root.appSelected(modelData);
            }
        }

        // No apps found message
        Text {
            anchors.centerIn: parent
            visible: root.apps.length === 0
            text: "No applications found"
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.normal
            color: Colours.secondary
            opacity: 0.7
        }

        // Scrollbar
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded

            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: Qt.alpha(Colours.primary, parent.pressed ? 0.5 : (parent.hovered ? 0.3 : 0.2))

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.small
                    }
                }
            }
        }
    }

    // Navigation functions
    function moveUp() {
        if (currentIndex > 0) {
            currentIndex--;
            ensureVisible(currentIndex);
        }
    }

    function moveDown() {
        if (currentIndex < apps.length - 1) {
            currentIndex++;
            ensureVisible(currentIndex);
        }
    }

    function getCurrentApp() {
        if (currentIndex >= 0 && currentIndex < apps.length) {
            return apps[currentIndex];
        }
        return null;
    }

    function ensureVisible(index) {
        listView.positionViewAtIndex(index, ListView.Contain);
    }
}
