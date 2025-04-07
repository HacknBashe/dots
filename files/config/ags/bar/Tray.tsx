import { bind } from "astal";

import AstalTray from "gi://AstalTray";

function TrayButton({ item }: { item: AstalTray.TrayItem }) {
  return (
    <menubutton
      tooltipMarkup={bind(item, "tooltipMarkup")}
      usePopover={false}
      actionGroup={bind(item, "actionGroup").as((ag) => ["dbusmenu", ag])}
      menuModel={bind(item, "menuModel")}
    >
      <icon gicon={bind(item, "gicon")} />
    </menubutton>
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
