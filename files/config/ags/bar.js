import { Weather } from "./weather.js";

const hyprland = await Service.import("hyprland");
const mpris = await Service.import("mpris");
const audio = await Service.import("audio");
const systemtray = await Service.import("systemtray");

const workspaceIconMap = {
  1: "󱈹",
  2: "󰃖",
  3: "",
  4: "",
  5: "󰺵",
  6: "󰖟",
  7: "󰽉",
  8: "󱁤",
  9: "󰒱",
  10: "󰙯",
  11: "󰟴",
  "special:notes": "󰠮",
  "special:player": "󰓇",
  "special:moviescreen": "󰨜",
};

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");

  const workspaces = hyprland.bind("workspaces").as((ws) => {
    const sorted = ws
      .sort((a, b) => a.id - b.id)
      .reduce(
        (acc, current) => {
          if (current.id > 5) acc.left.push(current);
          else if (current.id > 0) acc.right.push(current);
          else acc.special.push(current);
          return acc;
        },
        { left: [], right: [], special: [] },
      );
    return [
      Widget.Box({
        children: [
          Widget.Box({
            className: "left",
            vertical: true,
            children: sorted.left.map((w) =>
              Widget.Button({
                on_clicked: () =>
                  hyprland.messageAsync(
                    w.id > 0
                      ? `dispatch workspace ${w.id}`
                      : `dispatch togglespecialworkspace ${w.name.slice(8)}`,
                  ),
                child: Widget.Label(`${workspaceIconMap[w.name] || w.id}`),
                className: activeId.as((i) => `${i === w.id ? "focused" : ""}`),
              }),
            ),
          }),
          Widget.Box({
            className: "right",
            vertical: true,
            children: sorted.right.map((w) =>
              Widget.Button({
                on_clicked: () =>
                  hyprland.messageAsync(
                    w.id > 0
                      ? `dispatch workspace ${w.id}`
                      : `dispatch togglespecialworkspace ${w.name.slice(8)}`,
                  ),
                child: Widget.Label(`${workspaceIconMap[w.name] || w.id}`),
                className: activeId.as((i) => `${i === w.id ? "focused" : ""}`),
              }),
            ),
          }),
        ],
      }),
      Widget.Box({
        vertical: true,
        children: sorted.special.map((w) =>
          Widget.Button({
            on_clicked: () =>
              hyprland.messageAsync(
                w.id > 0
                  ? `dispatch workspace ${w.id}`
                  : `dispatch togglespecialworkspace ${w.name.slice(8)}`,
              ),
            child: Widget.Label(`${workspaceIconMap[w.name] || w.id}`),
            className: activeId.as((i) => `${i === w.id ? "focused" : ""}`),
          }),
        ),
      }),
    ];
  });

  return Widget.Box({
    className: "workspaces",
    vertical: true,
    halign: 3,
    children: workspaces,
  });
}

function ClientTitle() {
  return Widget.Label({
    className: "client-title",
    label: hyprland.active.client.bind("title"),
    justify: 2,
    wrap: true,
    wrapMode: 2,
  });
}

function Top() {
  return Widget.Box({
    vertical: true,
    spacing: 8,
    children: [Workspaces(), ClientTitle()],
  });
}

function Center() {
  return Widget.Box({
    vertical: true,
    vpack: "center",
    spacing: 8,
    children: [],
  });
}

function SysTray() {
  return Widget.Box({
    children: Array.from({ length: 2 }, (_, colIndex) =>
      Widget.Box({
        children: systemtray.bind("items").as((items) =>
          items
            .filter((_, index) => index % 2 === colIndex)
            .map((item) =>
              Widget.Button({
                child: Widget.Icon({ icon: item.bind("icon") }),
                on_primary_click: (_, event) => item.activate(event),
                on_secondary_click: (_, event) => item.openMenu(event),
                tooltip_markup: item.bind("tooltip_markup"),
              }),
            ),
        ),
        vertical: true,
      }),
    ),
    halign: 3,
    vertical: false,
  });
}

