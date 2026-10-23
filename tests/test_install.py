"""Exercise the installer against real files in isolated home directories."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class Installation(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='dotfiles-test-')
        self.home = Path(self.tmp.name)
        self.env = dict(os.environ, HOME=str(self.home))

    def tearDown(self):
        self.tmp.cleanup()

    def run_script(self, *args, ok=True):
        result = subprocess.run([sys.executable, *map(str, args)], env=self.env, capture_output=True, text=True)
        if ok: self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def install(self, *args):
        return self.run_script(ROOT / 'scripts/install.py', '--config-only', *args)

    def backups(self):
        return list((self.home / '.local/state/dotfiles/backups').glob('*/manifest.json'))

    def test_dry_run_writes_nothing(self):
        self.install('--dry-run', '--macos', '--apps')
        self.assertEqual(list(self.home.iterdir()), [])

    def test_installs_current_config_and_is_idempotent(self):
        self.install()
        self.assertEqual((self.home / '.p10k.zsh').read_bytes(), (ROOT / 'zsh/.p10k.zsh').read_bytes())
        self.assertEqual((self.home / '.config/lvim/config.lua').read_bytes(), (ROOT / 'lvim/config.lua').read_bytes())
        self.assertIn('CommitMono', (self.home / 'Library/Application Support/com.mitchellh.ghostty/config').read_text())
        self.assertFalse((self.home / '.config/karabiner').exists())
        before = self.backups()
        self.install()
        self.assertEqual(self.backups(), before)
        self.assertFalse((self.home / '.ssh').exists())

    def test_restore_existing_file_and_symlink(self):
        (self.home / '.zshrc').write_text('original shell\n')
        external = self.home / 'external-tmux'
        external.write_text('original tmux\n')
        (self.home / '.tmux.conf').symlink_to(external)
        self.install()
        self.assertEqual(external.read_text(), 'original tmux\n')
        self.run_script(ROOT / 'scripts/restore.py', self.backups()[0].parent)
        self.assertEqual((self.home / '.zshrc').read_text(), 'original shell\n')
        self.assertTrue((self.home / '.tmux.conf').is_symlink())
        self.assertFalse((self.home / '.p10k.zsh').exists())

    def test_restore_preserves_later_changes(self):
        self.install()
        (self.home / '.zshrc').write_text('my later edit\n')
        result = self.run_script(ROOT / 'scripts/restore.py', self.backups()[0].parent, ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.home / '.zshrc').read_text(), 'my later edit\n')
        self.assertIn('Changed since install', result.stderr)

    def test_private_capture_excludes_credentials(self):
        (self.home / '.ssh').mkdir()
        (self.home / '.ssh/id_ed25519').write_text('do not copy this private key')
        (self.home / '.ssh/id_ed25519.pub').write_text('ssh-ed25519 AAAA public reference\n')
        (self.home / '.ssh/authorized_keys').write_text('do not copy inbound access rules')
        (self.home / '.ssh/config').write_text('Host test\n  HostName 100.64.0.1\n')
        (self.home / '.zshrc').write_text('export AWS_PROFILE=personal\nexport SECRET_TOKEN=never-copy\n')
        (self.home / '.secrets').write_text('never copy this file')
        destination = self.home / 'private-overlay'
        self.run_script(ROOT / 'scripts/capture-private.py', destination)
        captured = [p for p in destination.rglob('*') if p.is_file()]
        combined = '\n'.join(p.read_text() for p in captured)
        self.assertIn('AWS_PROFILE=personal', combined)
        self.assertNotIn('SECRET_TOKEN', combined)
        self.assertNotIn('do not copy this private key', combined)
        self.assertNotIn('do not copy inbound access rules', combined)
        self.assertFalse((destination / '.secrets').exists())
        self.assertEqual(destination.stat().st_mode & 0o777, 0o700)

    def test_private_overlay_keeps_other_hosts_and_never_copies_private_key(self):
        overlay = self.home / 'overlay'
        (overlay / 'ssh/public-keys').mkdir(parents=True)
        (overlay / 'ssh/config').write_text('Host devstudio\n  HostName 100.101.175.1\n')
        (overlay / 'ssh/public-keys/example.pub').write_text('ssh-ed25519 AAAA example\n')
        (overlay / 'ssh/id_ed25519').write_text('private content must stay here')
        (overlay / 'gitconfig').write_text('[user]\n  name = Test Person\n')
        (self.home / '.ssh').mkdir()
        (self.home / '.ssh/config').write_text('Host existing\n  HostName example.com\n')
        self.run_script(ROOT / 'scripts/private.py', overlay)
        installed = (self.home / '.ssh/config').read_text()
        self.assertIn('Host existing', installed)
        self.assertEqual(installed.count('Include ~/.ssh/config.d/paul-dotfiles.conf'), 1)
        self.run_script(ROOT / 'scripts/private.py', overlay)
        self.assertEqual(installed, (self.home / '.ssh/config').read_text())
        self.install()
        identity = subprocess.check_output(['git', 'config', '--global', '--includes', '--get', 'user.name'], env=self.env, text=True)
        self.assertEqual(identity.strip(), 'Test Person')
        self.assertFalse((self.home / '.ssh/id_ed25519').exists())
        self.assertTrue((self.home / '.ssh/reference-public-keys/example.pub').exists())
        self.assertEqual((self.home / '.ssh/config').stat().st_mode & 0o777, 0o600)


if __name__ == '__main__': unittest.main()
