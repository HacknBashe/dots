import { Astal, Gtk, Gdk } from "astal/gtk3";

import { Workspaces, FocusedClient } from "./Workspaces";
import { Media } from "./Media";
import { Tray } from "./Tray";
import { Audio } from "./Audio";
import { Displays } from "./Displays";
import { Weather } from "./Weather";
import { Clock } from "./Clock";
import { System } from "./System";

export function Bar(monitor: Gdk.Monitor) {
  const { BOTTOM, TOP, LEFT } = Astal.WindowAnchor;

  return (
    <window
      className="bar"
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | BOTTOM}
    >
      <centerbox vertical={true}>
        <box vertical={true} valign={Gtk.Align.START}>
          <Workspaces />
          <FocusedClient />
        </box>
        <box>
          <Media />
        </box>
        <box vertical={true} valign={Gtk.Align.END}>
          <Tray />
          <Audio />
          <Displays/>
          <Weather />
          <Clock />
          <System />
        </box>
      </centerbox>
    </window>
  );
}
