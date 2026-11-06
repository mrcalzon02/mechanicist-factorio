#!/usr/bin/env python3
"""Fail fast unless this checkout is an isolated Factorio 2.1 Mechanicist mod."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "mechanicist-factorio_0.1.2"
EXPECTED = {
    "base",
    "elevated-rails",
    "recycler",
    "quality",
    "space-age",
}
REQUIRED = ("info.json", "settings.lua", "data.lua", "data-updates.lua", "control.lua",
            "scripts/informatron.lua", "scripts/space_age_description_keys.lua", "locale/en/base.cfg",
            "locale/en/quality.cfg", "locale/en/space-age.cfg")


def main():
    info = json.loads((SOURCE / "info.json").read_text(encoding="utf-8"))
    if info["name"] != "mechanicist-factorio":
        raise SystemExit("Wrong internal mod name")
    if info["factorio_version"] != "2.1":
        raise SystemExit("Mod must explicitly target the 2.1 major Factorio version")
    if info["version"] != "0.1.2":
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
    # Confirm the data-stage description whitelist agrees with actual locale keys.
    import re
    cfg = (SOURCE / "locale/en/space-age.cfg").read_text(encoding="utf-8")
    manifest = (SOURCE / "scripts/space_age_description_keys.lua").read_text(encoding="utf-8")
    expected = set()
    section = ""
    for line in cfg.splitlines():
        line = line.strip()
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
        elif (section.startswith("mechanicist-space-age.")
              and section.endswith("-description")
              and line and not line.startswith("#") and "=" in line):
            expected.add(section[len("mechanicist-space-age."):] + "." +
                         line.split("=", 1)[0].strip())
    observed = set()
    current_section = None
    for line in manifest.splitlines():
        outer = re.search(r'^\\s*\\["([^"]+)"\\] = \\{


if __name__ == "__main__":
    main()
, line)
        inner = re.search(r'^\\s*\\["([^"]+)"\\] = true,?


if __name__ == "__main__":
    main()
, line)
        if outer:
            current_section = outer.group(1)
        elif inner and current_section:
            observed.add(current_section + "." + inner.group(1))
        elif line.strip() == "},":
            current_section = None
    if expected != observed:
        raise SystemExit("Space Age description manifest is out of sync with locale/en/space-age.cfg")
    if "space_age_description_keys[description_section][name]" not in (
            SOURCE / "data-updates.lua").read_text(encoding="utf-8"):
        raise SystemExit("Space Age description overrides lost their locale-key guard")
    print("STATIC_PASS: isolated 2.1 metadata, source and Space Age localization guard")


if __name__ == "__main__":
    main()
