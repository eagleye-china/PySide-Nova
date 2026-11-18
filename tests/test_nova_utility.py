import subprocess
import sys


def test_utility_classes_contract():
    result = subprocess.run(
        [sys.executable, "tools/check_utility_classes.py"],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, f"Contract test failed:\n{result.stdout}\n{result.stderr}"
