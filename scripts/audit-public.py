#!/usr/bin/env python3
"""Fail on credential-shaped files and values in the public working tree."""
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
files = subprocess.check_output(['git', '-C', str(root), 'ls-files', '-co', '--exclude-standard'], text=True).splitlines()
patterns = [
    re.compile(r'-----BEGIN (?:OPENSSH |RSA |EC |DSA )?PRIVATE KEY-----'),
    re.compile(r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b'),
    re.compile(r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})\b'),
    re.compile(r'\bsk-(?:ant-)?[A-Za-z0-9_-]{28,}\b'),
    re.compile(r'/Users/[A-Za-z][^/\s"\']*/'),
]
errors = []
for name in sorted(set(files)):
    path = root / name
    if not path.is_file(): continue
    if any(part in {'.ssh', '.aws', '.auth', 'private'} for part in path.relative_to(root).parts):
        errors.append(f'{name}: private directory in public package')
    if path.name in {'auth.json', '.secrets', '.env', 'credentials', 'authorized_keys', 'known_hosts'}:
        errors.append(f'{name}: forbidden filename')
    if name == 'scripts/audit-public.py': continue
    text = path.read_text(errors='replace')
    if any(pattern.search(text) for pattern in patterns):
        errors.append(f'{name}: credential marker or machine-specific home path; inspect locally')
if errors:
    print('\n'.join(errors), file=sys.stderr)
    raise SystemExit(1)
print(f'Public allowlist checks passed for {len(set(files))} files. Run gitleaks for broader detection.')
