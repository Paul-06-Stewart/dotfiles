#!/usr/bin/env python3
"""Apply an allowlisted private overlay. Never installs private keys or credentials."""
import argparse
from pathlib import Path
import re
from install import HOME, Installer


def apply(root, dry_run=False):
    installer = Installer(dry_run)
    try:
        for source, target in [('gitconfig', '.gitconfig.local'), ('zshrc.local', '.zshrc.local'), ('zprofile.local', '.zprofile.local')]:
            if (root / source).is_file():
                installer.copy(root / source, target, 0o600)
        ssh = root / 'ssh/config'
        if ssh.is_file():
            installer.copy(ssh, '.ssh/config.d/paul-dotfiles.conf', 0o600)
            config = HOME / '.ssh/config'
            text = config.read_text() if config.exists() else ''
            include = 'Include ~/.ssh/config.d/paul-dotfiles.conf'
            # Put the include before Host blocks. Preserve existing config below it.
            text = '\n'.join(line for line in text.splitlines() if line.strip() != include)
            installer.write('.ssh/config', (include + '\n' + (text + '\n' if text else '')).encode(), 0o600)
        for public_key in sorted((root / 'ssh/public-keys').glob('*.pub')):
            if not re.match(r'^(ssh-|ecdsa-|sk-)', public_key.read_text()):
                raise ValueError(f'Not a public key: {public_key.name}')
            # Reference copies only. Never pair an old public key with a new private key.
            installer.copy(public_key, '.ssh/reference-public-keys/' + public_key.name, 0o600)
        if not dry_run and (HOME / '.ssh').exists():
            (HOME / '.ssh').chmod(0o700)
    finally:
        installer.receipt()
    print('Private overlay ready. Existing host IdentityFile paths may require fresh key authorization.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('overlay', type=Path)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    apply(args.overlay.resolve(), args.dry_run)
