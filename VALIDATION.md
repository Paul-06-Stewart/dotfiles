# Local validation

Verified on macOS arm64 with a temporary HOME. The source MacBook's live config files were not replaced.

- `./scripts/verify.sh` passed shell syntax checks, ShellCheck, six install/restore/private-data tests, the public-file audit, and Gitleaks.
- `gitleaks git --redact --no-banner .` found no credential matches in the existing public repository history.
- `./install.sh --dry-run --apps --macos` printed the install plan without writes.
- `scripts/install.py` config installation and `runtime()` completed in an isolated HOME using existing Homebrew dependencies. A repeat runtime installation completed without reinstall prompts.
- `scripts/doctor.sh` passed with the private overlay applied to that temporary HOME. Neovim 0.11.5 started, LunarVim loaded its theme and native fzf extension, and all 28 parsers and 17 Mason packages were available.
- An interactive Zsh login loaded the shell config, colorls, LunarVim, and Git aliases.
- An isolated tmux server confirmed Ctrl+a, mouse support, the transparent status theme, tmux-256color, and aggressive-resize disabled. The test server was stopped afterward.
- Ghostty's `+validate-config` accepted the packaged configuration.
- Homebrew metadata resolved every formula and optional application in the Brewfiles.
- Private overlay application preserved existing host blocks. Its SSH definitions resolved devmini, devstudio, and homestudio to the intended addresses.

A wiped Mac, Intel runtime, first-time Homebrew installation, app sign-ins, font rendering, and macOS preference writes have not been tested here.
The curl entry point becomes available after this change is published to main. The private package is local until a private remote is explicitly created.
