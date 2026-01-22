pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Volume widget with speaker icon and percentage
Item {
    id: root

    implicitWidth: 60
    implicitHeight: column.implicitHeight + Appearance.padding.small * 2

    property int volume: 50
    property string deviceName: ""
    property bool isHovered: false

    // Get current default sink device name
    Process {
        id: getDevice
        running: true
        command: ["/etc/profiles/per-user/nick/bin/pulsemixer", "--list-sinks"]

        stdout: SplitParser {
            onRead: data => {
                // Parse the output to find the default sink
                let lines = data.trim().split('\n');
                for (let line of lines) {
                    if (line.includes('Default')) {
                        // Extract the Name field
                        let nameMatch = line.match(/Name: ([^,]+)/);
                        if (nameMatch) {
                            root.deviceName = nameMatch[1].trim();
                        }
                        break;
                    }
                }
            }
        }
    }

    // Get current volume from pulsemixer
    Process {
        id: getVolume
        running: true
        command: ["/etc/profiles/per-user/nick/bin/pulsemixer", "--get-volume"]

        stdout: SplitParser {
            onRead: data => {
                // pulsemixer outputs "LEFT RIGHT" (e.g., "50 50")
                let parts = data.trim().split(/\s+/);
                if (parts.length > 0) {
                    let vol = parseInt(parts[0]);
                    if (!isNaN(vol)) {
                        root.volume = Math.max(0, vol);  // Allow values over 100%
                    }
                }
            }
        }
    }

    // Poll volume and device every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            getVolume.running = true;
            getDevice.running = true;
        }
    }

    // Processes for changing volume (separate for increase/decrease)
    Process {
        id: volumeUp
        command: ["/etc/profiles/per-user/nick/bin/pulsemixer", "--change-volume", "+5"]

        onExited: {
            getVolume.running = true;
        }
    }

    Process {
        id: volumeDown
        command: ["/etc/profiles/per-user/nick/bin/pulsemixer", "--change-volume", "-5"]

        onExited: {
            getVolume.running = true;
        }
    }

    // Background rectangle for hover effect
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: root.isHovered ? Qt.alpha(NixConfig.textOnBackground, 0.08) : "transparent"
        z: -1

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.small
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        // Device icon
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: deviceIcon.implicitWidth
            implicitHeight: deviceIcon.implicitHeight

            Text {
                id: deviceIcon
                anchors.centerIn: parent
                text: {
                    let device = root.deviceName.toLowerCase();
                    if (device.includes("headset") || device.includes("headphone"))
                        return "󰋋";  // Headset
                    if (device.includes("quad cortex"))
                        return "󰺢";  // Quad Cortex
                    if (device.includes("bluetooth") || device.includes("bt"))
                        return "󰂯";  // Bluetooth
                    if (device.includes("soundbar") || device.includes("speaker"))
                        return "󰓃";  // Soundbar/Speakers
                    if (device.includes("steam"))
                        return "󰓓";  // Steam/Gaming
                    if (device.includes("hdmi") || device.includes("displayport"))
                        return "󰍹";  // HDMI/Display
                    return "󰓃";  // Default to speakers
                }
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.large
                color: NixConfig.secondary
            }
        }

        // Volume percentage
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: volumeText.implicitWidth
            implicitHeight: volumeText.implicitHeight

            Text {
                id: volumeText
                anchors.centerIn: parent
                text: root.volume + "%"
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.larger
                color: NixConfig.secondary
            }
        }
    }

    // Mouse area for scroll wheel control - overlays the entire widget
    MouseArea {
        id: volumeMouseArea
        anchors.fill: parent
        z: 2000  // Place above the bar's hover detection MouseArea
        hoverEnabled: false
        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                volumeUp.running = true;
            } else {
                volumeDown.running = true;
            }
            wheel.accepted = true;
        }
    }
}