function TV() {
  let icon = Variable("󰠺");
  return Widget.Button({
    className: "tv",
    on_primary_click: () => {
      Utils.execAsync(["hyprctl", "monitors"])
        .then((out) => {
          if (out.includes("LG TV")) {
            Utils.execAsync([
              "hyprctl",
              "keyword monitor HDMI-A-1,disabled",
            ]).then((_) => {
              icon.setValue("󰠺");
              Utils.notify({
                id: 888,
                summary: "TV off",
                iconName: "preferences-desktop-screensaver-symbolic",
                timeout: 2000,
              });
            });
          } else {
            Utils.execAsync([
              "hyprctl",
              "keyword monitor HDMI-A-1,3840x2160,5360x0,1",
            ]).then((_) => {
              icon.setValue("󰟴");
              Utils.notify({
                id: 888,
                summary: "TV on",
                iconName: "preferences-desktop-remote-desktop-symbolic",
                timeout: 2000,
              });
            });
          }
        })
        .catch((err) => print(err));
    },
    child: Widget.Label({ label: icon.bind(), justify: 2 }),
  });
}

const mediaIconMap = {
  spotify: " ",
  brave: "󰖟 ",
  Playing: "  ",
  Paused: "  ",
  Stopped: "  ",
};

function Media() {
  const label = Utils.watch("", mpris, "player-changed", () => {
    if (mpris.players[0]) {
      const { name, play_back_status, track_artists, track_title } =
        mpris.players[0];
      return `${mediaIconMap[name] || ""}${mediaIconMap[play_back_status]}${track_artists.join(", ")} - ${track_title}`;
    } else {
      return "Nothing is playing";
    }
  });

  return Widget.Button({
    className: "media",
    on_primary_click: () => mpris.getPlayer("")?.playPause(),
    on_scroll_up: () => mpris.getPlayer("")?.next(),
    on_scroll_down: () => mpris.getPlayer("")?.previous(),
    child: Widget.Label({ label, justify: 2, wrap: true, wrapMode: 2 }),
  });
}

function Volume() {
  function getVolume() {
    return `${
      audio.speaker.name ===
      "alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo"
        ? audio.speaker.is_muted
          ? "󰓄"
          : "󰓃"
        : audio.speaker.name ===
            "alsa_output.usb-Macronix_Razer_Barracuda_Pro_2.4_1234-00.analog-stereo"
          ? audio.speaker.is_muted
            ? "󰟎"
            : "󰋋"
          : // "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1"
            "󰝟"
    }\n${Math.floor(audio.speaker.volume * 100)}%`;
  }

  return Widget.Box({
    className: "volume",
    vertical: true,

    children: [
      Widget.Button({
        onClicked: () => {
          Utils.execAsync(["ghostty", "-e", "pulsemixer"])
            .then((out) => print(out))
            .catch((err) => print(err));
        },
        onSecondaryClick: () => {
          Utils.execAsync(["pulsemixer", "--toggle-mute"])
            .then((out) => print(out))
            .catch((err) => print(err));
        },
        on_scroll_up: () => {
          Utils.execAsync(["pulsemixer", "--change-volume", "+5"])
            .then((out) => print(out))
            .catch((err) => print(err));
        },
        on_scroll_down: () => {
          Utils.execAsync(["pulsemixer", "--change-volume", "-5"])
            .then((out) => print(out))
            .catch((err) => print(err));
        },
        onMiddleClick: () => {
          Utils.execAsync(["wpctl", "status"]).then((out) => {
            const map = out
              .match(/(\d+)\.\s+(Soundbar|Headset)/g)
              ?.reduce((acc, curr) => {
                const [id, name] = curr.split(/\.\s+/);
                acc[name] = id;
                return acc;
              }, {});
            if (
              audio.speaker.name ===
              "alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo"
            ) {
              Utils.exec(`wpctl set-default ${map && map["Headset"]}`);
              Utils.notify({
                id: 888,
                summary: "Headset set as output",
                iconName: "audio-headphones-symbolic",
                timeout: 2000,
              });
            } else {
              Utils.exec(`wpctl set-default ${map && map["Soundbar"]}`);
              Utils.notify({
                id: 888,
                summary: "Soundbar set as output",
                iconName: "audio-speakers-symbolic",
                timeout: 2000,
              });
            }
          });
        },
        child: Widget.Label({
          justify: 2,
          label: Utils.watch(getVolume(), audio.speaker, getVolume),
        }),
      }),
    ],
  });
}

