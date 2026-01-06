export const IndicatorPlugin = async ({ directory, worktree, client, $ }) => {
  // Only run in TUI mode, not CLI mode
  if (process.argv.includes('run')) {
    return {
      event: async () => {}
    };
  }

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

  // Play a beep sound when agent finishes
  // NOTE: This uses direct audio playback commands because Ghostty's native bell audio
  // support (via '\a' character) is not yet available on macOS and requires a newer
  // version on Linux (see https://github.com/ghostty-org/ghostty/discussions/2710).
  // Once native bell support is available on both platforms, this can be simplified to:
  //   await $`/bin/sh -lc 'printf "\\a" > /dev/tty'`;
  // And the Ghostty config can be updated with:
  //   bell-features = audio,attention,title
  //   bell-audio-path = sounds/beep.wav
  //   bell-audio-volume = 0.5
  const playBeep = async () => {
    try {
      const os = process.platform;
      const soundPath = `${process.env.HOME}/.config/dots/files/config/ghostty/sounds/beep.wav`;
      
      if (os === 'darwin') {
        // macOS - use afplay (built-in)
        await $`afplay ${soundPath}`;
      } else if (os === 'linux') {
        // Linux - try pw-play first, fall back to aplay
        try {
          await $`pw-play ${soundPath}`;
        } catch (e) {
          try {
            await $`aplay ${soundPath}`;
          } catch (e2) {
            // If both fail, just do the terminal bell (no sound, but shows 🔔)
            await $`/bin/sh -lc 'printf "\\a" > /dev/tty'`;
          }
        }
      }
    } catch (e) {
      // Silently fail if sound can't be played
    }
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.updated") {
        await setTitle("Agent: working");
      }
      if (event.type === "permission.asked") {
        await setTitle("Agent: waiting");
        await playBeep();
      }
      if (event.type === "session.idle") {
        await setTitle("Agent: idle");
        await playBeep();
      }
    },
  };
};
