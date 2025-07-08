import { bind } from "astal";

import Hyprland from "gi://AstalHyprland";

const workspaceIconMap: { [key: string]: string } = {
  "1": "󱈹",
  "2": "󰚩",
  "3": "",
  "4": "",
  "5": "󰦬",
  "6": "󱁤",
  "7": "",
  "8": "󰪶",
  "9": "",
  "10": "󰙯",
  "11": "󰟴",
  "special:notes": "󰠮",
  "special:player": "󰓇",
  "special:moviescreen": "󰨜",
};

function WorkspaceButton({
  ws,
  hypr,
}: {
  ws: Hyprland.Workspace;
  hypr: Hyprland.Hyprland;
}) {
  return (
    <button
      className={bind(hypr, "focusedWorkspace").as((fw) =>
        ws === fw ? "focused" : "",
      )}
      onClicked={() => ws.focus()}
    >
      <label label={`${workspaceIconMap[ws.name]}`} />
    </button>
  );
}

export function Workspaces() {
  const hypr = Hyprland.get_default();

  return (
    <>
      {bind(hypr, "workspaces").as((wss) => {
        const sorted = wss
          .sort((a, b) => a.id - b.id)
          .reduce(
            (
              acc: {
                left: Hyprland.Workspace[];
                right: Hyprland.Workspace[];
                special: Hyprland.Workspace[];
              },
              current,
            ) => {
              if (current.id < 0) {
                acc.special.push(current);
              } else if (current.monitor?.name == "DP-3")
                acc.left.push(current);
              else if (current.monitor?.name == "DP-4") acc.right.push(current);
              else acc.special.push(current);
              return acc;
            },
            { left: [], right: [], special: [] },
          );

        return (
          <box className="workspaces" vertical={true}>
            <box>
              <box vertical={true} hexpand>
                {sorted.left.map((ws) => (
                  <WorkspaceButton ws={ws} hypr={hypr} />
                ))}
              </box>
              <box vertical={true} hexpand>
                {sorted.right.map((ws) => (
                  <WorkspaceButton ws={ws} hypr={hypr} />
                ))}
              </box>
            </box>
            <box vertical={true}>
              {sorted.special.map((ws) => (
                <WorkspaceButton ws={ws} hypr={hypr} />
              ))}
            </box>
          </box>
        );
      })}
    </>
  );
}

export function FocusedClient() {
  const hypr = Hyprland.get_default();
  const focused = bind(hypr, "focusedClient");

  return (
    <box className="focused" visible={focused.as(Boolean)}>
      {focused.as(
        (client) =>
          client && (
            <label
              label={bind(client, "title").as(String)}
              wrap={true}
              truncate={true}
            />
          ),
      )}
    </box>
  );
}
