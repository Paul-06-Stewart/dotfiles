# Dotfiles contribution rules

This repository builds a macOS terminal/editor setup. It is a public package.

- `install.sh` bootstraps Homebrew and calls `scripts/install.py`.
- `scripts/install.py` owns the config allowlist, backups, and runtime installation.
- `scripts/private.py` applies an explicitly separate private overlay.
- `scripts/capture-private.py` captures only named personal settings and SSH public material.
- `macos/preferences.json` is the explicit macOS settings allowlist.
- `lvim/pins.json`, `lvim/lazy-lock.json`, and `lvim/mason-versions.json` describe editor/runtime pins.
- `inventory/` is source-machine software reference data, not a full install list.

Run `./scripts/verify.sh` before delivery. It requires macOS, Python 3, zsh, ShellCheck, and Gitleaks.
Use a temporary HOME to test `./install.sh --config-only`; never replace the contributor's live configs as a test.
For a full runtime check, also use a temporary HOME and run `scripts/doctor.sh` with the private Git identity supplied separately.
Do not copy existing caches, sessions, histories, native plugin binaries, credentials, or entire config directories.
Keep install operations idempotent and preserve existing files with the backup mechanism.
Do not publish or push private overlay data with the public repo. Do not change remote-access policy in this installer.
Completion requires fresh config/rollback checks and a clear distinction between runtime tests, a clean-Mac test, and publication.
