#!/usr/bin/env python3
"""Exercise Mechanicist in clean Factorio 2.1 headless create, ticks and server."""
import argparse
import json
import re
import shutil
import zipfile
import subprocess
import sys
import time
import struct
from pathlib import Path

OFFICIAL = ("base", "elevated-rails", "recycler", "quality", "space-age")
ALLOWED = set(OFFICIAL) | {"core", "mechanicist-factorio", "settings"}  # engine settings phase
MODES = {
    # Enable the in-game assertions for every mode; the ZIP itself is unchanged.
    "base-standard": (set(), {}),
    "base-heresy": (set(), {"mechanicist-factorio-language-intensity": "heresy"}),
    "base-off": (set(), {"mechanicist-factorio-language-intensity": "off",
                        "mechanicist-factorio-rename-vanilla": False}),
    "elevated-rails": ({"elevated-rails"}, {}),
    "quality-on": ({"recycler", "quality"}, {}),
    "quality-off": ({"recycler", "quality"}, {"mechanicist-factorio-rename-quality": False}),
    "space-age-full": ({"elevated-rails", "recycler", "quality", "space-age"}, {}),
    "space-age-off": ({"elevated-rails", "recycler", "quality", "space-age"},
                      {"mechanicist-factorio-rename-space-age": False}),
}

FATAL = re.compile(
    r"(?im)^(?:\s*\d+(?:\.\d+)?\s+)?Error\b|"
    r"Error while loading|Failed to load|Error while running|stack traceback"
)
LOAD = re.compile(r"\bLoading mod ([A-Za-z0-9_-]+)\s")


def read_log(path):
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def findings_in(log):
    return [line.strip()[:500] for line in log.splitlines()
            if FATAL.search(line)][:30]


def run_command(args, logfile, seconds):
    with logfile.open("w", encoding="utf-8") as target:
        try:
            result = subprocess.run(args, stdout=target, stderr=subprocess.STDOUT,
                                    timeout=seconds, check=False)
            return result.returncode
        except subprocess.TimeoutExpired:
            target.write(f"\nCI_TIMEOUT after {seconds}s\n")
            return 124


def server_smoke(binary, mods, save, settings, logfile):
    args = [str(binary), "--mod-directory", str(mods),
            "--start-server", str(save), "--server-settings", str(settings)]
    with logfile.open("w", encoding="utf-8") as output:
        proc = subprocess.Popen(args, stdout=output, stderr=subprocess.STDOUT,
                                stdin=subprocess.PIPE)
        try:
            deadline = time.monotonic() + 75
            hosted = False
            while time.monotonic() < deadline:
                if "Hosting game at" in read_log(logfile):
                    hosted = True
                    break
                if proc.poll() is not None:
                    break
                time.sleep(1)
            if hosted and proc.poll() is None:
                time.sleep(5)
            return hosted and proc.poll() is None
        finally:
            if proc.poll() is None:
                proc.terminate()
                try:
                    proc.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait(timeout=5)



def write_mod_settings(path, extra):
    """Write Factorio 2.1 mod-settings.dat using the official PropertyTree format.

    This lets the *unmodified release ZIP* run with different startup settings.
    Format: 4 little-endian uint16 version fields, one false flag, then tree.
    """
    def string(value):
        encoded = value.encode("utf-8")
        return b"\x00" + (bytes((len(encoded),)) if len(encoded) < 255
                          else b"\xff" + struct.pack("<I", len(encoded))) + encoded

    def tree(value):
        if isinstance(value, bool):
            return b"\x01\x00" + bytes((1 if value else 0,))
        if isinstance(value, str):
            return b"\x03\x00" + string(value)
        if isinstance(value, dict):
            data = b"\x05\x00" + struct.pack("<I", len(value))
            return data + b"".join(string(key) + tree(val) for key, val in value.items())
        raise TypeError(f"Unsupported mod settings value: {value!r}")

    startup = {"mechanicist-factorio-debug-locale-audit": {"value": True}}
    startup.update({name: {"value": val} for name, val in extra.items()})
    payload = {"startup": startup, "runtime-global": {}, "runtime-per-user": {}}
    path.write_bytes(struct.pack("<4H", 2, 1, 24, 0) + b"\x00" + tree(payload))


