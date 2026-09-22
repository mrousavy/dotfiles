"""Installer regression tests using separate destinations, never a fake HOME."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("installer", ROOT / "scripts/install.py")
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class InstallTests(unittest.TestCase):
    def invoke(self, destination, *flags):
        return subprocess.run([sys.executable, str(ROOT / "scripts/install.py"),
                               "--target", str(destination), *flags],
                              capture_output=True, text=True, check=True)

    def test_dry_run_does_not_create_target(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / "new-mac"
            result = self.invoke(target, "--dry-run")
            self.assertIn("vim-one", result.stdout)
            self.assertFalse(target.exists())

    def test_existing_files_and_broken_links_are_backed_up_once(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / "Mac with spaces"
            target.mkdir()
            (target / ".zshrc").write_text("# original config\n")
            (target / ".vimrc").symlink_to(target / "missing-original")
            git_config = target / ".config/git"
            git_config.mkdir(parents=True)
            (git_config / "ignore").write_text("# original ignore\nlocal-only\n")
            (git_config / "config").write_text("# keep this config\n")
            self.invoke(target, "--link-only")
            manifests = list(target.glob(".local/state/dotfiles/backups/*/manifest.json"))
            self.assertEqual(1, len(manifests))
            records = json.loads(manifests[0].read_text())
            self.assertEqual(3, len(records))
            saved = {Path(r["original"]).name: Path(r["backup"]) for r in records}
            self.assertEqual("# original config\n", saved[".zshrc"].read_text())
            self.assertTrue(saved[".vimrc"].is_symlink())
            self.assertEqual("# original ignore\nlocal-only\n", saved["ignore"].read_text())
            self.assertEqual("# keep this config\n", (git_config / "config").read_text())
            for name in installer.FILES:
                self.assertEqual(ROOT / name, (target / name).resolve())
            self.invoke(target, "--link-only")
            self.assertEqual(manifests, list(target.glob(".local/state/dotfiles/backups/*/manifest.json")))

    def test_config_parent_cannot_redirect_links_outside_target(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / "target"
            elsewhere = Path(temp) / "other"
            target.mkdir()
            (elsewhere / "git").mkdir(parents=True)
            original = elsewhere / "git/ignore"
            original.write_text("keep me\n")
            (target / ".config").symlink_to(elsewhere)
            with self.assertRaisesRegex(RuntimeError, "directory symlink"):
                installer.Installer(target).link(".config/git/ignore")
            self.assertEqual("keep me\n", original.read_text())
            self.assertFalse(original.is_symlink())

    def test_failed_download_preserves_existing_plugin(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp)
            path = target / ".vim/pack/vendor/start/example"
            path.mkdir(parents=True)
            (path / "local-change").write_text("keep me")
            plugin = {"name": "example", "path": str(path.relative_to(target)),
                      "url": "https://example.invalid/plugin.git", "commit": "a" * 40}
            with patch.object(installer, "run", side_effect=subprocess.CalledProcessError(1, "git")):
                with self.assertRaises(subprocess.CalledProcessError):
                    installer.Installer(target).plugin(plugin)
            self.assertEqual("keep me", (path / "local-change").read_text())
            self.assertFalse((target / ".local").exists())

    def test_plugin_parent_cannot_redirect_installation_outside_target(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / "target"
            elsewhere = Path(temp) / "other"
            target.mkdir()
            elsewhere.mkdir()
            (target / ".vim").symlink_to(elsewhere)
            plugin = {"name": "example", "path": ".vim/pack/vendor/start/example"}
            with self.assertRaisesRegex(RuntimeError, "directory symlink"):
                installer.Installer(target).plugin(plugin)
            self.assertEqual([], list(elsewhere.iterdir()))


if __name__ == "__main__":
    unittest.main()
