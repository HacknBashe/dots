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
  7: " 7",
  8: "󰽉",
  9: "󰒱",
  10: "󰙯",
  11: "󰟴",
  "special:notes": "󰠮",
  "special:player": "",
  "special:moviescreen": "󰨜",
};

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");

  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws
      .sort((a, b) => a.id - b.id)
      .map(({ id, name }) =>
        Widget.Button({
          on_clicked: () =>
            hyprland.messageAsync(
              id > 0
                ? `dispatch workspace ${id}`
                : `dispatch togglespecialworkspace ${name.slice(8)}`,
            ),
          child: Widget.Label(`${workspaceIconMap[name] || id}`),
          class_name: activeId.as((i) => `${i === id ? "focused" : ""}`),
        }),
      ),
  );

  return Widget.Box({
    class_name: "workspaces",
    vertical: true,
    halign: 3,
    children: workspaces,
  });
}

function ClientTitle() {
  return Widget.Label({
    class_name: "client-title",
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
  const items = systemtray.bind("items").as((items) =>
    items.map((item) =>
      Widget.Button({
        child: Widget.Icon({ icon: item.bind("icon") }),
        on_primary_click: (_, event) => item.activate(event),
        on_secondary_click: (_, event) => item.openMenu(event),
        tooltip_markup: item.bind("tooltip_markup"),
      }),
    ),
  );

  return Widget.Box({
    children: items,
    vertical: true,
  });
}

const playerClientMap = {
  spotify: " ",
  brave: "󰖟 ",
};

const playerStatusMap = {
  Playing: "  ",
  Paused: "  ",
  Stopped: "  ",
};

function Media() {
  const label = Utils.watch("", mpris, "player-changed", () => {
    if (mpris.players[0]) {
      const { name, play_back_status, track_artists, track_title } =
        mpris.players[0];
      return `${playerClientMap[name] || ""}${playerStatusMap[play_back_status]}${track_artists.join(", ")} - ${track_title}`;
    } else {
      return "Nothing is playing";
    }
  });

  return Widget.Button({
    class_name: "media",
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
    class_name: "volume",
    css: "min-height: 180px",
    vertical: true,

    children: [
      Widget.Slider({
        orientation: 1,
        inverted: true,
        draw_value: false,
        vexpand: true,
        on_change: ({ value }) => (audio.speaker.volume = value),
        setup: (self) =>
          self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0;
          }),
      }),
      Widget.Button({
        onClicked: () => {
          Utils.execAsync(["alacritty", "--command", "pulsemixer"])
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
              Utils.exec(
                `hyprctl notify -1 3000 "rgb(ff1ea3)" "󰋋  Headset set as default output device."`,
              );
            } else {
              Utils.exec(`wpctl set-default ${map && map["Soundbar"]}`);
              Utils.exec(
                `hyprctl notify -1 3000 "rgb(ff1ea3)" "󰓃  Soundbar set as default output device."`,
              );
            }
          });
        },
        onSecondaryClick: () => {
          Utils.execAsync(["pulsemixer", "--toggle-mute"])
            .then((out) => print(out))
            .catch((err) => print(err));
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
  poll: [1000, 'date "+%I:%M:%S %p %a %b %e"'],
});

function Clock() {
  return Widget.Box({
    class_name: "clock",
    vertical: true,
    tooltip_text: date.bind(),
    children: date.bind().as((d) =>
      d.split(/[:\s]/).map((s, i) =>
        Widget.Label({
          class_name: "clock-line clock-line-" + i,
          label: s,
        }),
      ),
    ),
  });
}

const WINDOW_NAME = "system-popup";
function System() {
  return Widget.Button({
    class_name: "system",
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
    children: [SysTray(), Media(), Volume(), Weather(), Clock(), System()],
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
