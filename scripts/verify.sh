#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
bash -n install.sh bootstrap.sh scripts/doctor.sh scripts/verify.sh bin/lvim bin/nvim
shellcheck install.sh bootstrap.sh scripts/doctor.sh scripts/verify.sh bin/lvim bin/nvim
zsh -n zsh/.zshrc zsh/.zprofile zsh/.p10k.zsh
python3 -m unittest discover -s tests -v
python3 scripts/audit-public.py
gitleaks dir --redact --no-banner .
