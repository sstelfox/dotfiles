# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles for Sam Stelfox. Targets multiple environments (macOS, Fedora/Arch/Debian/Ubuntu/Alpine Linux, Termux on Android) from a single tree. Configs are deployed by symlinking into `$HOME` rather than copying — edits to files here take effect immediately on the system that ran `install`.

## Installation entrypoints

- `./install` — primary installer. Detects current shell + OS and only links what is relevant. Idempotent: re-run after pulling changes or switching shells.
- `./legacy-install` — older installer; still used for some `~/.config/*` symlinks (condarc, aichat, ra-multiplex, systemd, starship.toml, gemrc, gnupg, pryrb, sqliterc, ssh, toprc). Do not delete; some configs only flow through this path.
- `./system_setup.sh` — interactive Fedora-only system bootstrapper that runs scripts under `system-setup-scripts/{fedora,arch_linux,generic}/`. Refuses to run on non-Fedora and as root.

## Shell library architecture

The shell library is the heart of this repo. Two patterns coexist — understand both before editing:

1. **Shim pattern (interactive shells):** `lib/shim.sh.inc` defines `_plc <func> [args...]` (POSIX Lib Call). Interactive shells source only the shim; each `_plc` invocation forks a subshell that sources the full library, runs the function, and exits. This keeps shell startup fast and avoids polluting the user's environment with library internals. Use `_plc detect_os`, `_plc posix_which foo`, etc.
2. **Direct sourcing (scripts):** Scripts that need many library calls set `__DOTFILE_ROOT` and source `lib/posix.sh.inc` directly, then call functions normally. `posix.sh.inc` is the single entrypoint that loads every `lib/**/*.sh.inc` module in dependency order — add new modules to its source list.

Library layout:
- `lib/environment/` — detection (`detect_os`, `detect_os_family`, `detect_shell`), git info, network, fonts, access checks
- `lib/filesystem/` — `safe_symlink`, `safe_symlink_when_available`, `posix_which`, `trim_dir`, `trim_whitespace`
- `lib/pkg/` — package manager abstractions
- `lib/security/` — multifactor helpers
- `lib/services/` — k8s, ssh, ssh_agent helpers (incl. `rebuild_ssh_config`)
- `lib/logging.sh.inc` — `info`/`warn`/`err`/`fatal` emit JSON via `jq` (requires jq installed; fatal exits 230)
- `lib/trace.sh.inc` — call-stack tracing for log entries

`#!/usr/bin/env false` is the shebang on every `.sh.inc` file. It is intentional — these files must be sourced, not executed; running one directly fails loudly.

## Shell config layering

`configs/shell/` is layered in a strict order — preserve it when adding things:

1. `common.sh.inc` — shared across all POSIX shells (path setup, editor, git aliases, telemetry opt-out, password-store, SSH agent)
2. `{bash,zsh}/*.sh.inc` — shell-specific (prompt, history) — sourced *after* common so they can override
3. `operating_systems/*.sh.inc` — OS-conditional (e.g. macOS-only Docker Desktop, Nix)
4. `environments/*.sh.inc` — work/project specific (e.g. `tulip_development.sh.inc` — only loads on macOS as a Tulip-environment heuristic)

`zshrc` and `bashrc` set `__DOTFILE_ROOT` and `__SHELL_CFG_ROOT` then source the layers. Don't add logic to those entrypoints — put it in a `.sh.inc` and source it.

## Symlink contract

`safe_symlink` and `safe_symlink_when_available` are how every config reaches `$HOME`:
- They replace existing symlinks freely but refuse to overwrite real files/dirs (returns exit 2).
- `safe_symlink_when_available <bin> <src> <dst>` only links if `<bin>` is on `$PATH` — used to avoid pulling in configs for tools that aren't installed (e.g. nvim, alacritty).

## Git config

