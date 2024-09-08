const audio = await Service.import("audio");

export function SoundNotifications(monitor = 0) {
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
    let newMuted = audio.speaker.isMuted;

    if (newVol > vol) {
      vol = newVol;
      Utils.exec(`hyprctl dismissnotify`);
      Utils.exec(`hyprctl notify -1 2000 "rgb(ff1ea3)" "   ${vol}"`);
    } else if (newVol < vol) {
      vol = newVol;
      Utils.exec(`hyprctl dismissnotify`);
      Utils.exec(`hyprctl notify -1 2000 "rgb(ff1ea3)" "  ${vol}"`);
    } else if (newMuted !== muted) {
      if (muted !== null) {
        Utils.exec(
          `hyprctl notify -1 2000 "rgb(ff1ea3)" "${muted ? "󰝟  Muted" : "   Unmuted"} ${newVol}"`,
        );
      }
      muted = newMuted;
    }
  }

  win.hook(audio.speaker, onSpeakerChanged);

  return win;
}
