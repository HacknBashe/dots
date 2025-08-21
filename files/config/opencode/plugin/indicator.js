export const IndicatorPlugin = async ({ app, client, $ }) => {
  let paneId;
  try {
    const res = await $`tmux display-message -p '#{pane_id}'`;
    paneId = (res.stdout || res.stdOut || "").toString().trim();
  } catch {
    paneId = undefined;
  }

  const setTitle = async (title) => {
    try {
      if (!paneId) return;
      await $`tmux select-pane -t ${paneId} -T ${title}`;
    } catch {}
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
