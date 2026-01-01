pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Weather data properties
    property string weatherIcon: "󰖐"  // Default icon
    property string temperature: "--"
    property string feelsLike: "--"
    property string condition: "Loading..."
    property bool loading: true
    property bool error: false

    // Weather code to icon mapping (Nerd Font icons)
    readonly property var weatherCodes: ({
            "113": ""  // Sunny
            ,
            "116": ""  // Partly cloudy
            ,
            "119": ""  // Cloudy
            ,
            "122": ""  // Overcast
            ,
            "143": ""  // Mist
            ,
            "176": ""  // Patchy rain possible
            ,
            "179": ""  // Patchy snow possible
            ,
            "182": ""  // Patchy sleet possible
            ,
            "185": ""  // Patchy freezing drizzle
            ,
            "200": ""  // Thundery outbreaks possible
            ,
            "227": ""  // Blowing snow
            ,
            "230": ""  // Blizzard
            ,
            "248": ""  // Fog
            ,
            "260": ""  // Freezing fog
            ,
            "263": ""  // Patchy light drizzle
            ,
            "266": ""  // Light drizzle
            ,
            "281": ""  // Freezing drizzle
            ,
            "284": ""  // Heavy freezing drizzle
            ,
            "293": ""  // Patchy light rain
            ,
            "296": ""  // Light rain
            ,
            "299": ""  // Moderate rain
            ,
            "302": ""  // Moderate rain
            ,
            "305": ""  // Heavy rain
            ,
            "308": ""  // Heavy rain
            ,
            "311": ""  // Light freezing rain
            ,
            "314": ""  // Moderate freezing rain
            ,
            "317": ""  // Heavy freezing rain
            ,
            "320": ""  // Light sleet
            ,
            "323": ""  // Light snow
            ,
            "326": ""  // Moderate snow
            ,
            "329": ""  // Heavy snow
            ,
            "332": ""  // Moderate snow
            ,
            "335": ""  // Heavy snow
            ,
            "338": ""  // Heavy snow
            ,
            "350": ""  // Ice pellets
            ,
            "353": ""  // Light rain shower
            ,
            "356": ""  // Moderate rain shower
            ,
            "359": ""  // Torrential rain shower
            ,
            "362": ""  // Light sleet shower
            ,
            "365": ""  // Moderate sleet shower
            ,
            "368": ""  // Light snow shower
            ,
            "371": ""  // Moderate snow shower
            ,
            "374": ""  // Light ice pellet shower
            ,
            "377": ""  // Moderate ice pellet shower
            ,
            "386": ""  // Thunderstorm with rain
            ,
            "389": ""  // Moderate thunderstorm
            ,
            "392": ""  // Thunderstorm with snow
            ,
            "395": ""   // Heavy thunderstorm
        })

    property string jsonBuffer: ""

    // Process to fetch weather data
    Process {
        id: weatherProcess
        command: [Quickshell.env("HOME") + "/.local/bin/quickshell-weather"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.jsonBuffer += data;
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.jsonBuffer.length > 0) {
                try {
                    let jsonData = JSON.parse(root.jsonBuffer);
                    let current = jsonData.current_condition[0];

                    root.temperature = current.temp_F + "°";
                    root.feelsLike = current.FeelsLikeF + "°";
                    root.condition = current.weatherDesc[0].value;
                    root.weatherIcon = weatherCodes[current.weatherCode] || "󰖐";
                    root.loading = false;
                    root.error = false;
                    console.log("Weather updated:", root.condition, root.temperature);
                } catch (e) {
                    console.log("Weather parse error:", e);
                    root.error = true;
                    root.loading = false;
                } finally {
                    root.jsonBuffer = "";  // Clear buffer for next fetch
                }
            } else {
                console.log("Weather fetch error, exit code:", exitCode);
                root.error = true;
                root.loading = false;
                root.jsonBuffer = "";
            }
        }

        onRunningChanged: {
            if (running) {
                root.jsonBuffer = "";  // Clear buffer when starting
            }
        }
    }

    // Timer to refresh weather data every 30 minutes
    Timer {
        interval: 30 * 60 * 1000  // 30 minutes
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            console.log("Fetching weather data...");
            root.loading = true;
            weatherProcess.running = true;
        }
    }
}
