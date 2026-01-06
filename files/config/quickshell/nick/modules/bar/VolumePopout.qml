pragma ComponentBehavior: Bound

import "../../config"
import "../../services"
import "../../components"
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Popout window that displays audio device list
Popout {
    id: popout

    property bool barMouseInside: false

    shouldBeOpen: mouseInside || barMouseInside
    popoutWidth: 250

    // Get list of audio sinks using wpctl
    Process {
        id: listSinks
        running: true
        command: ["bash", "-c", "wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '^\\s*│\\s+[*]?\\s*[0-9]+\\.'"]

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