- `configs/git/default` is the global gitconfig (linked to `~/.gitconfig`). It uses `[includeIf]` to layer `tulip.inc` for Tulip repos (matched by path *or* remote URL).
- `configs/git/global-hooks/` is the global hooks dir — repo-local hooks should pass through to it.
- `configs/git/global-gitignore` is the global excludes file.

## SSH config generation

`configs/ssh/config` is generated, not hand-written, and is gitignored. Rebuild via `_plc rebuild_ssh_config` after editing `configs/ssh/{base.cfg.inc,common/,system/}`. The generator only runs when `whoami == sstelfox` to protect downstream users.

## Claude Code config

`configs/claude/` holds the tracked pieces of `~/.claude/`. Each top-level entry is symlinked **individually** by `install` (gated on `claude` being on `$PATH`) so Claude Code's runtime state — `sessions/`, `history.jsonl`, `cache/`, `plans/`, `projects/`, `plugins/known_marketplaces.json`, `plugins/marketplaces/` — stays untracked. Tracked: `settings.json`, `CLAUDE.md`, `skills/`, `commands/`, `agents/`.

**First-time install**: `~/.claude/settings.json` may already exist as a real file, which `safe_symlink` refuses to overwrite. Back it up before running `./install`:
```sh
mv ~/.claude/settings.json ~/.claude/settings.json.bak
```

**Marketplace registration**: handled idempotently by `install` — it checks `~/.claude/plugins/known_marketplaces.json` (via `jq`) and runs `claude plugin marketplace add` only when `stelfox-curated` is missing. Registration state is per-machine (untracked) and persists across sessions.

Tracked `settings.json` deliberately does **not** declare the marketplace via `extraKnownMarketplaces`. That key only auto-registers `github`/`url` sources at session start; a local-directory source there has no effect, and `claude plugin marketplace add` rewrites the file in place with an absolute home path (non-portable). The install-script registration is the single source of truth.

`configs/claude/marketplace/` is the personal plugin marketplace — vendored skills (currently from `trailofbits/skills`) curated for review-before-install. Each plugin's `VENDORED.md` records the upstream URL, commit SHA, and license. Re-vendoring is manual: sparse-clone upstream, copy the plugin dir, bump `VENDORED.md`. **No plugin is auto-enabled** — tracked `settings.json` registers the marketplace via `extraKnownMarketplaces` but leaves `enabledPlugins` empty. Install per-machine with `/plugin install <name>@stelfox-curated`.

`configs/claude/mcp-launchers/` is the home for `pass`-backed wrappers that fetch MCP server credentials at spawn time. Pattern: each launcher reads secrets via `pass show ...` and exec's the server. Definitions tracked, secrets never on disk in tracked files. Gitignored: `*.env`, `.secrets`, `**/credentials*` under `configs/claude/`.

## Adding a new shell utility script

Scripts in `in_path/scripts/` (and binaries staged in `in_path/bin/` — gitignored) are added to `$PATH` by `common/dotfiles_path.sh.inc`. Drop new executable scripts into `in_path/scripts/`; the leading-comma convention (e.g. `,pg-common`) is intentional to make personal scripts easy to tab-complete distinctly from system tools.

## Things to know before editing

- **Don't add bashisms to `.sh.inc` files unless they live under `configs/shell/bash/` or are gated by a shell check** — most of `lib/` must stay POSIX so it works under dash, ash, and the Termux shell.
- **macOS sed is BSD sed.** `trim_whitespace` already branches on this; follow that pattern (`if [ "$(detect_os)" = "macos" ]` then use `sed -i ''`).
- **`jq` is a hard dependency for logging and tracing.** If working on a system without jq, `info`/`warn`/`err`/`fatal` will fail; `trace_enabled` returns false silently.
- **`fonts/.uuid`, `in_path/bin/`, `containers/*.tar.gz`, `configs/ssh/config`, `configs/nvim/lazyvim.json`** are gitignored on purpose. Don't try to "fix" their absence.
- **`system-specific/git-user-info.sh`** is `git update-index --assume-unchanged`'d by `legacy-install` — local edits to it should not be committed.
