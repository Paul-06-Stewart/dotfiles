#!/usr/bin/env python3
"""Capture only named personal settings and SSH public material into a local folder."""
import argparse
from pathlib import Path
import shutil
import re
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('destination', type=Path)
args = parser.parse_args()
source = Path.home()
root = args.destination.expanduser().resolve()
if root.exists():
    raise SystemExit('Choose a new destination so existing private work cannot be overwritten.')
root.mkdir(parents=True, mode=0o700)
(root / 'ssh/public-keys').mkdir(parents=True)
config = source / '.ssh/config'
if config.is_file():
    text = config.read_text()
    # OrbStack owns its own Include. It should be regenerated on each machine.
    text = '\n'.join(line for line in text.splitlines() if '.orbstack/ssh/config' not in line)
    (root / 'ssh/config').write_text(text + '\n')
for key in sorted((source / '.ssh').glob('*.pub')):
    shutil.copyfile(key, root / 'ssh/public-keys' / key.name)
for field in ('name', 'email'):
    result = subprocess.run(['git', 'config', '--global', '--includes', '--get', 'user.' + field], capture_output=True, text=True)
    if result.returncode == 0:
        # Git's own formatter quotes personal values correctly.
        subprocess.run(['git', 'config', '--file', str(root / 'gitconfig'), 'user.' + field, result.stdout.strip()], check=True)
# Capture named noncredential exports without making their values public code.
allowed = {'AWS_PROFILE', 'DOGHOUSE_USER_ID', 'DOGHOUSE_USER_NAME', 'DOGHOUSE_ORG', 'DOGHOUSE_HOME', 'OPENCODE_DISABLE_MODELS_FETCH'}
personal = []
for line in (source / '.zshrc').read_text().splitlines():
    match = re.match(r'^export ([A-Z_]+)=', line)
    if match and match.group(1) in allowed:
        personal.append(line.replace(str(source), '$HOME'))
(root / 'zshrc.local').write_text('\n'.join(personal) + '\n')
(root / '.gitignore').write_text('*.pem\n*.key\nid_*\n!*.pub\n.env*\n.secrets\nauth.json\ncredentials*\n.DS_Store\n')
(root / 'install.sh').write_text('''#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC="${DOTFILES_PUBLIC_DIR:-$(dirname "$ROOT")/dotfiles}"
if [[ ! -f "$PUBLIC/scripts/private.py" ]]; then
  echo 'Set DOTFILES_PUBLIC_DIR to the public dotfiles checkout.' >&2
  exit 1
fi
exec python3 "$PUBLIC/scripts/private.py" "$ROOT" "$@"
''')
(root / 'install.sh').chmod(0o700)
(root / 'README.md').write_text('''# Private Mac settings

Keep this repository private. It contains Git identity, internal SSH aliases, and public keys.
It contains no SSH private keys, API tokens, browser sessions, or cloud credentials.

Install the public dotfiles first, then run:

```sh
DOTFILES_PUBLIC_DIR=/path/to/dotfiles ./install.sh --dry-run
DOTFILES_PUBLIC_DIR=/path/to/dotfiles ./install.sh
```

Existing configs are backed up. The installer prints a rollback command.
SSH aliases are added through an Include without replacing other host blocks.
Public keys are saved under ~/.ssh/reference-public-keys for reference only.
They do not authorize a new Mac. Generate a separate private key on each Mac:

```sh
ssh-keygen -t ed25519 -a 100 -C "paul@new-mac"
```

Use a passphrase, add the key to Keychain, and authorize its public key with GitHub
and the machines you access. Review IdentityFile paths in ssh/config for each Mac.
Tailscale enrollment, app sign-ins, macOS permissions, and credentials remain manual.
Do not copy authorized_keys automatically because that changes who can log in.
''')
for file in root.rglob('*'):
    if file.is_file() and file.name != 'install.sh': file.chmod(0o600)
print(f'Captured private overlay locally: {root}')
print('No private keys or credentials copied. No remote repository created.')
