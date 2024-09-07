const notifications = await Service.import("notifications");

export function Notifications(monitor = 0) {
  const win = Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    class_name: "notification",
    anchor: ["top", "right"],
  });

  function onNotified(_, /** @type {number} */ id) {
    const n = notifications.getNotification(id);

    if (n) {
      Utils.exec(
        `hyprctl notify -1 5000 "rgb(ff1ea3)" "${n.summary}\n\r${n.body}"`,
      );
      print(JSON.stringify(n));
    }
  }

  function onDismissed(_, /** @type {number} */ id) {}

  win
    .hook(notifications, onNotified, "notified")
    .hook(notifications, onDismissed, "dismissed");

  return win;
}
