import { Variable, GLib, bind } from "astal";

export function Clock({ format = "%I:%M:%S~%p~%a~%b~%e" }) {
  const time = Variable<string>("").poll(
    1000,
    () => GLib.DateTime.new_now_local().format(format)!,
  );
  return (
    <box className="clock" vertical={true}>
      {bind(time).as((d) =>
        d
          .split(/[:~]/)
          .map((s, i) => (
            <label
              className={"clock-line clock-line-" + i}
              label={s.replace(" ", "")}
            />
          )),
      )}
    </box>
  );
}
