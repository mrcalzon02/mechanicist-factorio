#!/usr/bin/env python3
"""Upload a tested GitHub-release ZIP to the existing Factorio Mod Portal page.

Requires the repository Actions secret FACTORIO_MOD_UPLOAD_KEY with the
"ModPortal: Upload Mods" permission. Never supplies that key to the upload URL.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import secrets
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import zipfile


PORTAL = "https://mods.factorio.com"
TIMEOUT = 35


def request_json(url, *, post=None, headers=None):
    request = urllib.request.Request(
        url, data=post, headers={"User-Agent": "Mechanicist-Factorio-Release/1", **(headers or {})})
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            raw = response.read()
    except urllib.error.HTTPError as exc:
        body = exc.read(2048).decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from Factorio portal: {body}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Factorio portal network error: {exc.reason}") from exc
    try:
        result = json.loads(raw)
    except ValueError as exc:
        raise RuntimeError("Factorio portal response is not valid JSON") from exc
    if not isinstance(result, dict):
        raise RuntimeError("Unexpected Factorio portal response type")
    return result


def portal_release(mod, version):
    url = f"{PORTAL}/api/mods/{urllib.parse.quote(mod, safe='')}/full"
    result = request_json(url)
    return next(
        (release for release in result.get("releases", [])
         if release.get("version") == version), None)


def validate_zip(path, mod, version):
    if not path.is_file():
        raise RuntimeError(f"Release asset absent: {path}")
    if not zipfile.is_zipfile(path):
        raise RuntimeError("GitHub release asset is not a valid Factorio ZIP")
    root = f"{mod}_{version}"
    if path.name != root + ".zip":
        raise RuntimeError(f"Incorrect release filename: {path.name!r}")
    with zipfile.ZipFile(path) as archive:
        entries = archive.namelist()
        if not entries or any(not x.startswith(root + "/") for x in entries):
            raise RuntimeError("Archive does not contain only the versioned mod folder")
        info = json.loads(archive.read(root + "/info.json"))
        if (info.get("name"), info.get("version"), info.get("factorio_version")) != (
                mod, version, "2.1"):
            raise RuntimeError("Release metadata/version is not the expected Factorio 2.1 build")
        if archive.testzip() is not None:
            raise RuntimeError("CRC failure in release asset")
    return hashlib.sha1(path.read_bytes()).hexdigest()


def upload(mod, path, token):
    # Factorio's documented two-step API for existing mods.
    init_url = PORTAL + "/api/v2/mods/releases/init_upload"
    response = request_json(
        init_url,
        post=urllib.parse.urlencode({"mod": mod}).encode("ascii"),
        headers={
            "Authorization": "Bearer " + token,
            "Content-Type": "application/x-www-form-urlencoded",
        })
    upload_url = response.get("upload_url")
    if not isinstance(upload_url, str):
        raise RuntimeError(
            "Factorio init_upload did not return an upload URL: "
            + str(response.get("error", "unknown")) + " "
            + str(response.get("message", "")))
    parsed = urllib.parse.urlparse(upload_url)
    if parsed.scheme != "https" or not parsed.netloc:
        raise RuntimeError("Refusing non-HTTPS Factorio upload URL")
    # The one-time upload URL is not logged, as it may contain private parameters.
    boundary = "----MechanicistFactorio" + secrets.token_hex(12)
    payload = path.read_bytes()
    body = (
        ("--" + boundary + "\r\n"
         'Content-Disposition: form-data; name="file"; filename="' + path.name + '"\r\n'
         "Content-Type: application/zip\r\n\r\n").encode("utf-8")
        + payload + ("\r\n--" + boundary + "--\r\n").encode("ascii"))
    result = request_json(
        upload_url,
        post=body,
        headers={"Content-Type": "multipart/form-data; boundary=" + boundary})
    if result.get("success") is not True:
        raise RuntimeError(
            "Factorio finish_upload rejected the ZIP: "
            + str(result.get("error", "unknown")) + " "
            + str(result.get("message", "")))
    print("PORTAL_UPLOAD_ACCEPTED: Factorio API accepted the release", flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mod", default="mechanicist-factorio")
    parser.add_argument("--version", default="0.1.2")
    parser.add_argument("--zip", dest="archive", type=Path, required=True)
    args = parser.parse_args()
    sha1 = validate_zip(args.archive, args.mod, args.version)
    print(f"Verified Factorio release archive {args.archive.name} SHA1={sha1}", flush=True)

    existing = portal_release(args.mod, args.version)
    if existing:
        if existing.get("sha1", "").lower() != sha1:
            raise SystemExit(
                "PORTAL_VERSION_CONFLICT: this version already exists with different bytes; "
                "never overwrite/retag an existing version")
        print(f"PORTAL_RELEASE_VERIFIED: {args.mod} {args.version} already published with identical SHA1")
        return 0

    token = os.environ.get("FACTORIO_MOD_UPLOAD_KEY", "").strip()
    if not token:
        raise SystemExit(
            "PORTAL_UPLOAD_BLOCKED: GitHub Actions repository secret "
            "FACTORIO_MOD_UPLOAD_KEY is missing. Add a Factorio API key with "
            "'ModPortal: Upload Mods' permission to this repository's Actions secrets.")
    upload(args.mod, args.archive, token)

    # Bounded, non-busy readback: requires the release's public SHA1 to match.
    for delay in [0, 2, 4, 8, 12]:
        if delay:
            time.sleep(delay)
        try:
            published = portal_release(args.mod, args.version)
        except RuntimeError:
            published = None
        if published:
            if published.get("sha1", "").lower() != sha1:
                raise SystemExit("PORTAL_READBACK_MISMATCH: published SHA1 differs from release ZIP")
            print(
                f"PORTAL_RELEASE_VERIFIED: {args.mod} {args.version} "
                f"live on {PORTAL}/mod/{args.mod}",
                flush=True)
            return 0
    raise SystemExit(
        "PORTAL_READBACK_PENDING: upload was accepted but public API readback could not "
        "confirm the new version yet. Inspect the mod page before retrying.")


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, KeyError, ValueError, zipfile.BadZipFile) as exc:
        raise SystemExit(f"PORTAL_RELEASE_FAILED: {exc}") from exc
