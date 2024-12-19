import { bind } from "astal";
import { Gdk } from "astal/gtk3";

import AstalTray from "gi://AstalTray";

function TrayButton({ item }: { item: AstalTray.TrayItem }) {
  const menu = item.create_menu();

  return (
    <button
      tooltipMarkup={bind(item, "tooltipMarkup")}
      onDestroy={() => menu?.destroy()}
      onClickRelease={(self) => {
        menu?.popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null);
      }}
    >
      <icon gIcon={bind(item, "gicon")} />
    </button>
  );
}

export function Tray() {
  const tray = AstalTray.get_default();

  return (
    <>
      {bind(tray, "items").as((items) => {
        const columns = items.reduce(
          (
            acc: {
              left: AstalTray.TrayItem[];
              middle: AstalTray.TrayItem[];
              right: AstalTray.TrayItem[];
            },
            current,
            id,
          ) => {
            if (id % 3 === 0) {
              acc.left.push(current);
            } else if (id % 3 === 1) {
              acc.middle.push(current);
            } else {
              acc.right.push(current);
            }
            return acc;
          },
          { left: [], middle: [], right: [] },
        );

        return (
          <box className="tray">
            <box vertical={true} hexpand>
              {columns.left.map((item) => (
                <TrayButton item={item} />
              ))}
            </box>
            <box vertical={true} hexpand>
              {columns.middle.map((item) => (
                <TrayButton item={item} />
              ))}
            </box>
            <box vertical={true} hexpand>
              {columns.right.map((item) => (
                <TrayButton item={item} />
              ))}
            </box>
          </box>
        );
      })}
    </>
  );
}
