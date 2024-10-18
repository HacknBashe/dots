import { Bar } from "./bar.js";
import { NotificationPopups } from "./notifications.js";
import { SoundNotificationWatcher } from "./sound-notifications-watcher.js";

App.config({
  style: App.configDir + "/style.css",
  windows: [Bar(1), NotificationPopups(1), SoundNotificationWatcher()],
});
