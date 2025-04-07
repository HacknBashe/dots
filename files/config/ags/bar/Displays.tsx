import { execAsync, timeout, Variable } from "astal";

import {
  MONITOR_1_COMMAND,
  MONITOR_2_COMMAND,
  MONITOR_3_COMMAND,
} from "/etc/nix/vars";

async function getMonitorStatus(): Promise<Record<string, boolean>> {
  const output = await execAsync(["hyprctl", "monitors", "all"]);
  const monitors: Record<string, boolean> = {};
  const monitorBlocks = output.split("\n\n");

  monitorBlocks.forEach((block) => {
    const nameMatch = block.match(/Monitor (\S+)/);
    const disabledMatch = block.match(/disabled: (\S+)/);

    if (nameMatch && disabledMatch) {
      const monitorName = nameMatch[1];
      const disabledStatus = disabledMatch[1].toLowerCase() === "true";
      monitors[monitorName] = !disabledStatus;
    }
  });

  return monitors;
}

const monitors: Variable<Record<string, boolean>> = Variable(
  await getMonitorStatus(),
);

async function toggleMonitor(monitor: string, enableCommand: string) {
  const initialMonitorStatus = await getMonitorStatus();

  if (initialMonitorStatus[monitor]) {
    if (
      Object.values(initialMonitorStatus).filter((status) => status).length > 1
    ) {
      execAsync(["hyprctl", "keyword", "monitor", monitor + ",disabled"]).then(
        async () => {
          const finalMonitorStatus = await getMonitorStatus();
          monitors.set(finalMonitorStatus);
        },
      );
    }
  } else {
    execAsync(["hyprctl", "keyword", "monitor", enableCommand]).then(
      async () => {
        const finalMonitorStatus = await getMonitorStatus();
        monitors.set(finalMonitorStatus);
      },
    );
  }
}

const MONITOR_1 = MONITOR_1_COMMAND.split(",")[0];
const MONITOR_2 = MONITOR_2_COMMAND.split(",")[0];
const TV = MONITOR_3_COMMAND.split(",")[0];

export function Displays() {
  return (
    <box className="displays">
      <button
        label={monitors((val) => (val[MONITOR_1] ? "󰎤" : "󰎦"))}
        onClick={() => {
          toggleMonitor(MONITOR_1, MONITOR_1_COMMAND);
        }}
      ></button>
      <button
        label={monitors((val) => (val[MONITOR_2] ? "󰎧" : "󰎩"))}
        onClick={() => {
          toggleMonitor(MONITOR_2, MONITOR_2_COMMAND);
        }}
      />
      <button
        label={monitors((val) => (val[TV] ? "󰎪" : "󰎬"))}
        onClick={() => {
          toggleMonitor(TV, MONITOR_3_COMMAND);
        }}
      ></button>
    </box>
  );
}
