"""Preference writes are mocked: no real macOS settings change in tests."""
import copy
import importlib.util
from pathlib import Path
import plistlib
import subprocess
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("macos", ROOT / "scripts/macos.py")
macos = importlib.util.module_from_spec(spec)
spec.loader.exec_module(macos)


class MacOSPreferencesTests(unittest.TestCase):
    def test_dry_run_does_not_read_back_up_or_change_preferences(self):
        argv = ["macos.py", "--finder", "--dock", "--windows", "--wallpaper", "--terminal", "--dry-run"]
        with patch("sys.platform", "darwin"), patch("sys.argv", argv), \
             patch.object(macos, "export") as export, \
             patch.object(macos, "backup") as backup, \
             patch.object(macos.subprocess, "run") as run, patch("builtins.print"):
            macos.main()
            export.assert_not_called()
            backup.assert_not_called()
            run.assert_not_called()

    def test_desktop_preferences_preserve_other_settings_and_repeat_without_writes(self):
        existing = {
            "com.apple.finder": {"AppleShowAllFiles": False, "ShowPathbar": True},
            "NSGlobalDomain": {"AppleShowAllExtensions": False, "AppleInterfaceStyle": "Dark"},
            "com.apple.dock": {
                "autohide": False, "autohide-delay": 0.5, "autohide-time-modifier": 0.0,
                "show-recents": True, "magnification": False, "tilesize": 60.0,
                "largesize": 80.0, "size-immutable": True,
                "persistent-apps": [{"tile-data": {"file-label": "My pinned app"}}],
            },
            "com.apple.WindowManager": {
                "EnableStandardClickToShowDesktop": True,
                "EnableTilingByEdgeDrag": False, "EnableTopTilingByEdgeDrag": False,
                "EnableTiledWindowMargins": True, "Unrelated": "keep me",
            },
        }
        state = copy.deepcopy(existing)
        backups = {}

        def save(domain, prefs):
            self.assertNotIn(domain, backups)
            backups[domain] = copy.deepcopy(prefs)

        def execute(args, **kwargs):
            self.assertEqual("defaults", args[0])
            operation, domain, key = args[1:4]
            self.assertIn(domain, backups, "Back up before the first write")
            if operation == "delete":
                del state[domain][key]
            else:
                self.assertEqual("write", operation)
                kind, value = args[4:]
                self.assertIn(kind, ("-bool", "-float"))
                state[domain][key] = value == "true" if kind == "-bool" else float(value)
            return subprocess.CompletedProcess(args, 0)

        argv = ["macos.py", "--finder", "--dock", "--windows", "--wallpaper"]
        with patch("sys.platform", "darwin"), patch("sys.argv", argv), \
             patch.object(macos, "export", side_effect=lambda domain: copy.deepcopy(state[domain])), \
             patch.object(macos, "backup", side_effect=save), \
             patch.object(macos.subprocess, "run", side_effect=execute) as run, patch("builtins.print"):
            macos.main()
            self.assertEqual(existing, backups)
            self.assertEqual({"AppleShowAllFiles": True, "ShowPathbar": True}, state["com.apple.finder"])
            self.assertEqual({"AppleShowAllExtensions": True, "AppleInterfaceStyle": "Dark"}, state["NSGlobalDomain"])
            self.assertEqual({
                "autohide": True, "autohide-delay": 0.0, "show-recents": False,
                "magnification": True, "tilesize": 52.0, "largesize": 71.0,
                "size-immutable": False, "persistent-apps": existing["com.apple.dock"]["persistent-apps"],
            }, state["com.apple.dock"])
            self.assertEqual({
                "EnableStandardClickToShowDesktop": False, "EnableTilingByEdgeDrag": True,
                "EnableTopTilingByEdgeDrag": True, "EnableTiledWindowMargins": False,
                "Unrelated": "keep me",
            }, state["com.apple.WindowManager"])
            run.reset_mock()
            macos.main()
            run.assert_not_called()

    def test_preference_verification_detects_a_write_that_did_not_take_effect(self):
        with patch.object(macos, "export", return_value={"AppleShowAllFiles": False}), \
             patch.object(macos, "backup"), patch.object(macos.subprocess, "run"), patch("builtins.print"):
            with self.assertRaisesRegex(RuntimeError, "Preference verification failed"):
                macos.apply_preferences("com.apple.finder", {"AppleShowAllFiles": True})

    def test_terminal_does_not_import_while_app_is_running(self):
        with patch("sys.platform", "darwin"), patch("sys.argv", ["macos.py", "--terminal"]), \
             patch.object(macos.subprocess, "run", return_value=subprocess.CompletedProcess([], 0)), \
             patch.object(macos, "export") as export:
            with self.assertRaisesRegex(RuntimeError, "Quit Apple Terminal"):
                macos.main()
            export.assert_not_called()

    def test_import_preserves_other_profiles_and_preferences(self):
        existing = {"Window Settings": {"My Profile": {"name": "My Profile", "Font": b"original"}},
                    "Default Window Settings": "My Profile", "Unrelated": True}
        state = copy.deepcopy(existing)
        backups = []
        def execute(args, **kwargs):
            if args[0] == "pgrep":
                return subprocess.CompletedProcess(args, 1)
            self.assertEqual(["defaults", "import", "com.apple.Terminal", "-"], args)
            state.clear()
            state.update(plistlib.loads(kwargs["input"]))
            return subprocess.CompletedProcess(args, 0)
        with patch("sys.platform", "darwin"), patch("sys.argv", ["macos.py", "--terminal"]), \
             patch.object(macos, "export", side_effect=lambda _: copy.deepcopy(state)), \
             patch.object(macos, "backup", side_effect=lambda domain, prefs: backups.append((domain, copy.deepcopy(prefs)))) as backup, \
             patch.object(macos.subprocess, "run", side_effect=execute):
            macos.main()
            self.assertEqual([("com.apple.Terminal", existing)], backups)
            self.assertEqual(existing["Window Settings"]["My Profile"], state["Window Settings"]["My Profile"])
            self.assertTrue(state["Unrelated"])
            self.assertEqual("Dotfiles", state["Default Window Settings"])
            macos.main()
            self.assertEqual(1, backup.call_count)


if __name__ == "__main__":
    unittest.main()
