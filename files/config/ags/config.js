const Gdk = imports.gi.Gdk;
const display = Gdk.Display.get_default();

import { Bar } from "./bar.js";
import { SystemPopup } from "./bar.js";
import { NotificationPopups } from "./notifications.js";
import { SoundNotificationWatcher } from "./sound-notifications-watcher.js";
import { AppLauncherWindow } from "./app-launcher.js";

function getAWMonitor() {
  const numMonitors = display.get_n_monitors();
  for (let id = 0; id < numMonitors; ++id) {
    if (display.get_monitor(id).model.includes("AW")) {
      return id;
    }
  }
}
const AWMonitorId = getAWMonitor();

App.config({
  style: App.configDir + "/style.css",
  windows: [
    Bar(AWMonitorId),
    SystemPopup(AWMonitorId),
    NotificationPopups(AWMonitorId),
    SoundNotificationWatcher(AWMonitorId),
    AppLauncherWindow,
  ],
});
