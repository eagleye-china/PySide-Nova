import re
import sys
from pathlib import Path

KNOWN_CLASSES = {
    "bg-primary", "bg-secondary", "bg-positive", "bg-negative", "bg-warning",
    "bg-info", "bg-dark", "bg-white", "bg-background", "bg-surface",
    "text-white", "text-primary", "text-secondary", "text-positive",
    "text-negative", "text-warning", "text-dark", "text-muted", "text-disabled",
    "elevation-1", "elevation-2", "elevation-3", "elevation-4", "elevation-5",
    "rounded-none", "rounded-sm", "rounded-md", "rounded-lg", "rounded-pill",
}


def check_qml_files(directory: str) -> list[str]:
    errors = []
    for qml_file in Path(directory).rglob("*.qml"):
        content = qml_file.read_text(encoding="utf-8")
        matches = re.findall(r'utilityClasses\s*:\s*["\']([^"\']+)["\']', content)
        for match in matches:
            classes = match.split()
            for cls in classes:
                if cls not in KNOWN_CLASSES:
                    errors.append(f"{qml_file.name}: unknown class '{cls}'")
    return errors


if __name__ == "__main__":
    errors = check_qml_files("src/pyside_nova/qml/Nova")
    if errors:
        print("Utility class check FAILED:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    print("Utility class check PASSED.")