const date = Variable("", {
  poll: [1000, 'date "+%I:%M:%S~%p~%a~%b~%e"'],
});

function Clock() {
  return Widget.Box({
    className: "clock",
    vertical: true,
    tooltipText: date.bind().as((d) => d.replace(" ", "").replace(/~/g, " ")),
    children: date.bind().as((d) =>
      d.split(/[:~]/).map((s, i) =>
        Widget.Label({
          className: "clock-line clock-line-" + i,
          label: s.replace(" ", ""),
        }),
      ),
    ),
  });
}

const WINDOW_NAME = "system-popup";
function System() {
  return Widget.Button({
    className: "system",
    label: "󱄅",
    onClicked: () => {
      App.toggleWindow(WINDOW_NAME);
    },
  });
}

export function SystemPopup(monitor = 0) {
  return Widget.Window({
    name: WINDOW_NAME,
    monitor,
    className: "system-popup",
    setup: (self) =>
      self.keybind("Escape", () => {
        App.closeWindow(WINDOW_NAME);
      }),
    visible: false,
    anchor: ["bottom", "left"],
    keymode: "exclusive",
    child: Widget.Box({
      children: [
        Widget.Button({
          label: "󰌾",
          onClicked: () => {
            App.toggleWindow(WINDOW_NAME);
            Utils.execAsync([
              "bash",
              "-c",
              "grim -o DP-4 -l 0 /tmp/hyprlock_screenshot1.png & grim -o DP-3 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock",
            ]);
          },
        }),
        Widget.Button({
          label: "󰍃",
          onClicked: () => {
            App.toggleWindow(WINDOW_NAME);

            Utils.execAsync(["wayland-logout"]);
          },
        }),
        Widget.Button({
          label: "󰤄",
          onClicked: () => {
            App.toggleWindow(WINDOW_NAME);

            Utils.execAsync([
              "bash",
              "-c",
              "grim -o DP-4 -l 0 /tmp/hyprlock_screenshot1.png & grim -o DP-3 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock & sleep 1 && systemctl suspend",
            ]);
          },
        }),
        Widget.Button({
          label: "󰒲",
          onClicked: () => {
            App.toggleWindow(WINDOW_NAME);
            Utils.execAsync([
              "bash",
              "-c",
              "grim -o DP-4 -l 0 /tmp/hyprlock_screenshot1.png & grim -o DP-3 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock & sleep 1 && systemctl hibernate",
            ]);
          },
        }),
        Widget.Button({
          label: "󰜉",
          onClicked: () => {
            App.toggleWindow(WINDOW_NAME);
            Utils.execAsync(["systemctl", "reboot"]);
          },
        }),
        Widget.Button({
          label: "󰐥",
          onClicked: () => {
            App.toggleWindow(WINDOW_NAME);
            Utils.execAsync(["systemctl", "poweroff"]);
          },
        }),
      ],
    }),
  });
}

function Bottom() {
  return Widget.Box({
    vertical: true,
    vpack: "end",
    spacing: 8,
    children: [
      SysTray(),
      TV(),
      Media(),
      Volume(),
      Weather(),
      Clock(),
      System(),
    ],
  });
}

export function Bar(monitor = 0) {
  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    monitor,
    anchor: ["top", "bottom", "left"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      vertical: true,
      start_widget: Top(),
      center_widget: Center(),
      end_widget: Bottom(),
    }),
  });
}
