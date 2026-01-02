pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Main launcher content with search and results
FocusScope {
    id: root

    property bool open: false
    property real screenHeight: 1080
    signal closeRequested()

    width: 600
    height: contentColumn.height + Appearance.padding.large * 2
    focus: true
    clip: true
    
    Behavior on height {
        NumberAnimation {
            duration: Appearance.anim.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Colours.surface
        border.width: 1
        border.color: Qt.alpha(Colours.outline, 0.2)
    }

    // Slide animation from bottom
    // Calculate offset: half screen height + half launcher height + extra margin
    transform: Translate {
        id: slideTransform
        y: root.open ? 0 : (root.screenHeight / 2 + root.height / 2 + 50)
        
        Behavior on y {
            NumberAnimation {
                duration: Appearance.anim.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.expressiveDefaultSpatial
            }
        }
    }

    // Focus handling - focus search field when opened
    onOpenChanged: {
        if (open) {
            searchField.text = "";  // Clear text before sliding in
            root.focus = true;
            searchField.focus = true;
            searchField.forceActiveFocus();
        }
        // Don't clear text on close - it causes height animation during slide out
    }

    ColumnLayout {
        id: contentColumn
        
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        // Search field
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            radius: Appearance.rounding.full
            color: Colours.surfaceContainer
            border.width: searchField.activeFocus ? 2 : 0
            border.color: Colours.primary

            Behavior on border.width {
                NumberAnimation {
                    duration: Appearance.anim.small
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.larger
                anchors.rightMargin: Appearance.padding.normal
                spacing: Appearance.spacing.normal

                // Search icon
                Text {
                    text: "󰍉"
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.larger
                    color: Colours.primary
                }

                // Text input
                TextInput {
                    id: searchField
                    
                    Layout.fillWidth: true
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.normal
                    color: Colours.textOnSurface
                    selectionColor: Colours.primary
                    selectedTextColor: Colours.textOnPrimary
                    clip: true
                    focus: true
                    activeFocusOnTab: true
                    
                    Text {
                        anchors.fill: parent
                        text: "Search applications..."
                        font: searchField.font
                        color: Colours.secondary
                        opacity: 0.5
                        visible: searchField.text === "" && !searchField.activeFocus
                    }

                    // Key navigation
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.closeRequested();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            appList.moveUp();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            appList.moveDown();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            let app = appList.getCurrentApp();
                            if (app) {
                                if (Apps.launch(app)) {
                                    root.closeRequested();
                                }
                            }
                            event.accepted = true;
                        }
                    }
                }

                // Clear button
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: Appearance.rounding.full
                    color: clearMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"
                    visible: searchField.text !== ""

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.normal
                        color: Colours.secondary
                    }

                    MouseArea {
                        id: clearMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchField.text = "";
                            searchField.forceActiveFocus();
                        }
                    }
                }
            }
        }

        // App list
        AppList {
            id: appList
            
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.maximumHeight: 480
            
            apps: Apps.search(searchField.text)
            
            onAppSelected: app => {
                if (Apps.launch(app)) {
                    root.closeRequested();
                }
            }
        }
    }
}
