# Dotfiles

Personal configs for a Fedora Atomic laptop running sway, with fish as the
login shell and helix (`hx`) as the editor. Published at
github.com/mvdan/dotfiles.

## Layout and deployment

The repo root mirrors `$HOME`. Whole directories are symlinked into place:
`~/.config`, `~/.bin` and `~/.ssh` point at the same paths here, and single
files like `~/.bashrc` are symlinked individually. Editing a file here is
editing the live config, so changes take effect immediately and can be
verified against the running system.

- `.bin/` — small bash scripts, mostly git and Go workflow helpers.
  `versioned-cue` is invoked through `cue-vX.Y.Z` symlinks, which are
  created as needed and ignored.
- `.config/` — per-tool configs. Sway lives in `sway/config.d/`; the main
  sway config is the distro one. systemd `*.wants/` entries are tracked
  symlinks to `/usr/lib/systemd/user/`.
- `.config/environment.d/` — session environment, including `PATH`,
  `EDITOR` and `SSH_AUTH_SOCK`, which relies on `ssh-agent.socket` being
  enabled.
- `.config/fish/config.fish` — abbreviations and functions. Abbreviations
  do not expand recursively, so never define one in terms of another.
- `.config/git/config` and `.config/git/ignore` — global git settings; the
  ignore file applies to every repo, so keep it narrow.

## .gitignore

The ignore file is a whitelist: everything is ignored, then dotfiles are
re-included, then `/.config/*` is ignored again and each tracked tool dir
is re-included with `!/.config/<tool>/`. Directories ending in `.d/` are
ignored too and need their own negation. When adding a config for a new
tool, add its whitelist line, otherwise new files there are silently
hidden. Keys, caches, state files and databases stay untracked.

## Verifying changes

There are no tests. Check syntax with the real tools:

```
fish -n .config/fish/config.fish
bash -n .bin/<script>
foot --check-config --config=$PWD/.config/foot/foot.ini
ssh -G -F .ssh/config <host>
git config --global --list
swaymsg -t get_tree | jq -r '.. | .app_id? // empty' | sort -u
```

Use `command -v`, `flatpak list --app` and the desktop files under
`/var/lib/flatpak/exports/share/applications` to confirm that binaries,
app IDs and `.desktop` names referenced in configs actually exist. Flatpak
app IDs are case-sensitive.

## Commits

Historically changes were batched into periodic "updates" commits. Prefer
one commit per tool or concern, with a short subject prefixed by the area
(`fish:`, `sway:`, `bin:`) and a body only when the why is not obvious.
Never push without being asked.
