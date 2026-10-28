"""Exercise the generated activation without installing packages or activating Home Manager."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class GlobalNpmPackagesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="claude-activation-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home with 'quote"
        self.tools = Path(self.temp.name) / "tools"
        self.tools.mkdir()
        self.log = Path(self.temp.name) / "calls"
        self.env = {**os.environ, "CALL_LOG": str(self.log)}
        self.write_executable("bun", 'printf "bun\\n" >> "$CALL_LOG"\nexit "${BUN_EXIT:-0}"\n')
        self.write_executable("node", '''
[ "$1" = "$BUN_INSTALL_GLOBAL_DIR/node_modules/@anthropic-ai/claude-code/install.cjs" ] || exit 90
[ -f "$1" ] || exit 91
printf "postinstall\\n" >> "$CALL_LOG"
exit "${POSTINSTALL_EXIT:-0}"
''')
        self.claude_dir = self.home / ".bun/install/global/node_modules/@anthropic-ai/claude-code"
        self.claude_dir.mkdir(parents=True)
        (self.claude_dir / "install.cjs").touch()
        self.bin = self.home / ".bun/bin"
        self.bin.mkdir(parents=True)
        claude = self.bin / "claude"
        claude.write_text('''#!/bin/sh
[ "$1" = "--version" ] || exit 92
printf "verify\\n" >> "$CALL_LOG"
exit "${CLAUDE_EXIT:-0}"
''')
        claude.chmod(0o755)

    def write_executable(self, name, body):
        path = self.tools / name / "bin" / name
        path.parent.mkdir(parents=True)
        path.write_text("#!/bin/sh\nset -eu\n" + body)
        path.chmod(0o755)

    def activation(self, darwin=False):
        # Use the real Nixpkgs shell escaping/getExe helpers; only the package
        # executables and Home Manager DAG constructor are substituted.
        expression = f'''
          let
            flake = builtins.getFlake {json.dumps('git+file://' + str(ROOT))};
            lib = flake.inputs.nixpkgs.lib // {{
              hm.dag.entryAfter = after: data: {{ inherit after data; }};
            }};
            module = import {ROOT}/shared/npm-cli-packages.nix {{
              inherit lib;
              config.home.homeDirectory = {json.dumps(str(self.home))};
              pkgs = {{
                stdenv.isDarwin = {str(darwin).lower()};
                bun = {{ type = "derivation"; outPath = {json.dumps(str(self.tools / 'bun'))}; meta.mainProgram = "bun"; }};
                nodejs = {{ type = "derivation"; outPath = {json.dumps(str(self.tools / 'node'))}; meta.mainProgram = "node"; }};
              }};
            }};
          in module.home.activation.installGlobalNpmPackages.data
        '''
        return subprocess.check_output(
            ["nix", "eval", "--raw", "--impure", "--expr", expression], text=True, cwd=ROOT
        )

    def run_activation(self, *, dry_run=False, **env):
        # Home Manager runs activation with errexit and supplies run for dry runs.
        run = 'run() { printf "dry-run\\n"; };' if dry_run else 'run() { "$@"; };'
        return subprocess.run(
            ["bash", "-eu", "-o", "pipefail", "-c", run + self.activation()],
            env={**self.env, **env}, capture_output=True, text=True,
        )

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_fresh_install_and_reapply_always_run_postinstall_then_verify(self):
        for _ in range(2):
            result = self.run_activation()
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), ["bun", "postinstall", "verify"] * 2)

    def test_bun_failure_stops_before_postinstall(self):
        self.assertEqual(self.run_activation(BUN_EXIT="23").returncode, 23)
        self.assertEqual(self.calls(), ["bun"])

    def test_postinstall_failure_stops_before_verification(self):
        self.assertEqual(self.run_activation(POSTINSTALL_EXIT="24").returncode, 24)
        self.assertEqual(self.calls(), ["bun", "postinstall"])

    def test_missing_postinstall_is_an_error(self):
        (self.claude_dir / "install.cjs").unlink()
        self.assertNotEqual(self.run_activation().returncode, 0)
        self.assertEqual(self.calls(), ["bun"])

    def test_missing_native_binary_fails_even_when_postinstall_succeeds(self):
        self.assertEqual(self.run_activation(CLAUDE_EXIT="1").returncode, 1)
        self.assertEqual(self.calls(), ["bun", "postinstall", "verify"])

    def test_dry_run_does_not_execute_or_require_installed_files(self):
        (self.claude_dir / "install.cjs").unlink()
        (self.bin / "claude").unlink()
        self.assertEqual(self.run_activation(dry_run=True).returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_darwin_and_linux_use_the_same_platform_neutral_postinstall(self):
        self.assertEqual(self.activation(darwin=True), self.activation(darwin=False))


if __name__ == "__main__":
    unittest.main()
