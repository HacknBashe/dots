export const IndicatorPlugin = async ({ app, client, $ }) => {
  let paneId;

  try {
    // Find the pane where opencode is actually running by looking at process tree
    const ppid = process.ppid;

    // Get the TTY of the parent opencode process
    const ttyResult = await $`ps -p ${ppid} -o tty=`;
    const ttyOutput =
      ttyResult.stdout || ttyResult.stdOut || ttyResult.toString() || "";
    const tty = (
      typeof ttyOutput === "string" ? ttyOutput : String(ttyOutput)
    ).trim();

    if (tty && tty !== "??") {
      // Find the tmux pane with matching TTY
      const paneResult =
        await $`tmux list-panes -a -F "#{pane_id} #{pane_tty}" | grep "/dev/${tty}"`;
      const paneOutput =
        paneResult.stdout || paneResult.stdOut || paneResult.toString() || "";
      const paneStr =
        typeof paneOutput === "string" ? paneOutput : String(paneOutput);
      paneId = paneStr.trim().split(" ")[0];
    }
  } catch (e) {
    paneId = undefined;
  }

  const setTitle = async (title) => {
    try {
      if (!paneId) {
        return;
      }
      await $`tmux select-pane -t '${paneId}' -T '${title}'`;
    } catch (e) {}
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.updated") {
        await setTitle("agent_pane: working");
      }
      if (event.type === "session.idle") {
        await setTitle("agent_pane: idle");
        await $`/bin/sh -lc 'printf "\\a" > /dev/tty'`;
      }
    },
  };
};
