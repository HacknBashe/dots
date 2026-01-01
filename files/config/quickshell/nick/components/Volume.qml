pragma ComponentBehavior: Bound

import "../config"
import "../services"
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Volume widget with speaker icon and percentage
Item {
    id: root
    
    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight
    
    property int volume: 50
    
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
                        root.volume = Math.max(0, Math.min(100, vol));
                    }
                }
            }
        }
    }
    
    // Poll volume every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: getVolume.running = true
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
    
    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Appearance.spacing.small
        
        // Speaker icon (changes based on volume level)
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: speakerIcon.implicitWidth
            implicitHeight: speakerIcon.implicitHeight
            
            Text {
                id: speakerIcon
                anchors.centerIn: parent
                text: {
                    if (root.volume === 0) return "󰖁";  // Muted
                    if (root.volume < 33) return "󰕿";   // Low
                    if (root.volume < 66) return "󰖀";   // Medium
                    return "󰕾";                          // High
                }
                font.family: Appearance.font.mono
                font.pixelSize: Appearance.font.large
                color: Colours.secondary
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
                font.pixelSize: Appearance.font.normal
                color: Colours.secondary
            }
        }
    }
    
    // Mouse area for scroll wheel control - overlays the entire widget
    MouseArea {
        anchors.fill: parent
        z: 2000  // Place above the bar's hover detection MouseArea
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                volumeUp.running = true;
            } else {
                volumeDown.running = true;
            }
            wheel.accepted = true;
        }
    }
}
