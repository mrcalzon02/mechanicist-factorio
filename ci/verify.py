#!/usr/bin/env python3
"""Validate the Factorio 2.1 Mechanicist source and its Space Age localization."""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "mechanicist-factorio_0.1.3"
EXPECTED = {"base", "elevated-rails", "recycler", "quality", "space-age"}
REQUIRED = (
    "info.json", "settings.lua", "data.lua", "data-updates.lua", "control.lua",
    "scripts/informatron.lua", "scripts/space_age_description_keys.lua",
    "locale/en/base.cfg", "locale/en/quality.cfg", "locale/en/space-age.cfg"
)


def main():
    info = json.loads((SOURCE / "info.json").read_text(encoding="utf-8"))
    if (info["name"], info["version"], info["factorio_version"]) != (
            "mechanicist-factorio", "0.1.3", "2.1"):
        raise SystemExit("Mod name/version/Factorio target must match the 0.1.3 release")
    if SOURCE.name != info["name"] + "_" + info["version"]:
        raise SystemExit("Source directory version mismatch")
    for name in REQUIRED:
        if not (SOURCE / name).is_file():
            raise SystemExit(f"Missing required mod file: {name}")
    found = set()
    for dependency in info.get("dependencies", []):
        parts = dependency.strip().split()
        if not parts:
            raise SystemExit("Empty mod dependency declaration")
        name = parts[1] if parts[0] in {"?", "!", "+", "~", "(?)"} else parts[0]
        if name not in EXPECTED:
            raise SystemExit(f"Forbidden non-official dependency: {name}")
        if parts[0] in {"!", "+", "~"}:
            raise SystemExit(f"Prohibited dependency modifier: {dependency}")
        if name != "base" and parts[0] != "?":
            raise SystemExit(f"Official DLC must remain optional: {name}")
        found.add(name)
    if found != EXPECTED:
        raise SystemExit(f"Unexpected official dependency list: {found}")

    data_lua = (SOURCE / "data.lua").read_text(encoding="utf-8")
    executable = "\n".join(line for line in data_lua.splitlines()
                           if not line.lstrip().startswith("--"))
    if "pcall(require" in executable or "safe_require" in executable:
        raise SystemExit("Data stage must not hide module-load errors")

    # The generated manifest must contain exactly the available Space Age
    # description keys, preventing unknown localization keys in the game UI.
    locale = (SOURCE / "locale/en/space-age.cfg").read_text(encoding="utf-8")
    known = set()
    section = ""
    for line in locale.splitlines():
        line = line.strip()
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
        elif (section.startswith("mechanicist-space-age.")
              and section.endswith("-description")
              and line and not line.startswith("#") and "=" in line):
            known.add(section.split(".", 1)[1] + "." + line.split("=", 1)[0].strip())

    manifest = (SOURCE / "scripts/space_age_description_keys.lua").read_text(encoding="utf-8")
    recorded = set()
    section = None
    for line in manifest.splitlines():
        line = line.strip()
        if line.startswith('["') and line.endswith('"] = {'):
            section = line.split('"')[1]
        elif section and line.startswith('["') and line.endswith('"] = true,'):
            recorded.add(section + "." + line.split('"')[1])
        elif line == "},":
            section = None
    if recorded != known:
        raise SystemExit(f"Space Age locale manifest out of sync: "
                         f"{len(known - recorded)} missing, {len(recorded - known)} unexpected")
    data_updates = (SOURCE / "data-updates.lua").read_text(encoding="utf-8")
    if "space_age_description_keys[description_section][name]" not in data_updates:
        raise SystemExit("Data stage must guard optional Space Age descriptions")
    subprocess.run([sys.executable, str(ROOT / "ci/audit_locale.py")],
                   cwd=ROOT, check=True)
    print("STATIC_PASS: Mechanicist 0.1.3 / Factorio 2.1 / locale keys")


if __name__ == "__main__":
    main()
