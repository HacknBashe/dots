import { execSync } from 'child_process';

export const IndicatorPlugin = async ({ directory, worktree, client, $ }) => {
  // Only run if inside tmux (where we can set pane status)
  if (!process.env.TMUX) {
    return { event: async () => {} };
  }

  let paneId;

  try {
    // Find the pane where opencode is actually running by looking at process tree
    const ppid = process.ppid;

    // Get the TTY of the parent opencode process (using execSync to suppress output)
    const tty = execSync(`ps -p ${ppid} -o tty=`, {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();

    if (tty && tty !== "??") {
      // Find the tmux pane with matching TTY (use $ anchor to avoid pts/1 matching pts/11)
      const paneOutput = execSync(
        `tmux list-panes -a -F "#{pane_id} #{pane_tty}" | grep " /dev/${tty}$"`,
        {
          encoding: 'utf8',
          stdio: ['pipe', 'pipe', 'pipe']
        }
      );
      paneId = paneOutput.trim().split(" ")[0];
    }
  } catch (e) {
    paneId = undefined;
  }

  // Set @pane_status tmux option (can't be overwritten by applications)
  const setStatus = async (status) => {
    if (!paneId) return;
    try {
      await $`tmux set-option -p -t ${paneId} @pane_status ${status}`;
    } catch (e) {}
  };

  let isIdle = true; // Start idle until first real work

  return {
    event: async ({ event }) => {
      if (event.type === "session.updated") {
        // Only set working if we're not idle (session.updated fires after session.idle)
        if (!isIdle) {
          await setStatus("working");
        }
      }
      if (event.type === "permission.asked") {
        isIdle = false;
        await setStatus("waiting");
      }
      if (event.type === "session.idle") {
        isIdle = true;
        await setStatus("idle");
      }
      // session.status with running=true indicates actual work starting
      if (event.type === "session.status") {
        isIdle = false;
        await setStatus("working");
      }
    },
  };
};
