import Wp from "gi://AstalWp";

import { bind, execAsync } from "astal";

function setDefaultDevice(device: string) {
  execAsync(["wpctl", "status"]).then((out) => {
    const map = out
      .match(/(\d+)\.\s+(Soundbar|Headset|TV)/g)
      ?.reduce((acc: { [key: string]: string }, curr) => {
        const [id, name] = curr.split(/\.\s+/);
        acc[name] = id;
        return acc;
      }, {});
    execAsync(`wpctl set-default ${map && map[device]}`);
  });
}

export function Audio() {
  const speaker = Wp.get_default()?.audio.defaultSpeaker!;

  return (
    <box className="volume" vertical={true}>
      <eventbox onScroll={() => {}}>
        <button
          onClick={(_, e) => {
            switch (e.button) {
              case 1:
                execAsync(["ghostty", "-e", "pulsemixer"])
                  .then((out) => console.log(out))
                  .catch((err) => console.error(err));
                break;
              case 3:
                execAsync(["pulsemixer", "--toggle-mute"])
                  .then((out) => console.log(out))
                  .catch((err) => console.error(err));
                break;
            }
          }}
          onScroll={(_, e) => {
            if (e.delta_y < 0) {
              execAsync(["pulsemixer", "--change-volume", "+5"]);
            } else {
              execAsync(["pulsemixer", "--change-volume", "-5"]);
            }
          }}
          label={bind(speaker, "volume").as(
            (volume) => `${Math.floor(volume * 100)}%`,
          )}
        />
      </eventbox>
      <box>
        <button
          onClick={() => {
            setDefaultDevice("Soundbar");
          }}
          label={bind(speaker, "description").as((desc) => {
            return desc === "Soundbar" ? "󰓃" : "󰓄";
          })}
        />
        <button
          onClick={() => {
            setDefaultDevice("Headset");
          }}
          label={bind(speaker, "description").as((desc) => {
            return desc === "Headset" ? "󰋋" : "󰟎";
          })}
        />
        <button
          onClick={() => {
            setDefaultDevice("TV");
          }}
          label={bind(speaker, "description").as((desc) => {
            return desc === "TV" ? "󰄘" : "󰞊";
          })}
        />
      </box>
    </box>
  );
}
