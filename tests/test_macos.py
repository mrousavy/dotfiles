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
