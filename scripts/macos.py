#!/usr/bin/env python3
"""Apply a small preferences allowlist and preserve the previous values."""
import json
from pathlib import Path
import plistlib
import subprocess
import sys
import uuid

HOME = Path.home()
ROOT = Path(__file__).resolve().parents[1]


def read(domain):
    result = subprocess.run(['defaults', 'export', domain, '-'], capture_output=True)
    return plistlib.loads(result.stdout) if result.returncode == 0 else {}


def write(domain, key, value):
    if value is None:
        subprocess.run(['defaults', 'delete', domain, key], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        flag = {bool: '-bool', int: '-int', float: '-float', str: '-string'}[type(value)]
        text = str(value).lower() if isinstance(value, bool) else str(value)
        subprocess.run(['defaults', 'write', domain, key, flag, text.replace('${HOME}', str(HOME))], check=True)


def main():
    if sys.platform != 'darwin':
        raise SystemExit('macOS required')
    if sys.argv[1] == 'apply':
        settings = json.loads((ROOT / 'macos/preferences.json').read_text())
        changes = []
        for entry in settings:
            previous = read(entry['domain'])
            value = entry['value']
            expanded = value.replace('${HOME}', str(HOME)) if isinstance(value, str) else value
            if previous.get(entry['key']) != expanded:
                changes.append(dict(entry, previous=previous.get(entry['key'])))
        if not changes:
            print('macOS preferences already match.')
            return
        backup = HOME / '.local/state/dotfiles/macos' / (uuid.uuid4().hex + '.json')
        backup.parent.mkdir(parents=True, exist_ok=True)
        backup.write_text(json.dumps(changes, indent=2) + '\n')
        backup.chmod(0o600)
        print(f'Preferences rollback: python3 {__file__} restore {backup}', flush=True)
        for entry in changes:
            write(entry['domain'], entry['key'], entry['value'])
            actual = read(entry['domain']).get(entry['key'])
            expected = entry['value']
            if isinstance(expected, str): expected = expected.replace('${HOME}', str(HOME))
            if actual != expected:
                raise RuntimeError(f"Preference readback failed: {entry['domain']} {entry['key']}")
        print('Preferences applied and read back. Log out and back in to refresh Finder and Dock.')
    elif sys.argv[1] == 'restore':
        for entry in json.loads(Path(sys.argv[2]).read_text()):
            write(entry['domain'], entry['key'], entry['previous'])
        print('Previous preferences restored. Log out and back in.')
    else:
        raise SystemExit('Usage: macos.py apply | restore BACKUP.json')


if __name__ == '__main__': main()
