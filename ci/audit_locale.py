#!/usr/bin/env python3
"""Release-blocking coverage audit for all packaged English locale references.

This checks the actual Factorio locale .cfg structure, source name lists,
Informatron page keys and conditional Quality / Space Age mappings.
"""
from __future__ import annotations
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "mechanicist-factorio_0.1.3"
FILES = {
    "base": MOD / "locale/en/base.cfg",
    "quality": MOD / "locale/en/quality.cfg",
    "space_age": MOD / "locale/en/space-age.cfg",
}


def parse_cfg(path: Path):
    section = ""
    result = {}
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#") or line.startswith(";"):
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if "=" not in line:
            raise AssertionError(f"{path}:{lineno}: invalid line {line[:100]!r}")
        key, value = line.split("=", 1)
        if not key or not value or key != key.strip():
            raise AssertionError(f"{path}:{lineno}: invalid/empty key or value")
        full = f"{section}.{key}" if section else key
        if full in result:
            raise AssertionError(f"{path}:{lineno}: duplicate {full}")
        result[full] = value
    return result


def listed_names(text, variable):
    match = re.search(r"local\s+" + re.escape(variable) + r"\s*=\s*\{(.*?)\n\}", text, re.S)
    if not match:
        raise AssertionError(f"Missing Lua name list: {variable}")
    return re.findall(r'"([^"]+)"', match.group(1))


def assert_key(keys, key, errors, from_where):
    if key not in keys:
        errors.append(f"{from_where} missing {key}")


def main():
    locale = {}
    per_file = {}
    for file, path in FILES.items():
        parsed = parse_cfg(path)
        per_file[file] = len(parsed)
        for key, value in parsed.items():
            if key in locale:
                raise AssertionError(f"Cross-file duplicate locale key: {key}")
            locale[key] = value

    lua = (MOD / "data-updates.lua").read_text(encoding="utf-8")
    informatron = (MOD / "scripts/informatron.lua").read_text(encoding="utf-8")
    settings = (MOD / "settings.lua").read_text(encoding="utf-8")
    errors = []

    category_lists = {
        "vanilla_entities": "entity", "vanilla_items": "item",
        "vanilla_fluids": "fluid", "vanilla_recipes": "recipe",
        "vanilla_technologies": "technology",
    }
    base_references = 0
    for variable, cat in category_lists.items():
        for name in listed_names(lua, variable):
            for intensity in ("standard", "heresy"):
                for suffix in ("name", "description"):
                    key = f"mechanicist-{intensity}.{cat}-{suffix}.{name}"
                    assert_key(locale, key, errors, variable)
                    base_references += 1

    quality_re = re.compile(
        r'\{proto_type = "([^"]+)", category = "([^"]+)",\s*'
        r'(descriptions = true,\s*)?names = \{([^}]+)\}\}',
        re.S,
    )
    quality_references = 0
    quality_specs = quality_re.findall(lua)
    if len(quality_specs) != 6:
        raise AssertionError(f"Expected 6 explicit Quality category mappings; got {len(quality_specs)}")
    for proto_type, cat, desc, names in quality_specs:
        for name in re.findall(r'"([^"]+)"', names):
            assert_key(locale, f"mechanicist-quality.{cat}.{name}", errors, proto_type)
            quality_references += 1
            if desc:
                dc = cat.replace("-name", "-description")
                assert_key(locale, f"mechanicist-quality.{dc}.{name}", errors, proto_type)
                quality_references += 1

    sa_re = re.compile(
        r'\{\s*name_section\s*=\s*"([^"]+)"\s*,\s*'
        r'description_section\s*=\s*(?:"([^"]+)"|nil)\s*,\s*'
        r'names\s*=\s*\{([\s\S]*?)\}\s*\}',
    )
    sa_references = 0
    sets = list(sa_re.finditer(lua))
    if len(sets) < 14:
        raise AssertionError(f"Missing Space Age name sets: found {len(sets)}")
    desc_required = set()
    for match in sets:
        name_section, description_section, names = match.groups()
        for name in re.findall(r'"([^"]+)"', names):
            assert_key(locale, f"mechanicist-space-age.{name_section}.{name}", errors, name_section)
            sa_references += 1
            if description_section:
                k = f"mechanicist-space-age.{description_section}.{name}"
                if k in locale:
                    desc_required.add(description_section + "." + name)

    manifest = (MOD / "scripts/space_age_description_keys.lua").read_text(encoding="utf-8")
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
    # All emitted Space Age prototype descriptions must have a guarded key.
    missing_guard = desc_required - recorded
    if missing_guard:
        errors += [f"Space Age description missing guard {s}" for s in sorted(missing_guard)]
    expected_guard = set()
    for key in locale:
        if key.startswith("mechanicist-space-age.") and "-description." in key:
            expected_guard.add(key.split("mechanicist-space-age.", 1)[1])
    if recorded != expected_guard:
        errors.append(f"Space Age description manifest mismatch: "
                      f"{len(expected_guard-recorded)} missing, {len(recorded-expected_guard)} extra")

    info_re = re.compile(r'interface = "([^"]+)",\s+locale = "([^"]+)",'
                         r'([\s\S]*?)text_counts = \{([\s\S]*?)\}\s*\}')
    informatron_refs = 0
    interfaces = list(info_re.finditer(informatron))
    if len(interfaces) != 4:
        raise AssertionError(f"Expected 4 optional Informatron interfaces; got {len(interfaces)}")
    for match in interfaces:
        interface, prefix, _, counts = match.groups()
        for page, count in re.findall(r'\["([^"]+)"\]\s*=\s*(\d+)', counts):
            for kind in ("menu", "title"):
                assert_key(locale, f"{prefix}.{kind}_{page}", errors, interface)
                informatron_refs += 1
            for number in range(1, int(count)+1):
                assert_key(locale, f"{prefix}.page_{page}_text_{number}", errors, interface)
                informatron_refs += 1

    setting_refs = 0
    for suffix in re.findall(r'setting_name\("([^"]+)"\)', settings):
        for kind in ("mod-setting-name", "mod-setting-description"):
            assert_key(locale, f"{kind}.mechanicist-factorio-{suffix}", errors, "settings")
            setting_refs += 1

    for pattern in ("locale_type_matches(prototype_type, name_section)",
                    'startup_value("rename-quality", true)',
                    "LOCALE_AUDIT_PASS"):
        if pattern not in lua:
            errors.append("Missing safety mechanism: " + pattern)
    if "clear_space_age_locale()" in lua or re.search(r"^\s+clear_vanilla_locale\(\)", lua, re.M):
        errors.append("Disabled retheme still clears original prototype localization")

    if errors:
        raise SystemExit("LOCALE_AUDIT_FAIL:\n" + "\n".join(errors[:150]))
    print("LOCALE_STATIC_PASS: "
          f"{len(locale)} unique English keys, packages={json.dumps(per_file)}, "
          f"{base_references} base refs, {quality_references} Quality refs, "
          f"{sa_references} Space Age refs, {informatron_refs} Informatron refs, "
          f"{setting_refs} settings refs; missing=0")


if __name__ == "__main__":
    main()
