import { App } from "astal/gtk3";
import style from "./style.scss";

import { Bar } from "./bar/Bar";
import { SystemPopup } from "./bar/System";

import { AppLauncher } from "./widget/AppLauncher";
import { NotificationPopups } from "./widget/NotificationPopups";
import { SoundNotificationWatcher } from "./widget/SoundNotificationsWatcher";

export function remapWindows() {
  App.get_windows().forEach((window) => {
    App.remove_window(window);
    window.destroy();
  });

  mapWindows();
}

function mapWindows() {
  let monitors = App.get_monitors();

  if (monitors.length === 1) {
    monitors.map(Bar);
    monitors.map(SystemPopup);
    monitors.map(NotificationPopups);
    monitors.map(AppLauncher);
    return;
  }

  monitors = monitors.filter((mon) => mon.model !== "DELL P3223QE");
  monitors.map(Bar);
  monitors.map(SystemPopup);
  monitors.map(NotificationPopups);
  monitors.map(AppLauncher);
}

App.start({
  css: style,
  main() {
    mapWindows();
  },
});
