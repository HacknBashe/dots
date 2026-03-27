# dots

Nix flake managing all machines (NixOS + macOS/nix-darwin). Home directory configs are managed in this repo under `files/` and symlinked into `~` by Nix.

**When editing config files, always edit the source in this repo, never the symlink targets in `~`.** For example:
- `files/config/opencode/AGENTS.md` is the source for `~/.config/opencode/AGENTS.md`
- `files/config/opencode/skills/*/SKILL.md` is the source for `~/.config/opencode/skills/*/SKILL.md`

Do not read or write files under `~/.config/`, `~/.claude/`, or other home directories when the user asks you to edit their config. The files you need are here in this repo under `files/`.
