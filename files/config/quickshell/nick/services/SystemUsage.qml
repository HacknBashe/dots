pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuPerc: 0
    property real cpuTemp: 0
    property string gpuType: "NONE"
    property real gpuPerc: 0
    property real gpuTemp: 0
    property real memUsed: 0
    property real memTotal: 1
    readonly property real memPerc: memTotal > 0 ? memUsed / memTotal : 0
    property real storageUsed: 0
    property real storageTotal: 1
    readonly property real storagePerc: storageTotal > 0 ? storageUsed / storageTotal : 0

    property real lastCpuIdle: 0
    property real lastCpuTotal: 0

    function formatKib(kib) {
        const mib = 1024;
        const gib = 1024 * 1024;
        const tib = 1024 * 1024 * 1024;

        if (kib >= tib) {
            return { value: kib / tib, unit: "TiB" };
        }
        if (kib >= gib) {
            return { value: kib / gib, unit: "GiB" };
        }
        if (kib >= mib) {
            return { value: kib / mib, unit: "MiB" };
        }
        return { value: kib, unit: "KiB" };
    }

    Timer {
        running: true
        interval: 3000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            storage.running = true;
            gpuUsage.running = true;
            sensorsCheck.running = true;
        }
    }

    // Check if sensors command exists
    Process {
        id: sensorsCheck
        command: ["sh", "-c", "if command -v sensors &>/dev/null; then sensors; else cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1; fi"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                // Try sensors output first
                let cpuTemp = text.match(/(?:Package id [0-9]+|Tdie):\s+((\+|-)[0-9.]+)(°| )C/);
                if (!cpuTemp) {
                    cpuTemp = text.match(/Tctl:\s+((\+|-)[0-9.]+)(°| )C/);
                }
                
                if (cpuTemp) {
                    root.cpuTemp = parseFloat(cpuTemp[1]);
                } else {
                    // Fallback to thermal zone (in millidegrees)
                    const thermalTemp = parseInt(text.trim(), 10);
                    if (!isNaN(thermalTemp)) {
                        root.cpuTemp = thermalTemp / 1000;
                    }
                }

                // GPU temperature for Generic GPU
                if (root.gpuType !== "GENERIC")
                    return;

                let eligible = false;
                let sum = 0;
                let count = 0;

                for (const line of text.trim().split("\n")) {
                    if (line === "Adapter: PCI adapter")
                        eligible = true;
                    else if (line === "")
                        eligible = false;
                    else if (eligible) {
                        let match = line.match(/^(temp[0-9]+|GPU core|edge)+:\s+\+([0-9]+\.[0-9]+)(°| )C/);
                        if (!match)
                            match = line.match(/^(junction|mem)+:\s+\+([0-9]+\.[0-9]+)(°| )C/);

                        if (match) {
                            sum += parseFloat(match[2]);
                            count++;
                        }
                    }
                }

                root.gpuTemp = count > 0 ? sum / count : 0;
            }
        }
    }

    // CPU usage from /proc/stat
    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const data = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (data) {
                const stats = data.slice(1).map(n => parseInt(n, 10));
                const total = stats.reduce((a, b) => a + b, 0);
                const idle = stats[3] + (stats[4] || 0);

                const totalDiff = total - root.lastCpuTotal;
                const idleDiff = idle - root.lastCpuIdle;
                root.cpuPerc = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;

                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
    }

    // Memory from /proc/meminfo
    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const data = text();
            const totalMatch = data.match(/MemTotal:\s*(\d+)/);
            const availMatch = data.match(/MemAvailable:\s*(\d+)/);
            if (totalMatch && availMatch) {
                root.memTotal = parseInt(totalMatch[1], 10) || 1;
                root.memUsed = root.memTotal - parseInt(availMatch[1], 10);
            }
        }
    }

    // Storage usage
    Process {
        id: storage
        command: ["sh", "-c", "df | grep '^/dev/' | awk '{print $1, $3, $4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const deviceMap = new Map();

                for (const line of lines) {
                    if (line.trim() === "") continue;

                    const parts = line.trim().split(/\s+/);
                    if (parts.length >= 3) {
                        const device = parts[0];
                        const used = parseInt(parts[1], 10) || 0;
                        const avail = parseInt(parts[2], 10) || 0;

                        if (!deviceMap.has(device) || (used + avail) > (deviceMap.get(device).used + deviceMap.get(device).avail)) {
                            deviceMap.set(device, { used: used, avail: avail });
                        }
                    }
                }

                let totalUsed = 0;
                let totalAvail = 0;

                for (const [device, stats] of deviceMap) {
                    totalUsed += stats.used;
                    totalAvail += stats.avail;
                }

                root.storageUsed = totalUsed;
                root.storageTotal = totalUsed + totalAvail;
            }
        }
    }

    // GPU type detection
    Process {
        id: gpuTypeCheck
        running: true
        command: ["sh", "-c", "if command -v nvidia-smi &>/dev/null && nvidia-smi -L &>/dev/null; then echo NVIDIA; elif ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | grep -q .; then echo GENERIC; else echo NONE; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.gpuType = text.trim();
            }
        }
    }

    // GPU usage
    Process {
        id: gpuUsage
        command: root.gpuType === "GENERIC" 
            ? ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent"] 
            : root.gpuType === "NVIDIA" 
            ? ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"] 
            : ["echo"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.gpuType === "GENERIC") {
                    const percs = text.trim().split("\n");
                    const sum = percs.reduce((acc, d) => acc + parseInt(d, 10), 0);
                    root.gpuPerc = sum / percs.length / 100;
                } else if (root.gpuType === "NVIDIA") {
                    const [usage, temp] = text.trim().split(",");
                    root.gpuPerc = parseInt(usage, 10) / 100;
                    root.gpuTemp = parseInt(temp, 10);
                } else {
                    root.gpuPerc = 0;
                    root.gpuTemp = 0;
                }
            }
        }
    }


}
