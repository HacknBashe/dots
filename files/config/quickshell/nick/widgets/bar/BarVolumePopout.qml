pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../shared"
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Popout window that displays audio device list
BarPopout {
    id: popout

    property bool barMouseInside: false

    shouldBeOpen: mouseInside || barMouseInside
    popoutWidth: 250

    // Get list of audio sinks using wpctl (includes both Sinks and pro-audio Filters)
    Process {
        id: listSinks
        running: true
        command: ["bash", "-c", `
            wpctl status | awk '/Sinks:|Filters:/{flag=1} /Sources:|Video/{flag=0} flag' | grep -E '^\\s*│\\s+[*]?\\s*[0-9]+\\.' | grep -v 'Audio/Source' | while IFS= read -r line; do
                id=$(echo "$line" | grep -oP '\\d+(?=\\.)')
                # Try device.nick first (like wiremix), fall back to node.nick
                device_id=$(wpctl inspect "$id" 2>/dev/null | grep 'device.id' | cut -d'"' -f2)
                if [ -n "$device_id" ]; then
                    nick=$(wpctl inspect "$device_id" 2>/dev/null | grep 'device.nick' | cut -d'"' -f2)
                fi
                if [ -z "$nick" ]; then
                    nick=$(wpctl inspect "$id" 2>/dev/null | grep 'node.nick' | cut -d'"' -f2)
                fi
                if [ -n "$nick" ]; then
                    echo "$line" | sed -E "s/([0-9]+\\.)\\s+[^[]+/\\1 $nick /"
                else
                    echo "$line"
                fi
            done
        `]

        property var sinks: []
        property string buffer: ""

        onRunningChanged: {
            if (running) {
                buffer = "";  // Clear buffer when starting
            }
        }

        stdout: SplitParser {
            onRead: data => {
                listSinks.buffer += data;
            }
        }

        onExited: {
            let sinkList = [];
            // Split by │ character which starts each sink line
            let lines = buffer.split('│').filter(s => s.trim());

            for (let line of lines) {
                if (!line.trim())
                    continue;

                // Parse: "  *   90. Soundbar                            [vol: 1.00]"
                // or:    "      48. Steam Link                          [vol: 0.20]"
                let match = line.match(/\s+([*])?\s*(\d+)\.\s+(.+?)\s+\[/);

                if (match) {
                    let isDefault = match[1] === '*';
                    let id = match[2];
                    let name = match[3].trim();

                    sinkList.push({
                        id: id,
                        name: name,
                        isDefault: isDefault
                    });
                }
            }

            listSinks.sinks = sinkList;
        }
    }

    // Refresh sink list when popout becomes visible
    onVisibleChanged: {
        if (visible) {
            listSinks.running = true;
        }
    }

    contentItem: Component {
        Item {
            width: parent.width
            height: Math.max(40, sinkColumn.height + 16)

            Column {
                id: sinkColumn
                anchors.centerIn: parent
                width: parent.width - 16
                spacing: 4

                Repeater {
                    model: listSinks.sinks

                    Rectangle {
                        id: sinkItem
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: 36
                        radius: Appearance.rounding.small
                        color: sinkMouseArea.containsMouse ? Qt.alpha(NixConfig.textOnBackground, 0.1) : "transparent"

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            spacing: 8

                            // Icon
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    let name = sinkItem.modelData.name;
                                    if (name.includes("Steam Link"))
                                        return "";
                                    if (name.includes("WiVRn"))
                                        return "";
                                    if (name.includes("Headset"))
                                        return "󰋋";
                                    if (name.includes("Quad Cortex"))
                                        return "󰺢";
                                    if (name.includes("Dongle"))
                                        return "󱡬";
                                    if (name.includes("Soundbar"))
                                        return "󰓃";
                                    return "󰓃";  // Default: speakers
                                }
                                font.family: Appearance.font.mono
                                font.pixelSize: Appearance.font.normal
                                color: sinkItem.modelData.isDefault ? NixConfig.primary : NixConfig.textOnBackground
                            }

                            // Device name
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 32
                                text: sinkItem.modelData.name
                                font.family: Appearance.font.mono
                                font.pixelSize: Appearance.font.normal
                                color: sinkItem.modelData.isDefault ? NixConfig.primary : NixConfig.textOnBackground
                                elide: Text.ElideRight
                            }
                        }

                        // Process for setting default sink
                        Process {
                            id: setDefaultSink
                            command: ["wpctl", "set-default", sinkItem.modelData.id]

                            onExited: code => {
                                // Refresh list after change
                                listSinks.running = true;
                            }
                        }

                        MouseArea {
                            id: sinkMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                setDefaultSink.running = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
