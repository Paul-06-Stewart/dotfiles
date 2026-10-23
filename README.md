# Paul's Mac setup

Restore the MacBook's terminal and editor setup on a new Apple Silicon or Intel Mac.
The installer backs up files it replaces and prints a rollback command.

## Install on a new Mac

```sh
git clone https://github.com/Paul-06-Stewart/dotfiles.git
cd dotfiles
./install.sh --apps --macos
```

If macOS asks you to install Command Line Tools, finish that installation and run the command again.
Homebrew and some applications need an administrator password. Run the installer as your normal user.

Open a new Ghostty window when installation finishes. Then check the setup:

```sh
./scripts/doctor.sh
```

The public setup does not set your Git identity. Add it with the private overlay or run:

```sh
git config --file ~/.gitconfig.local user.name 'Your Name'
git config --file ~/.gitconfig.local user.email 'you@example.com'
```

After this version is published to `main`, the download entry point is:

```sh
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/Paul-06-Stewart/dotfiles/main/bootstrap.sh \
  -o /tmp/paul-dotfiles-bootstrap.sh
bash /tmp/paul-dotfiles-bootstrap.sh --apps --macos
```

For a pipe-based install, use `curl -fsSL URL | bash -s -- --apps --macos`.
Downloading the script first lets you inspect it. `bootstrap.sh` clones into
`~/.local/share/paul-dotfiles`. It refuses to overwrite an existing checkout.
Set `DOTFILES_DIR` to choose another destination.

## Choose what to install

| Command | Result |
| --- | --- |
| `./install.sh --dry-run` | Show the plan without writes or downloads. Requires Python 3. |
| `./install.sh` | Install terminal tools, configs, pinned editor runtimes, plugins, parsers, and language servers. |
| `./install.sh --apps --macos` | Also install the desktop app list and captured Dock/Finder preferences. |
| `./install.sh --config-only` | Copy configs without downloads. Requires Python 3 and preinstalled tools for a working terminal. |
| `./install.sh --karabiner` | Also install the keyboard mapping config. Install Karabiner with `--apps`. |

Reruns skip identical config files. Homebrew uses `--no-upgrade` so the installer does not request a general package upgrade.
Pinned runtime checkouts must be clean and at the expected revision. Move a conflicting checkout aside before rerunning.

## What matches the MacBook

| Area | Included |
| --- | --- |
| Zsh | Current Powerlevel10k config, completions, Git/navigation aliases, fzf, zoxide, direnv, autosuggestions, syntax highlighting, colorls colors. |
| Ghostty | CommitMono Nerd Font, transparent window, spacing, Shift+Enter binding, automatic Catppuccin Mocha/Soft Latte appearance. |
| tmux | Ctrl+a prefix, mouse, pane/window bindings, transparent status theme, sensible and resurrect plugins. No old sessions or pane history. |
| LunarVim | Current config and plugin lockfile, local compatibility fixes, pinned LunarVim core and Neovim 0.11.5, 28 parsers, 15 language servers and 2 formatters. |
| Neovim | Standalone config and lockfile, alongside LunarVim. |
| Git | Delta, Git LFS filters, macOS Keychain helper, global ignore file, private identity include. |
| Other configs | colorls, Cava, Spotify player. Karabiner mappings are opt-in because they can disable a built-in keyboard. |
| macOS | The explicit settings in `macos/preferences.json`, including the left auto-hiding Dock and Finder path bar. No running apps are restarted. |

`Brewfile` contains the terminal and development dependencies. `Brewfile.apps` contains optional desktop apps.
`inventory/` records the source MacBook's installed formulae, casks, and app names for reference.
The inventory is not an instruction to install every historical language toolchain or paid app.

Neovim release archives are verified against the SHA-256 hashes in `lvim/pins.json`.
LunarVim, Powerlevel10k, and tmux plugins use pinned Git commits. LunarVim plugins use the MacBook's lockfile.
Mason server versions are captured in `lvim/mason-versions.json`; formatters use the registry's available release.
Homebrew packages, application versions, parser downloads, and upstream availability can change.

Ghostty's authoritative config is installed under `~/Library/Application Support/com.mitchellh.ghostty/config`.
The XDG config is a pointer comment, and the custom Soft Latte theme lives in `~/.config/ghostty/themes`.

## Add private settings

The companion private package contains SSH host aliases, reference public keys, Git identity, and personal shell settings.
It does not contain SSH private keys, API tokens, app sessions, cloud credentials, or `authorized_keys`.
Public keys are not secret, but hostnames and key associations belong in the private package.

On the source Mac, capture the allowlist into a new folder:

```sh
python3 scripts/capture-private.py ../dotfiles-private
```

Keep that folder in a private repository. After authenticating GitHub on the new Mac, clone it and run:

```sh
cd ../dotfiles-private
DOTFILES_PUBLIC_DIR=../dotfiles ./install.sh --dry-run
DOTFILES_PUBLIC_DIR=../dotfiles ./install.sh
```

The private installer preserves existing SSH host blocks and adds an Include before them.
Existing `IdentityFile` paths may refer to keys that are intentionally absent on the new Mac.
Generate a separate passphrase-protected SSH key on each Mac and authorize that public key with the services you use.
Reference public keys are copied into `~/.ssh/reference-public-keys`; they are never installed as your new identity.

Custom local settings belong in `~/.zshrc.local`, `~/.zprofile.local`, or `~/.gitconfig.local`.
API keys can live in a local `~/.secrets` with mode `600`. Do not commit it, even to this private package.

## Restore replaced files

Each run prints the exact backup path and command:

```sh
python3 scripts/restore.py ~/.local/state/dotfiles/backups/RUN-ID
```

Restore refuses to overwrite configs edited since installation. Restore those files manually from the backup.
If multiple installs changed a file, restore their backups in reverse order.
Packages and downloaded runtimes remain installed. Preferences have a separate JSON backup and printed rollback command.

## Finish the Mac setup

Sign in to Tailscale and the apps you use. Grant macOS permissions for Karabiner, Rectangle, and screen recording when requested.
Authorize the new Mac's SSH key. Reauthenticate GitHub, AWS, and coding assistants.
Install paid, App Store, employer-managed, or custom applications separately using `inventory/applications.txt` as a checklist.
Set up Dock app positions, wallpaper, browser profiles, Touch ID, and account-specific settings manually.
This package does not change Remote Login, Screen Sharing, firewall policy, or Tailscale ACLs.

## Validate changes

```sh
./scripts/verify.sh
```

This runs shell syntax checks, ShellCheck, isolated config install/restore tests, a public-file audit, and Gitleaks.
CI runs it on macOS. Full runtime installation downloads dependencies and is checked separately with `scripts/doctor.sh`.

Upstream references: [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile),
[Neovim 0.11.5](https://github.com/neovim/neovim/releases/tag/v0.11.5),
[LunarVim](https://github.com/LunarVim/LunarVim).
