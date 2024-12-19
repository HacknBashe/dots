const audio = await Service.import("audio");
const notifications = await Service.import("notifications");

let notificationId = 80000;

export function SoundNotificationWatcher(monitor = 0) {
  let vol = (audio.speaker.volume * 100).toString().split(".")[0],
    muted = null;

  const win = Widget.Window({
    monitor,
    name: `sound-notification${monitor}`,
    class_name: "sound-notification",
    anchor: ["top", "right"],
  });

  function onSpeakerChanged(_) {
    let newVol = Math.round(audio.speaker.volume * 100)
      .toString()
      .split(".")[0];
    let newMuted = audio.speaker.is_muted;

    if (newVol > vol) {
      vol = newVol;
      notifications.getNotification(notificationId)?.dismiss();
      Utils.notify({
        id: ++notificationId,
        summary: `Volume increased to ${vol}%`,
        iconName: "audio-volume-high-symbolic",
        timeout: 2000,
      });
    } else if (newVol < vol) {
      vol = newVol;
      notifications.getNotification(notificationId)?.dismiss();
      Utils.notify({
        id: ++notificationId,
        summary: `Volume decreased to ${vol}%`,
        iconName: "audio-volume-low-symbolic",
        timeout: 2000,
      });
    } else if (newMuted !== muted) {
      if (muted !== null) {
        Utils.notify({
          summary: `${newMuted ? "Muted" : "Unmuted"}`,
          iconName: `${newMuted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic"}`,
          timeout: 2000,
        });
      }
      muted = newMuted;
    }
  }

  win.hook(audio.speaker, onSpeakerChanged);

  return win;
}
