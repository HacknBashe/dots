import { Bar } from "./bar.js";
import { SystemPopup } from "./bar.js";
import { NotificationPopups } from "./notifications.js";
import { SoundNotificationWatcher } from "./sound-notifications-watcher.js";
// import { AppLauncherWindow } from "./app-launcher.js";

App.config({
  style: App.configDir + "/style.css",
  windows: [
    Bar(1),
    SystemPopup(1),
    NotificationPopups(1),
    SoundNotificationWatcher(),
    // AppLauncherWindow,
  ],
});
