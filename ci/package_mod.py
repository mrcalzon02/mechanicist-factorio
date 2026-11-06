#!/usr/bin/env python3
"""Build an installable reproducible Factorio mod archive from the versioned source."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    source = args.source.resolve(strict=True)
    metadata = json.loads((source / "info.json").read_text(encoding="utf-8"))
    folder = f"{metadata['name']}_{metadata['version']}"
    if folder != source.name:
        raise SystemExit(f"Source folder {source.name!r} != info.json expected {folder!r}")
    if metadata["factorio_version"] != "2.1":
        raise SystemExit("Refusing to package a mod not targeting Factorio 2.1")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    output = args.output_dir / f"{folder}.zip"
    input_files = sorted(path for path in source.rglob("*") if path.is_file())
    if not input_files:
        raise SystemExit("No source files in mod package")
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED,
                         compresslevel=9, strict_timestamps=True) as archive:
        for path in input_files:
            if path.is_symlink() or "__pycache__" in path.parts:
                raise SystemExit(f"Invalid packaged source: {path}")
            member = f"{folder}/{path.relative_to(source).as_posix()}"
            info = zipfile.ZipInfo(member, date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED,
                             compresslevel=9)
    with zipfile.ZipFile(output) as archive:
        if archive.testzip() is not None:
            raise SystemExit("Archive ZIP CRC failure")
        actual = set(archive.namelist())
        expected = {f"{folder}/{p.relative_to(source).as_posix()}" for p in input_files}
        if actual != expected:
            raise SystemExit("ZIP file list does not exactly match the source tree")
        for path in input_files:
            if archive.read(f"{folder}/{path.relative_to(source).as_posix()}") != path.read_bytes():
                raise SystemExit(f"ZIP content differs from original: {path}")
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    (args.output_dir / (output.name + ".sha256")).write_text(
        f"{digest}  {output.name}\n", encoding="ascii")
    print(f"PACKAGE_PASS: {output} ({output.stat().st_size} bytes), SHA-256 {digest}")


if __name__ == "__main__":
    main()
