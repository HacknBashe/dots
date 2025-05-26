import { App, Gdk, Gtk } from "astal/gtk3";
import style from "./style.scss";
import { timeout } from "astal";

import { Bar } from "./bar/Bar";
import { SystemPopup } from "./bar/System";

import { AppLauncher } from "./widget/AppLauncher";
import { NotificationPopups } from "./widget/NotificationPopups";
import { OSD } from "./widget/OSD";

App.start({
  css: style,
  main() {
    let monitors: Gdk.Monitor[] = App.get_monitors();

    let bars = new Map<Gdk.Monitor, Gtk.Widget>();
    let systemPopups = new Map<Gdk.Monitor, Gtk.Widget>();

    monitors.map(NotificationPopups);
    monitors.map(AppLauncher);
    monitors.map(OSD);

    function handleMonitor(gdkmonitor: Gdk.Monitor) {
      bars.get(gdkmonitor)?.destroy();
      bars.delete(gdkmonitor);
      systemPopups.get(gdkmonitor)?.destroy();
      systemPopups.delete(gdkmonitor);

      if (gdkmonitor.get_model() === "DELL P3223QE") {
        const hasUltrawide = App.get_monitors().some(
          (m) => m.get_model() === "Dell AW3418DW",
        );
        if (hasUltrawide) return;
      }

      systemPopups.set(gdkmonitor, SystemPopup(gdkmonitor));
      bars.set(gdkmonitor, Bar(gdkmonitor));
    }

    function updateAllMonitors() {
      timeout(50, () => {
        App.get_monitors().forEach((gdkmonitor) => handleMonitor(gdkmonitor));
      });
    }

    App.connect("monitor-added", () => {
      updateAllMonitors();
    });

    App.connect("monitor-removed", () => {
      updateAllMonitors();
    });

    updateAllMonitors();
  },
});
