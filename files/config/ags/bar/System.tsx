import { execAsync } from "astal";
import { App, Astal, Gdk } from "astal/gtk3";

const WINDOW_NAME = "SystemPopup";
const LOCK_COMMAND =
  "grim -o DP-4 -l 0 /tmp/hyprlock_screenshot1.png & grim -o DP-3 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock";

export function System() {
  return (
    <button className="system" onClick={() => App.toggle_window(WINDOW_NAME)}>
      󱄅
    </button>
  );
}

function lock() {
  App.toggle_window(WINDOW_NAME);
  execAsync(["bash", "-c", LOCK_COMMAND]);
}

function logout() {
  App.toggle_window(WINDOW_NAME);
  execAsync(["wayland-logout"]);
}

function sleep() {
  App.toggle_window(WINDOW_NAME);
  execAsync(["bash", "-c", LOCK_COMMAND + " & sleep 1 && systemctl suspend"]);
}

function hibernate() {
  App.toggle_window(WINDOW_NAME);
  execAsync(["bash", "-c", LOCK_COMMAND + " & sleep 1 && systemctl hibernate"]);
}

function reboot() {
  App.toggle_window(WINDOW_NAME);
  execAsync(["systemctl", "reboot"]);
}

function poweroff() {
  App.toggle_window(WINDOW_NAME);
  execAsync(["systemctl", "poweroff"]);
}

export function SystemPopup(monitor: Gdk.Monitor) {
  const { BOTTOM, LEFT } = Astal.WindowAnchor;

  return (
    <window
      name={WINDOW_NAME}
      className="system-popup"
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={BOTTOM | LEFT}
      visible={false}
      keymode={Astal.Keymode.EXCLUSIVE}
      onKeyPressEvent={(_, event: Gdk.Event) => {
        switch (event.get_keyval()[1]) {
          case Gdk.KEY_l:
            lock();
            break;
          case Gdk.KEY_o:
            logout();
            break;
          case Gdk.KEY_s:
            sleep();
            break;
          case Gdk.KEY_h:
            hibernate();
            break;
          case Gdk.KEY_r:
            reboot();
            break;
          case Gdk.KEY_p:
            poweroff();
            break;
          case Gdk.KEY_Escape:
            App.toggle_window(WINDOW_NAME);
            break;
        }
      }}
      setup={(self: Astal.Window) => {
        App.add_window(self);
      }}
    >
      <box>
        <button onClick={lock}>󰌾</button>
        <button onClick={logout}>󰍃</button>
        <button onClick={sleep}>󰤄</button>
        {/* <button onClick={hibernate}>󰒲</button> */}
        <button onClick={reboot}>󰜉</button>
        <button onClick={poweroff}>󰐥</button>
      </box>
    </window>
  );
}
