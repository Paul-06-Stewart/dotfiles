#!/usr/bin/env python3
"""Install explicit config files, recording reversible changes before each write."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import shlex
import subprocess
import sys
import uuid
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
HOME = Path.home()


def digest(path):
    if path.is_symlink():
        return 'link:' + os.readlink(path)
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None


class Installer:
    def __init__(self, dry_run=False):
        self.dry_run = dry_run
        self.journal = None
        self.entries = []

    def write(self, relative, data, mode=0o644):
        target = HOME / relative
        if not target.is_relative_to(HOME) or '..' in Path(relative).parts:
            raise ValueError(f'Unsafe target: {relative}')
        for parent in target.parents:
            if parent == HOME:
                break
            if parent.is_symlink():
                raise ValueError(f'Refusing to write through a symlinked directory: {parent}')
        if target.is_file() and not target.is_symlink() and target.read_bytes() == data and (target.stat().st_mode & 0o777) == mode:
            return
        print(('Would install ' if self.dry_run else 'Installing ') + str(target))
        if self.dry_run:
            return
        if self.journal is None:
            stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-' + uuid.uuid4().hex[:8]
            self.journal = HOME / '.local/state/dotfiles/backups' / stamp
            self.journal.mkdir(parents=True, mode=0o700)
            self.journal.chmod(0o700)
        backup = self.journal / 'files' / relative
        existed = target.exists() or target.is_symlink()
        if existed and target.is_dir() and not target.is_symlink():
            raise ValueError(f'Expected a file, found directory: {target}')
        entry = {'target': relative, 'existed': existed, 'installed': hashlib.sha256(data).hexdigest()}
        if existed:
            backup.parent.mkdir(parents=True, exist_ok=True)
            if target.is_symlink():
                backup.symlink_to(os.readlink(target))
            else:
                shutil.copy2(target, backup)
        self.entries.append(entry)
        (self.journal / 'manifest.json').write_text(json.dumps(self.entries, indent=2) + '\n')
        (self.journal / 'manifest.json').chmod(0o600)
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_name(target.name + '.dotfiles-' + uuid.uuid4().hex)
        try:
            temporary.write_bytes(data)
            temporary.chmod(mode)
            temporary.replace(target)
        finally:
            temporary.unlink(missing_ok=True)

    def copy(self, source, relative, mode=0o644):
        self.write(relative, source.read_bytes(), mode)

    def receipt(self):
        if self.journal:
            print(f'Config backup: {self.journal}')
            print('Rollback: python3 ' + shlex.quote(str(ROOT / 'scripts/restore.py')) + ' ' + shlex.quote(str(self.journal)))


def configs(installer, karabiner=False):
    files = {
        'zsh/.zshrc': '.zshrc', 'zsh/.zprofile': '.zprofile',
        'zsh/.p10k.zsh': '.p10k.zsh', 'zsh/.dircolors': '.dircolors',
        'tmux/.tmux.conf': '.tmux.conf', 'git/.gitconfig': '.gitconfig',
        'git/.gitignore_global': '.gitignore_global',
        'ghostty/config': 'Library/Application Support/com.mitchellh.ghostty/config',
        'ghostty/xdg-config': '.config/ghostty/config',
        'ghostty/themes/Soft Latte': '.config/ghostty/themes/Soft Latte',
        'colorls/dark_colors.yaml': '.config/colorls/dark_colors.yaml',
        'cava/config': '.config/cava/config',
        'nvim/init.lua': '.config/nvim/init.lua', 'nvim/lazy-lock.json': '.config/nvim/lazy-lock.json',
        'lvim/config.lua': '.config/lvim/config.lua', 'lvim/lazy-lock.json': '.config/lvim/lazy-lock.json',
        'lvim/entry.lua': '.local/share/dotfiles/lvim-entry.lua',
        'spotify-player/app.toml': '.config/spotify-player/app.toml',
        'spotify-player/theme.toml': '.config/spotify-player/theme.toml',
    }
    if karabiner:
        files['karabiner/karabiner.json'] = '.config/karabiner/karabiner.json'
    for relative in ('lua/config/lazy.lua', 'lua/config/options.lua', 'lua/config/keymaps.lua', 'lua/config/autocmds.lua', 'lua/plugins/init.lua', 'lazyvim.json', 'stylua.toml'):
        files['nvim/' + relative] = '.config/nvim/' + relative
    for source, target in files.items():
        installer.copy(ROOT / source, target)
    for binary in ('lvim', 'nvim'):
        installer.copy(ROOT / 'bin' / binary, '.local/bin/' + binary, 0o755)


def run(*args, **kwargs):
    print('+ ' + ' '.join(str(arg) for arg in args), flush=True)
    subprocess.run(args, check=True, timeout=900, **kwargs)


def pinned_clone(url, path, revision):
    if path.exists():
        head = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], text=True).strip()
        status = subprocess.check_output(['git', '-C', str(path), 'status', '--porcelain'], text=True)
        if head != revision or status:
            raise RuntimeError(f'Existing checkout differs from the pin or has changes: {path}. Move it aside and rerun.')
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    import tempfile
    with tempfile.TemporaryDirectory(prefix='.clone-', dir=path.parent) as temporary:
        checkout = Path(temporary) / 'repo'
        run('git', 'init', str(checkout))
        run('git', '-C', str(checkout), 'remote', 'add', 'origin', url)
        run('git', '-C', str(checkout), 'fetch', '--depth=1', 'origin', revision)
        run('git', '-C', str(checkout), 'checkout', '--detach', 'FETCH_HEAD')
        checkout.rename(path)


def runtime():
    import platform
    import tempfile
    pins = json.loads((ROOT / 'lvim/pins.json').read_text())
    arch = platform.machine()
    expected = pins['neovim_sha256'][arch]
    version = pins['neovim']
    destination = HOME / '.local/share/dotfiles/neovim' / version
    binary = destination / f'nvim-macos-{arch}/bin/nvim'
    if not binary.exists():
        destination.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='.neovim-', dir=destination.parent) as tmp:
            archive = Path(tmp) / 'nvim.tar.gz'
            run('curl', '--proto', '=https', '--tlsv1.2', '-fsSL', f'https://github.com/neovim/neovim/releases/download/v{version}/nvim-macos-{arch}.tar.gz', '-o', str(archive))
            if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
                raise RuntimeError('Neovim archive checksum did not match the pinned release.')
            unpacked = Path(tmp) / 'unpacked'
            unpacked.mkdir()
            run('tar', '-xzf', str(archive), '-C', str(unpacked))
            if not (unpacked / f'nvim-macos-{arch}/bin/nvim').exists():
                raise RuntimeError('Neovim archive layout changed.')
            if destination.exists():
                raise RuntimeError(f'Partial Neovim install exists: {destination}. Move it aside and rerun.')
            unpacked.rename(destination)
    pinned_clone('https://github.com/LunarVim/LunarVim.git', HOME / '.local/share/dotfiles/lunarvim' / pins['lunarvim'], pins['lunarvim'])
    pinned_clone('https://github.com/romkatv/powerlevel10k.git', HOME / '.powerlevel10k', pins['powerlevel10k'])
    pinned_clone('https://github.com/tmux-plugins/tpm.git', HOME / '.tmux/plugins/tpm', pins['tpm'])
    for plugin in ('tmux-sensible', 'tmux-resurrect'):
        pinned_clone('https://github.com/tmux-plugins/' + plugin + '.git', HOME / '.tmux/plugins' / plugin, pins[plugin])
    prefix = subprocess.check_output(['brew', '--prefix'], text=True).strip()
    ruby = str(Path(prefix) / 'opt/ruby/bin/gem')
    gem_env = dict(os.environ, GEM_HOME=str(HOME / '.local/share/gem'), GEM_PATH=str(HOME / '.local/share/gem'))
    if subprocess.run([ruby, 'list', '--installed', 'colorls'], env=gem_env, stdout=subprocess.DEVNULL).returncode:
        run(ruby, 'install', 'colorls', '--version', '1.5.0', '--no-document', env=gem_env)
    env = dict(os.environ)
    env['PATH'] = str(HOME / '.local/bin') + os.pathsep + env['PATH']
    env['DOTFILES_EDITOR_SETUP'] = str(ROOT / 'scripts/editor-setup.lua')
    env['DOTFILES_MASON_VERSIONS'] = str(ROOT / 'lvim/mason-versions.json')
    env['JAVA_HOME'] = str(Path(prefix) / 'opt/openjdk@21/libexec/openjdk.jdk/Contents/Home')
    run(str(HOME / '.local/bin/nvim'), '--headless', '+Lazy! restore', '+qa', env=env)
    run(str(HOME / '.local/bin/lvim'), '--headless', '+Lazy! restore', '+qa', env=env)
    run(str(HOME / '.local/bin/lvim'), '--headless', '-c', 'autocmd VimEnter * lua dofile(vim.env.DOTFILES_EDITOR_SETUP)', env=env)


def main():
    parser = argparse.ArgumentParser()
    for flag in ('dry-run', 'config-only', 'apps', 'macos', 'karabiner'):
        parser.add_argument('--' + flag, action='store_true')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.error('macOS required')
    installer = Installer(args.dry_run)
    try:
        if args.dry_run and not args.config_only:
            print('Would install Homebrew dependencies, pinned Neovim/LunarVim, shell/tmux plugins, and editor tools.')
        if args.dry_run and args.apps:
            print('Would install Brewfile.apps.')
        configs(installer, args.karabiner)
        if not args.config_only and not args.dry_run:
            runtime()
        if args.macos:
            if args.dry_run:
                print('Would apply macos/preferences.json, backing up each existing value.')
            else:
                run(sys.executable, str(ROOT / 'scripts/macos.py'), 'apply')
    finally:
        installer.receipt()
    print('Plan complete.' if args.dry_run else 'Config installation complete. Open a new Ghostty window. Run scripts/doctor.sh to check setup.')


if __name__ == '__main__':
    main()
