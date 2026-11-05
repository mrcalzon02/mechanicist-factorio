#!/usr/bin/env python3
"""Fail fast unless this checkout is an isolated Factorio 2.1 Mechanicist mod."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "mechanicist-factorio_0.1.1"
EXPECTED = {
    "base",
    "elevated-rails",
    "recycler",
    "quality",
    "space-age",
}
REQUIRED = ("info.json", "settings.lua", "data.lua", "data-updates.lua", "control.lua",
            "scripts/informatron.lua", "locale/en/base.cfg",
            "locale/en/quality.cfg", "locale/en/space-age.cfg")


def main():
    info = json.loads((SOURCE / "info.json").read_text(encoding="utf-8"))
    if info["name"] != "mechanicist-factorio":
        raise SystemExit("Wrong internal mod name")
    if info["factorio_version"] != "2.1":
        raise SystemExit("Mod must explicitly target the 2.1 major Factorio version")
    if info["version"] != "0.1.1":
        raise SystemExit("Version mismatch: update source directory and verifier together")
    for relative in REQUIRED:
        if not (SOURCE / relative).is_file():
            raise SystemExit(f"Required source file missing: {relative}")
    found = set()
    for dependency in info.get("dependencies", []):
        parts = dependency.strip().split()
        if not parts:
            raise SystemExit("Empty dependency declaration")
        name = parts[1] if parts[0] in {"?", "!", "+", "~", "(?)"} else parts[0]
        if name not in EXPECTED:
            raise SystemExit(f"External dependency is prohibited in this isolated test: {name}")
        if parts[0] in {"!", "+", "~"}:
            raise SystemExit(f"Unexpected dependency modifier: {dependency}")
        if name != "base" and parts[0] != "?":
            raise SystemExit(f"Official DLC must be optional so base-only works: {name}")
        found.add(name)
    if found != EXPECTED:
        raise SystemExit(f"Official dependencies mismatch: expected {sorted(EXPECTED)}; got {sorted(found)}")
    source = (SOURCE / "data.lua").read_text(encoding="utf-8")
    executable = "\n".join(line for line in source.splitlines()
                           if not line.lstrip().startswith("--"))
    if "pcall(require" in executable or "safe_require" in executable:
        raise SystemExit("Data stage must not suppress missing-module exceptions")
    print("STATIC_PASS: isolated Mechanicist Factorio 2.1 metadata and source structure")


if __name__ == "__main__":
    main()
