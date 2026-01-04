pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Slide-out menu content
Rectangle {
    id: root

    property bool open: false
    signal closeRequested

    // Keyboard navigation
    property int selectedButtonIndex: -1
    readonly property int buttonCount: 5  // lock, logout, suspend, restart, power

    focus: true

    Keys.onPressed: event => {
        if (!root.open)
            return;

        if (event.key === Qt.Key_Escape) {
            root.closeRequested();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            if (selectedButtonIndex < 0) {
                selectedButtonIndex = 0;
            } else {
                selectedButtonIndex = Math.max(0, selectedButtonIndex - 1);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            if (selectedButtonIndex < 0) {
                selectedButtonIndex = 0;
            } else {
                selectedButtonIndex = Math.min(buttonCount - 1, selectedButtonIndex + 1);
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (selectedButtonIndex >= 0) {
                // Trigger the selected button action
                root.closeRequested();
                if (selectedButtonIndex === 0) {
                    lockTimer.start();
                } else if (selectedButtonIndex === 1) {
                    suspendProcess.running = true;
                } else if (selectedButtonIndex === 2) {
                    logoutProcess.running = true;
                } else if (selectedButtonIndex === 3) {
                    restartProcess.running = true;
                } else if (selectedButtonIndex === 4) {
                    powerProcess.running = true;
                }
                event.accepted = true;
            }
        }
    }

    // Focus when menu opens
    onOpenChanged: {
        if (open) {
            root.forceActiveFocus();
            selectedButtonIndex = -1; // Reset selection
            calendar.currentDate = new Date(); // Reset to current month
        }
    }

    // Get lock command from environment variable set by Nix
    readonly property string lockCommand: Quickshell.env("LOCK_COMMAND") || "grim -o DP-3 -l 0 /tmp/hyprlock_screenshot1.png & grim -o HDMI-A-5 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock"

    // Timer to delay lock command so menu can close
    Timer {
        id: lockTimer
        interval: 200
        onTriggered: lockProcess.running = true
    }

    // Process runners for each action
    Process {
        id: lockProcess
        command: ["sh", "-c", root.lockCommand]
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }

    Process {
        id: restartProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: powerProcess
        command: ["systemctl", "poweroff"]
    }

    width: Math.max(buttonRow.width, calendar.width) + Appearance.padding.large * 2
    height: contentColumn.height + Appearance.padding.large * 2
    radius: Appearance.rounding.normal
    // Square corners on left side, rounded on right
    topLeftRadius: 0
    bottomLeftRadius: 0
    color: Colours.layer(Colours.background, 0)
    border.width: 0

    // No animation - instant appearance
    opacity: 1
    scale: 1

    // ResourceBar component definition
    component ResourceBar: Row {
        id: resBar
        required property string label
        required property real value
        required property string rightText
        required property color barColor

        spacing: Appearance.spacing.small

        // Label
        Text {
            width: 22
            anchors.verticalCenter: parent.verticalCenter
            text: resBar.label
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.normal
            font.bold: true
            color: resBar.barColor
            horizontalAlignment: Text.AlignLeft
        }

        // Bar container
        Rectangle {
            width: parent.width - 22 - 35 - Appearance.spacing.small * 2
            height: 6
            anchors.verticalCenter: parent.verticalCenter
            radius: Appearance.rounding.full
            color: Qt.alpha(Colours.textOnBackground, 0.1)

            // Fill bar
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, resBar.value))
                height: parent.height
                radius: parent.radius
                color: resBar.barColor

                Behavior on width {
                    NumberAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // Right text (percentage or temp)
        Text {
            width: 35
            anchors.verticalCenter: parent.verticalCenter
            text: resBar.rightText
            font.family: Appearance.font.mono
            font.pixelSize: Appearance.font.smaller
            color: resBar.barColor
            horizontalAlignment: Text.AlignRight
        }
    }

    Column {
        id: contentColumn
        anchors.centerIn: parent
        spacing: Appearance.spacing.large

        // Calendar
        Rectangle {
            id: calendarContainer
            width: Math.max(buttonRow.width, 280)
            implicitHeight: calendar.implicitHeight + Appearance.padding.large * 2
            radius: Appearance.rounding.normal
            color: Colours.layer(Colours.surfaceContainer, 0)

            Column {
                id: calendar
                anchors.centerIn: parent
                width: parent.width - Appearance.padding.large * 2
                spacing: Appearance.spacing.normal

                property date currentDate: new Date()
                property int currMonth: currentDate.getMonth()
                property int currYear: currentDate.getFullYear()

                // Month navigation
                Row {
                    width: parent.width
                    spacing: Appearance.spacing.small

                    // Previous month button
                    Rectangle {
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        radius: Appearance.rounding.full
                        color: prevMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: Appearance.font.mono
                            font.pixelSize: Appearance.font.large
                            font.bold: true
                            color: Colours.primary
                        }

                        MouseArea {
                            id: prevMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendar.currentDate = new Date(calendar.currYear, calendar.currMonth - 1, 1);
                            }
                        }
                    }

                    // Month/Year display
                    Text {
                        width: parent.width - 60 - Appearance.spacing.small * 2
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDate(calendar.currentDate, "MMMM yyyy")
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.larger
                        font.bold: true
                        font.capitalization: Font.Capitalize
                        color: Colours.primary
                    }

                    // Next month button
                    Rectangle {
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        radius: Appearance.rounding.full
                        color: nextMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: Appearance.font.mono
                            font.pixelSize: Appearance.font.large
                            color: Colours.primary
                        }

                        MouseArea {
                            id: nextMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendar.currentDate = new Date(calendar.currYear, calendar.currMonth + 1, 1);
                            }
                        }
                    }
                }

                // Day of week headers
                DayOfWeekRow {
                    width: parent.width
                    locale: Qt.locale()

                    delegate: Text {
                        required property var model
                        horizontalAlignment: Text.AlignHCenter
                        text: model.shortName
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.smaller
                        color: Colours.textOnSurface
                        opacity: 0.7
                    }
                }

                // Calendar grid
                Item {
                    width: parent.width
                    implicitHeight: grid.implicitHeight

                    MonthGrid {
                        id: grid
                        anchors.fill: parent
                        month: calendar.currMonth
                        year: calendar.currYear
                        locale: Qt.locale()
                        spacing: 2

                        delegate: Rectangle {
                            required property var model

                            implicitWidth: 36
                            implicitHeight: 36
                            color: model.today ? Colours.primary : "transparent"
                            radius: Appearance.rounding.small

                            Text {
                                anchors.centerIn: parent
                                text: model.day
                                font.family: Appearance.font.mono
                                font.pixelSize: Appearance.font.normal
                                color: model.today ? Colours.textOnPrimary : (model.month === grid.month ? Colours.textOnSurface : Colours.textOnSurface)
                                opacity: model.month === grid.month ? 1 : 0.4
                            }
                        }
                    }
                }
            }
        }

        // Weather and Performance row
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Appearance.spacing.large

            readonly property real targetWidth: Math.max(buttonRow.width, calendarContainer.width)

            // Weather section (40%)
            Rectangle {
                width: parent.targetWidth * 0.4 - Appearance.spacing.large * 0.6
                height: 120
                radius: Appearance.rounding.normal
                color: Colours.surfaceContainer

                Column {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.small

                    // Weather icon and temperature on same line
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Appearance.spacing.small

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Weather.weatherIcon
                            font.family: Appearance.font.mono
                            font.pixelSize: Appearance.font.large
                            color: Colours.primary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Weather.temperature
                            font.family: Appearance.font.mono
                            font.pixelSize: Appearance.font.larger
                            font.bold: true
                            color: Colours.textOnSurface
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Weather.condition
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.smaller
                        color: Colours.secondary
                        elide: Text.ElideRight
                        width: parent.parent.width - Appearance.padding.normal * 2
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Performance stats (60%)
            Rectangle {
                width: parent.targetWidth * 0.6 - Appearance.spacing.large * 0.4
                height: 120
                radius: Appearance.rounding.normal
                color: Colours.surfaceContainer

                Column {
                    anchors.centerIn: parent
                    width: parent.width - Appearance.padding.normal * 2
                    spacing: Appearance.spacing.small

                    // CPU
                    ResourceBar {
                        width: parent.width
                        label: ""
                        value: SystemUsage.cpuPerc
                        rightText: `${Math.round(SystemUsage.cpuTemp)}°C`
                        barColor: Colours.primary
                    }

                    // GPU
                    ResourceBar {
                        width: parent.width
                        label: "󰢮"
                        value: SystemUsage.gpuPerc
                        rightText: SystemUsage.gpuType !== "NONE" ? `${Math.round(SystemUsage.gpuTemp)}°C` : "N/A"
                        barColor: Colours.tertiary
                    }

                    // RAM
                    ResourceBar {
                        width: parent.width
                        label: ""
                        value: SystemUsage.memPerc
                        rightText: `${Math.round(SystemUsage.memPerc * 100)}%`
                        barColor: Colours.quaternary
                    }

                    // Storage
                    ResourceBar {
                        width: parent.width
                        label: ""
                        value: SystemUsage.storagePerc
                        rightText: `${Math.round(SystemUsage.storagePerc * 100)}%`
                        barColor: Colours.quinary
                    }
                }
            }
        }

        // Now Playing widget
        Rectangle {
            width: Math.max(buttonRow.width, calendarContainer.width)
            height: 120
            radius: Appearance.rounding.normal
            color: Colours.surfaceContainer
            visible: activePlayer !== null

            // Select active player with priority: playing media > paused media > any player
            // Prioritize actual music players (spotify, vlc, etc) over browsers
            readonly property var activePlayer: {
                let players = Mpris.players.values;
                if (players.length === 0)
                    return null;

                // Browser identities to deprioritize
                let browsers = ["brave", "chrome", "chromium", "firefox", "edge"];

                // First, try to find a playing non-browser player
                let playingPlayer = players.find(p => {
                    let id = p.identity.toLowerCase();
                    return p.isPlaying && !browsers.some(b => id.includes(b));
                });
                if (playingPlayer)
                    return playingPlayer;

                // Then, try any playing player (including browsers)
                playingPlayer = players.find(p => p.isPlaying);
                if (playingPlayer)
                    return playingPlayer;

                // Then, try a paused non-browser player
                let pausedPlayer = players.find(p => {
                    let id = p.identity.toLowerCase();
                    return !browsers.some(b => id.includes(b));
                });
                if (pausedPlayer)
                    return pausedPlayer;

                // Finally, fall back to first player
                return players[0];
            }

            Row {
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                spacing: Appearance.spacing.normal

                // Album art
                Rectangle {
                    width: 90
                    height: 90
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Appearance.rounding.small
                    color: Colours.surface
                    clip: true

                    // Fallback icon
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Appearance.font.mono
                        font.pixelSize: 40
                        color: Colours.secondary
                        visible: !albumArt.visible
                    }

                    Image {
                        id: albumArt
                        anchors.fill: parent
                        source: parent.parent.parent.activePlayer?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                        smooth: true
                    }
                }

                // Track info and controls
                Column {
                    width: parent.width - 90 - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing.small

                    // Track title
                    Text {
                        width: parent.width
                        text: parent.parent.parent.activePlayer?.trackTitle || "No media"
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.normal
                        font.bold: true
                        color: Colours.textOnSurface
                        elide: Text.ElideRight
                    }

                    // Artist
                    Text {
                        width: parent.width
                        text: parent.parent.parent.activePlayer?.trackArtist || "Unknown artist"
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.smaller
                        color: Colours.secondary
                        elide: Text.ElideRight
                    }

                    // Album
                    Text {
                        width: parent.width
                        text: parent.parent.parent.activePlayer?.trackAlbum || ""
                        font.family: Appearance.font.mono
                        font.pixelSize: Appearance.font.smaller
                        color: Colours.secondary
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    // Media controls
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Appearance.spacing.small

                        // Previous button
                        Rectangle {
                            width: 35
                            height: 35
                            radius: Appearance.rounding.full
                            color: mediaPrevMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"
                            visible: parent.parent.parent.parent.activePlayer?.canGoPrevious ?? false

                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.family: Appearance.font.mono
                                font.pixelSize: Appearance.font.normal
                                color: Colours.primary
                            }

                            MouseArea {
                                id: mediaPrevMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.parent.parent.parent.activePlayer?.previous()
                            }
                        }

                        // Play/Pause button
                        Rectangle {
                            width: 35
                            height: 35
                            radius: Appearance.rounding.full
                            color: mediaPlayMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"
                            visible: parent.parent.parent.parent.activePlayer?.canTogglePlaying ?? false

                            Text {
                                anchors.centerIn: parent
                                text: (parent.parent.parent.parent.parent.activePlayer?.isPlaying ?? false) ? "󰏤" : "󰐊"
                                font.family: Appearance.font.mono
                                font.pixelSize: Appearance.font.normal
                                color: Colours.primary
                            }

                            MouseArea {
                                id: mediaPlayMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.parent.parent.parent.activePlayer?.togglePlaying()
                            }
                        }

                        // Next button
                        Rectangle {
                            width: 35
                            height: 35
                            radius: Appearance.rounding.full
                            color: mediaNextMouseArea.containsMouse ? Qt.alpha(Colours.textOnBackground, 0.1) : "transparent"
                            visible: parent.parent.parent.parent.activePlayer?.canGoNext ?? false

                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.family: Appearance.font.mono
                                font.pixelSize: Appearance.font.normal
                                color: Colours.primary
                            }

                            MouseArea {
                                id: mediaNextMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.parent.parent.parent.activePlayer?.next()
                            }
                        }
                    }
                }
            }
        }

        // Divider
        Rectangle {
            width: Math.max(buttonRow.width, calendar.width)
            height: 1
            color: Colours.outline
            opacity: 0.3
        }

        // Power buttons row
        Row {
            id: buttonRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Appearance.spacing.normal

            // Lock button
            Rectangle {
                width: 50
                height: 50
                radius: Appearance.rounding.small
                color: root.selectedButtonIndex === 0 ? Colours.primary : Colours.surfaceContainer
                scale: lockMouseArea.containsMouse || root.selectedButtonIndex === 0 ? 1.1 : 1.0
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.Linear
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.OutBack
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    font.bold: true
                    color: root.selectedButtonIndex === 0 ? Colours.textOnPrimary : Colours.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.anim.small
                            easing.type: Easing.Linear
                        }
                    }
                }

                MouseArea {
                    id: lockMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.closeRequested();
                        lockTimer.start();
                    }

                    onEntered: root.selectedButtonIndex = 0
                }
            }

            // Suspend button
            Rectangle {
                width: 50
                height: 50
                radius: Appearance.rounding.small
                color: root.selectedButtonIndex === 1 ? Colours.primary : Colours.surfaceContainer
                scale: suspendMouseArea.containsMouse || root.selectedButtonIndex === 1 ? 1.1 : 1.0
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.Linear
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.OutBack
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰒲"
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: root.selectedButtonIndex === 1 ? Colours.textOnPrimary : Colours.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.anim.small
                            easing.type: Easing.Linear
                        }
                    }
                }

                MouseArea {
                    id: suspendMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.closeRequested();
                        suspendProcess.running = true;
                    }

                    onEntered: root.selectedButtonIndex = 1
                }
            }

            // Logout button
            Rectangle {
                width: 50
                height: 50
                radius: Appearance.rounding.small
                color: root.selectedButtonIndex === 2 ? Colours.primary : Colours.surfaceContainer
                scale: logoutMouseArea.containsMouse || root.selectedButtonIndex === 2 ? 1.1 : 1.0
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.Linear
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.OutBack
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰍃"
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: root.selectedButtonIndex === 2 ? Colours.textOnPrimary : Colours.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.anim.small
                            easing.type: Easing.Linear
                        }
                    }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.closeRequested();
                        logoutProcess.running = true;
                    }

                    onEntered: root.selectedButtonIndex = 2
                }
            }

            // Restart button
            Rectangle {
                width: 50
                height: 50
                radius: Appearance.rounding.small
                color: root.selectedButtonIndex === 3 ? Colours.primary : Colours.surfaceContainer
                scale: restartMouseArea.containsMouse || root.selectedButtonIndex === 3 ? 1.1 : 1.0
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.Linear
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.OutBack
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰜉"
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: root.selectedButtonIndex === 3 ? Colours.textOnPrimary : Colours.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.anim.small
                            easing.type: Easing.Linear
                        }
                    }
                }

                MouseArea {
                    id: restartMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.closeRequested();
                        restartProcess.running = true;
                    }

                    onEntered: root.selectedButtonIndex = 3
                }
            }

            // Power off button
            Rectangle {
                width: 50
                height: 50
                radius: Appearance.rounding.small
                color: root.selectedButtonIndex === 4 ? Colours.primary : Colours.surfaceContainer
                scale: powerMouseArea.containsMouse || root.selectedButtonIndex === 4 ? 1.1 : 1.0
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.Linear
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.anim.small
                        easing.type: Easing.OutBack
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰐥"
                    font.family: Appearance.font.mono
                    font.pixelSize: Appearance.font.large
                    color: root.selectedButtonIndex === 4 ? Colours.textOnPrimary : Colours.primary

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.anim.small
                            easing.type: Easing.Linear
                        }
                    }
                }

                MouseArea {
                    id: powerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.closeRequested();
                        powerProcess.running = true;
                    }

                    onEntered: root.selectedButtonIndex = 4
                }
            }
        }
    }
}
