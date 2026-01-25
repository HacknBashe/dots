import { execSync } from 'child_process';

export const BeepPlugin = async ({ directory, worktree, client, $ }) => {
  // Check if command exists (silent check)
  const commandExists = async (cmd) => {
    try {
      await $`command -v ${cmd}`.quiet();
      return true;
    } catch (e) {
      return false;
    }
  };

  // Determine which audio player is available
  let audioPlayer = null;
  const os = process.platform;

  if (os === 'darwin') {
    if (await commandExists('afplay')) {
      audioPlayer = 'afplay';
    }
  } else if (os === 'linux') {
    if (await commandExists('pw-play')) {
      audioPlayer = 'pw-play';
    } else if (await commandExists('aplay')) {
      audioPlayer = 'aplay';
    }
  }

  // If no audio player available, return a no-op plugin (returning null crashes OpenCode)
  if (!audioPlayer) {
    return { event: async () => {} };
  }

  // Play a beep sound
  const playBeep = async () => {
    try {
      const soundPath = `${process.env.HOME}/.config/dots/files/config/ghostty/sounds/beep.wav`;
      
      if (audioPlayer === 'afplay') {
        await $`afplay ${soundPath}`;
      } else if (audioPlayer === 'pw-play') {
        await $`pw-play ${soundPath}`;
      } else if (audioPlayer === 'aplay') {
        await $`aplay ${soundPath}`;
      }
    } catch (e) {
      // Silently fail if sound can't be played
    }
  };

  return {
    event: async ({ event }) => {
      // Play beep when agent needs permission
      if (event.type === "permission.asked") {
        await playBeep();
      }
      // Play beep when agent becomes idle (task complete)
      if (event.type === "session.idle") {
        await playBeep();
      }
    },
  };
};