def check_mode(binary, package, work, artifacts, mode, enabled, options):
    folder = work / mode
    mods = folder / "mods"
    mods.mkdir(parents=True, exist_ok=True)
    shutil.copy2(package, mods / package.name)
    entries = [{"name": "base", "enabled": True},
               {"name": "mechanicist-factorio", "enabled": True}]
    entries.extend({"name": name, "enabled": name in enabled}
                   for name in OFFICIAL if name != "base")
    (mods / "mod-list.json").write_text(json.dumps({"mods": entries}, indent=2),
                                        encoding="utf-8")
    write_mod_settings(mods / "mod-settings.dat", options)
    report = {"mode": mode, "enabled_official": sorted(enabled | {"base"}),
              "settings": options, "stages": {}, "errors": []}
    save = folder / "smoke.zip"
    create = artifacts / f"{mode}-create.log"
    bench = artifacts / f"{mode}-benchmark.log"
    server = artifacts / f"{mode}-server.log"
    prefix = [str(binary), "--mod-directory", str(mods)]
    code = run_command(prefix + ["--create", str(save), "--map-gen-seed", "907260"],
                       create, 240)
    raw = read_log(create)
    loaded = set(LOAD.findall(raw))
    expected = enabled | {"base", "mechanicist-factorio"}
    unexpected = loaded - ALLOWED
    missing = expected - loaded
    report["stages"]["create"] = code == 0 and save.is_file() and not missing and not unexpected
    report["errors"] += findings_in(raw)
    if "LOCALE_AUDIT_PASS" not in raw:
        report["stages"]["create"] = False
        report["errors"].append("In-engine locale assertions did not execute/pass")
    if code != 0:
        report["errors"].append(f"Create exited {code}")
    if missing:
        report["errors"].append(f"Expected loaded mods absent from engine log: {sorted(missing)}")
    if unexpected:
        report["errors"].append(f"Unexpected non-official mods loaded: {sorted(unexpected)}")
    if not save.is_file():
        report["errors"].append("Headless engine did not create the save")
    print(f"{mode} create={report['stages']['create']} loaded={sorted(loaded)}", flush=True)
    if report["stages"]["create"] and not report["errors"]:
        code = run_command(prefix + ["--benchmark", str(save), "--benchmark-ticks", "1200"],
                           bench, 300)
        raw = read_log(bench)
        report["stages"]["benchmark"] = code == 0 and not findings_in(raw)
        report["errors"] += findings_in(raw)
        if code != 0:
            report["errors"].append(f"Benchmark exited {code}")
        if not report["stages"]["benchmark"]:
            report["errors"].append("1200-tick simulation did not pass")
        print(f"{mode} benchmark={report['stages']['benchmark']}", flush=True)
    if report["stages"].get("benchmark", False):
        settings = folder / "server-settings.json"
        settings.write_text(json.dumps({
            "name": "Mechanicist Factorio CI",
            "description": "Private temporary isolated Factorio 2.1 headless test",
            "max_players": 1,
            "visibility": {"public": False, "lan": False},
            "require_user_verification": False,
            "auto_pause": False,
            "autosave_interval": 10,
            "autosave_slots": 2
        }), encoding="utf-8")
        try:
            report["stages"]["dedicated-server"] = server_smoke(binary, mods, save, settings, server)
        except Exception as exc:
            report["stages"]["dedicated-server"] = False
            report["errors"].append(f"Server launch error: {exc}")
        report["errors"] += findings_in(read_log(server))
        if not report["stages"]["dedicated-server"]:
            report["errors"].append("Private dedicated server never reached 'Hosting game at'")
        print(f"{mode} server={report['stages']['dedicated-server']}", flush=True)
    report["passed"] = (all(report["stages"].get(name, False)
                            for name in ("create", "benchmark", "dedicated-server"))
                        and not report["errors"])
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", required=True, type=Path)
    parser.add_argument("--package", required=True, type=Path)
    parser.add_argument("--work", required=True, type=Path)
    parser.add_argument("--artifacts", required=True, type=Path)
    args = parser.parse_args()
    if not args.package.is_file() or not zipfile.is_zipfile(args.package):
        raise SystemExit("Packaged mod ZIP missing or invalid")
    with zipfile.ZipFile(args.package) as archive:
        roots = {p.split("/", 1)[0] for p in archive.namelist()}
        if len(roots) != 1:
            raise SystemExit("Package must have exactly one versioned top-level directory")
        root = next(iter(roots))
        info = json.loads(archive.read(root + "/info.json"))
        if root != f"{info['name']}_{info['version']}" or args.package.name != root + ".zip":
            raise SystemExit("Mod package ZIP root/name/version mismatch")
    args.artifacts.mkdir(parents=True, exist_ok=True)
    args.work.mkdir(parents=True, exist_ok=True)
    reports = []
    try:
        for mode, (enabled, options) in MODES.items():
            try:
                reports.append(check_mode(args.binary, args.package, args.work,
                                          args.artifacts, mode, enabled, options))
            except Exception as exc:
                reports.append({"mode": mode, "passed": False,
                                "stages": {}, "errors": [f"Unhandled CI stage exception: {exc}"]})
    finally:
        (args.artifacts / "result.json").write_text(json.dumps(reports, indent=2) + "\n",
                                                      encoding="utf-8")
        lines = ["# Mechanicist Factorio — isolated 2.1 headless compatibility",
                 "", "Only Mechanicist and official Factorio mods were installed.",
                 "", "| Configuration | Create/load | 1200 ticks | Private server | Result |",
                 "| --- | --- | --- | --- | --- |"]
        for result in reports:
            stages = result["stages"]
            status = lambda stage: "PASS" if stages.get(stage) else "FAIL / not reached"
            lines.append(f"| {result['mode']} | {status('create')} | {status('benchmark')} | "
                         f"{status('dedicated-server')} | {'PASS' if result['passed'] else 'FAIL'} |")
        lines.extend(["", "## Errors (see full stage logs in artifacts)", ""])
        for result in reports:
            for item in result["errors"]:
                lines.append(f"- **{result['mode']}:** {item}")
        if not any(result["errors"] for result in reports):
            lines.append("- No engine errors detected.")
        (args.artifacts / "summary.md").write_text("\n".join(lines) + "\n",
                                                     encoding="utf-8")
    print((args.artifacts / "summary.md").read_text(encoding="utf-8"))
    return 0 if len(reports) == len(MODES) and all(r["passed"] for r in reports) else 1


if __name__ == "__main__":
    sys.exit(main())
