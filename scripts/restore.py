#!/usr/bin/env python3
"""Restore a config backup without overwriting changes made since installation."""
import json
from pathlib import Path
import shutil
import sys
from install import HOME, digest

backup = Path(sys.argv[1]).expanduser().resolve()
state = (HOME / '.local/state/dotfiles/backups').resolve()
if not backup.is_relative_to(state):
    raise SystemExit('Expected a backup under ~/.local/state/dotfiles/backups')
entries = json.loads((backup / 'manifest.json').read_text())
for entry in entries:
    relative = Path(entry['target'])
    if relative.is_absolute() or '..' in relative.parts:
        raise SystemExit('Unsafe backup manifest')
    target = HOME / relative
    if digest(target) != entry['installed']:
        raise SystemExit(f'Changed since install; refusing to overwrite: {target}. Restore this file manually.')
for entry in reversed(entries):
    target = HOME / entry['target']
    target.unlink()
    if entry['existed']:
        shutil.copy2(backup / 'files' / entry['target'], target, follow_symlinks=False)
    print(f'Restored {target}')
print('Configs restored. Installed packages and downloaded runtimes remain available.')
