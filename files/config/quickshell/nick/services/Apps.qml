pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // All available desktop applications - use property binding
    property var allApps: {
        let apps = [];
        let entries = DesktopEntries.applications.values;

        if (!entries) {
            return [];
        }

        for (let i = 0; i < entries.length; i++) {
            let entry = entries[i];
            
            // Skip apps without names or that are hidden
            if (!entry.name || entry.noDisplay) {
                continue;
            }

            apps.push({
                name: entry.name,
                description: entry.comment || "",
                icon: entry.icon || "",
                command: entry.command || [],
                runInTerminal: entry.runInTerminal || false,
                workingDirectory: entry.workingDirectory || Quickshell.env("HOME"),
                entry: entry
            });
        }

        // Sort alphabetically by name
        apps.sort((a, b) => a.name.localeCompare(b.name));
        
        return apps;
    }

    // Simple fuzzy search function
    function search(query) {
        if (!query || query.trim() === "") {
            return allApps;
        }

        let searchLower = query.toLowerCase().trim();
        let results = [];

        for (let i = 0; i < allApps.length; i++) {
            let app = allApps[i];
            let nameLower = app.name.toLowerCase();
            let descLower = app.description.toLowerCase();
            
            // Check if query matches name or description
            if (nameLower.includes(searchLower) || descLower.includes(searchLower)) {
                results.push(app);
            }
        }

        return results;
    }

    // Launch an application
    function launch(app) {
        if (!app || !app.command || app.command.length === 0) {
            console.log("Cannot launch app:", app ? app.name : "unknown", "- invalid or missing command");
            return false;
        }

        // Filter out desktop entry field codes (%f, %F, %u, %U, %d, %D, %n, %N, %i, %c, %k, %v, %m)
        // These are placeholders for file paths, URLs, etc. and shouldn't be passed literally
        let cleanCommand = app.command.filter(arg => !arg.match(/^%[a-zA-Z]$/));
        
        if (cleanCommand.length === 0) {
            console.log("Cannot launch app:", app.name, "- command only contained field codes");
            return false;
        }

        console.log("Launching app:", app.name, "with command:", cleanCommand);

        try {
            if (app.runInTerminal) {
                // Launch in ghostty terminal using -e flag
                let terminalCmd = ["ghostty", "-e"];
                terminalCmd = terminalCmd.concat(cleanCommand);
                
                Quickshell.execDetached({
                    command: terminalCmd,
                    workingDirectory: app.workingDirectory
                });
            } else {
                // Launch regular app
                Quickshell.execDetached({
                    command: cleanCommand,
                    workingDirectory: app.workingDirectory
                });
            }
            
            console.log("Successfully launched:", app.name);
            return true;
        } catch (e) {
            console.log("Failed to launch app:", app.name, "Error:", e);
            return false;
        }
    }
}
