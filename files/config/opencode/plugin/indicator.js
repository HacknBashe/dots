import { execSync } from 'child_process';

export const IndicatorPlugin = async ({ directory, worktree, client, $ }) => {
  const os = process.platform;
  const inTmux = !!process.env.TMUX;
  const soundDir = `${process.env.HOME}/.config/dots/files/config/ghostty/sounds`;

  // Check if command exists (silent check)
  const commandExists = async (cmd) => {
    try {
      await $`command -v ${cmd}`.quiet();
      return true;
    } catch (e) {
      return false;
    }
  };

  // --- Audio setup ---
  let audioPlayer = null;

  if (os === 'darwin') {
    if (await commandExists('afplay')) audioPlayer = 'afplay';
  } else if (os === 'linux') {
    if (await commandExists('pw-play')) audioPlayer = 'pw-play';
    else if (await commandExists('aplay')) audioPlayer = 'aplay';
  }

  const playSound = async (file) => {
    if (!audioPlayer) return;
    const path = `${soundDir}/${file}`;
    try {
      if (audioPlayer === 'afplay') await $`afplay ${path}`;
      else if (audioPlayer === 'pw-play') await $`pw-play ${path}`;
      else if (audioPlayer === 'aplay') await $`aplay ${path}`;
    } catch (e) {}
  };

  // --- Notification setup ---
  let notifier = null;

  if (os === 'darwin') {
    notifier = 'osascript';
  } else if (os === 'linux') {
    if (await commandExists('notify-send')) notifier = 'notify-send';
  }

  // --- Tmux setup ---
  let paneId;
  let sessionName = '';

  if (inTmux) {
    try {
      const ppid = process.ppid;
      const tty = execSync(`ps -p ${ppid} -o tty=`, {
        encoding: 'utf8',
        stdio: ['pipe', 'pipe', 'pipe']
      }).trim();

      if (tty && tty !== "??") {
        const paneOutput = execSync(
          `tmux list-panes -a -F "#{pane_id} #{pane_tty}" | grep " /dev/${tty}$"`,
          { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }
        );
        paneId = paneOutput.trim().split(" ")[0];
      }

      if (paneId) {
        sessionName = execSync(
          `tmux display-message -p -t ${paneId} '#{session_name}'`,
          { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }
        ).trim();
      }
    } catch (e) {
      paneId = undefined;
    }
  }

  // Check if the tmux window is currently visible to the user
  const isWindowVisible = () => {
    if (!inTmux) return true;
    try {
      const result = execSync(
        "tmux display-message -p '#{window_active}#{session_attached}'",
        { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }
      ).trim();
      return result === '11';
    } catch (e) {
      return true; // If check fails, assume visible (don't spam notifications)
    }
  };

  // Set @pane_status tmux option
  const setStatus = async (status) => {
    if (!paneId) return;
    try {
      await $`tmux set-option -p -t ${paneId} @pane_status ${status}`;
    } catch (e) {}
  };

  // Send a desktop notification (only when tmux window is not visible)
  const notify = async (body) => {
    if (!notifier || isWindowVisible()) return;
    const title = sessionName ? `OpenCode (${sessionName})` : 'OpenCode';
    try {
      if (notifier === 'osascript') {
        await $`osascript -e ${'display notification "' + body + '" with title "' + title + '"'}`;
      } else if (notifier === 'notify-send') {
        await $`notify-send ${title} ${body}`;
      }
    } catch (e) {}
  };

  let isIdle = true;

  return {
    event: async ({ event }) => {
      // Agent is working
      if (event.type === "session.updated") {
        if (!isIdle) await setStatus("working");
      }
      if (event.type === "session.status") {
        isIdle = false;
        await setStatus("working");
      }
      if (event.type === "permission.replied" || event.type === "question.replied") {
        await setStatus("working");
      }

      // Agent needs input
      if (event.type === "permission.asked" || event.type === "question.asked") {
        isIdle = false;
        await setStatus("waiting");
        await playSound("question.wav");
        await notify("Waiting for input");
      }

      // Agent finished
      if (event.type === "session.idle") {
        isIdle = true;
        await setStatus("idle");
        try {
          execSync('tmux_mark_idle_seen', { stdio: ['pipe', 'pipe', 'pipe'] });
        } catch (e) {}
        await playSound("complete.wav");
        await notify("Task complete");
      }
    },
  };
};
