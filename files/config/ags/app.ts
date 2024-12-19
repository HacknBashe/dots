import { App } from "astal/gtk3";
import style from "./style.scss";

import { Bar } from "./bar/Bar";
import { SystemPopup } from "./bar/System";

import { AppLauncher } from "./widget/AppLauncher";
import { NotificationPopups } from "./widget/NotificationPopups";
import { SoundNotificationWatcher } from "./widget/SoundNotificationsWatcher";

App.start({
  css: style,
  main() {
    App.get_monitors().map(Bar);
    App.get_monitors().map(SystemPopup);
    App.get_monitors().map(NotificationPopups);
    App.get_monitors().map(AppLauncher);
  },
});
