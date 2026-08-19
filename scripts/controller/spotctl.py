#!/usr/bin/env python3
"""Controller CLI for SPOT workstation discovery."""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
import zipfile
from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
WINDOWS_SCRIPTS = REPO_ROOT / "scripts" / "windows"
SCHEMAS = REPO_ROOT / "schemas"
DEFAULT_EVIDENCE = Path(
    os.environ.get("SPOT_EVIDENCE_ROOT", "/home/grok-agent/spot-discovery/evidence")
)


def load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace(
        "+00:00", "Z"
    )


def sha256_file(path: Path) -> str:
    h = sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def write_checksums(run_dir: Path) -> Path:
    lines = []
    for file in sorted(run_dir.rglob("*")):
        if not file.is_file():
            continue
        if file.name == "SHA256SUMS" and file.parent.name == "hashes":
            continue
        rel = file.relative_to(run_dir).as_posix()
        lines.append(f"{sha256_file(file)}  {rel}")
    hashes = run_dir / "hashes"
    hashes.mkdir(parents=True, exist_ok=True)
    out = hashes / "SHA256SUMS"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return out


def cmd_package_evidence(args: argparse.Namespace) -> int:
    run_dir = Path(args.run_dir).expanduser().resolve()
    if not run_dir.is_dir():
        print(f"run dir not found: {run_dir}", file=sys.stderr)
        return 1
    checksum = write_checksums(run_dir)
    manifest_path = run_dir / "manifest.json"
    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    else:
        manifest = {"run_id": run_dir.name, "schema": "run-manifest/v1"}
    manifest["packaged_at"] = utc_now()
    manifest["checksum_file"] = "hashes/SHA256SUMS"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    dest_root = Path(args.evidence_root).expanduser()
    dest_root.mkdir(parents=True, exist_ok=True)
    print(f"checksums: {checksum}")
    print(f"manifest:  {manifest_path}")
    print(f"keep this directory out of git: {run_dir}")
    pointer = REPO_ROOT / "evidence" / f"{run_dir.name}.pointer.md"
    pointer.write_text(
        f"# Evidence pointer\n\n- run_id: `{run_dir.name}`\n"
        f"- path: `{run_dir}`\n- packaged_at: {manifest['packaged_at']}\n",
        encoding="utf-8",
    )
    print(f"git-safe pointer: {pointer}")
    return 0


def cmd_validate_evidence(args: argparse.Namespace) -> int:
    try:
        import jsonschema
    except ImportError:
        print("jsonschema is required", file=sys.stderr)
        return 1
    run_dir = Path(args.run_dir).expanduser().resolve()
    errors = 0
    status_schema = json.loads((SCHEMAS / "collector-status.schema.json").read_text())
    manifest_schema = json.loads((SCHEMAS / "run-manifest.schema.json").read_text())
    manifest = run_dir / "manifest.json"
    if manifest.is_file():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        try:
            jsonschema.validate(data, manifest_schema)
            print("manifest.json OK")
        except jsonschema.ValidationError as exc:
            print(f"manifest.json FAIL: {exc.message}", file=sys.stderr)
            errors += 1
    else:
        print("manifest.json missing", file=sys.stderr)
        errors += 1
    status_dir = run_dir / "status"
    if status_dir.is_dir():
        for path in sorted(status_dir.glob("*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            try:
                jsonschema.validate(data, status_schema)
                print(f"{path.name} OK")
            except jsonschema.ValidationError as exc:
                print(f"{path.name} FAIL: {exc.message}", file=sys.stderr)
                errors += 1
    return 1 if errors else 0


def _winrm_session():
    try:
        import winrm
    except ImportError as exc:
        raise SystemExit("python3-winrm is not installed") from exc
    host = os.environ.get("SPOT_WINRM_HOST")
    user = os.environ.get("SPOT_WINRM_USER")
    password = os.environ.get("SPOT_WINRM_PASSWORD")
    if not (host and user and password):
        raise SystemExit(
            "Set SPOT_WINRM_HOST, SPOT_WINRM_USER, SPOT_WINRM_PASSWORD (see .env.example)"
        )
    transport = os.environ.get("SPOT_WINRM_TRANSPORT", "ntlm")
    scheme = os.environ.get("SPOT_WINRM_SCHEME", "http")
    port = os.environ.get("SPOT_WINRM_PORT", "5985")
    endpoint = f"{scheme}://{host}:{port}/wsman"
    return winrm.Session(endpoint, auth=(user, password), transport=transport)


def cmd_verify_connectivity(_args: argparse.Namespace) -> int:
    session = _winrm_session()
    script = r"""
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
[pscustomobject]@{
  ComputerName = $env:COMPUTERNAME
  DnsHostName = $cs.DNSHostName
  Caption = $os.Caption
  Version = $os.Version
  Build = $os.BuildNumber
  User = "$env:USERDOMAIN\$env:USERNAME"
  LoggedOn = $cs.UserName
  PSVersion = $PSVersionTable.PSVersion.ToString()
} | ConvertTo-Json
"""
    result = session.run_ps(script)
    sys.stdout.write(result.std_out.decode("utf-8", errors="replace"))
    if result.std_err:
        sys.stderr.write(result.std_err.decode("utf-8", errors="replace"))
    if result.status_code != 0:
        print(f"WinRM status_code={result.status_code}", file=sys.stderr)
        return 1
    print("verify-connectivity: OK")
    return 0


def _zip_windows_scripts(dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in WINDOWS_SCRIPTS.rglob("*"):
            if path.is_file():
                zf.write(path, path.relative_to(WINDOWS_SCRIPTS).as_posix())
    return dest


def cmd_run_baseline(args: argparse.Namespace) -> int:
    session = _winrm_session()
    zip_path = Path("/tmp/spot-windows-collectors.zip")
    _zip_windows_scripts(zip_path)
    blob = base64.b64encode(zip_path.read_bytes()).decode("ascii")
    # Chunk into PowerShell here-string pieces to stay under command limits.
    chunks = [blob[i : i + 12000] for i in range(0, len(blob), 12000)]
    init = r"""
$ErrorActionPreference = 'Stop'
$base = Join-Path $env:ProgramData 'spot-discovery\staging'
New-Item -ItemType Directory -Path $base -Force | Out-Null
Remove-Item (Join-Path $base 'payload.b64') -ErrorAction SilentlyContinue
"""
    result = session.run_ps(init)
    if result.status_code != 0:
        sys.stderr.write(result.std_err.decode("utf-8", errors="replace"))
        return 1
    for chunk in chunks:
        append = (
            f"$p = Join-Path $env:ProgramData 'spot-discovery\\staging\\payload.b64'; "
            f"Add-Content -Path $p -Value '{chunk}' -Encoding ASCII"
        )
        result = session.run_ps(append)
        if result.status_code != 0:
            sys.stderr.write(result.std_err.decode("utf-8", errors="replace"))
            return 1
    finish = r"""
$ErrorActionPreference = 'Stop'
$base = Join-Path $env:ProgramData 'spot-discovery\staging'
$b64 = Get-Content (Join-Path $base 'payload.b64') -Raw
$zip = Join-Path $base 'collectors.zip'
$out = Join-Path $base 'windows'
[IO.File]::WriteAllBytes($zip, [Convert]::FromBase64String($b64.Trim()))
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Path $out -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $out)
$invoke = Join-Path $out 'Invoke-Discovery.ps1'
& $invoke -Profile baseline
"""
    result = session.run_ps(finish)
    sys.stdout.write(result.std_out.decode("utf-8", errors="replace"))
    if result.std_err:
        sys.stderr.write(result.std_err.decode("utf-8", errors="replace"))
    return 0 if result.status_code == 0 else 1


def cmd_collect_run(_args: argparse.Namespace) -> int:
    session = _winrm_session()
    script = r"""
$runs = Join-Path $env:ProgramData 'spot-discovery\runs'
if (-not (Test-Path $runs)) { Write-Output 'NO_RUNS'; exit 1 }
Get-ChildItem $runs -Directory | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
"""
    result = session.run_ps(script)
    remote = result.std_out.decode("utf-8", errors="replace").strip()
    if not remote or remote == "NO_RUNS":
        print("no remote runs found", file=sys.stderr)
        return 1
    print(f"latest remote run: {remote}")
    print("Copy this folder to the controller with USB/SMB, then:")
    print(f"  python3 scripts/controller/spotctl.py package-evidence --run-dir <local-copy>")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="spotctl")
    sub = p.add_subparsers(dest="cmd", required=True)

    sub.add_parser("verify-connectivity", help="WinRM identity probe")

    b = sub.add_parser("run-baseline", help="Copy collectors over WinRM and run Level A")
    b.add_argument("--profile", default="baseline")

    sub.add_parser("collect-run", help="Print latest remote run path")

    pk = sub.add_parser("package-evidence", help="Checksum a local run directory")
    pk.add_argument("--run-dir", required=True)
    pk.add_argument("--evidence-root", default=str(DEFAULT_EVIDENCE))

    v = sub.add_parser("validate-evidence", help="JSON-schema check a run directory")
    v.add_argument("--run-dir", required=True)

    return p


def main(argv: list[str] | None = None) -> int:
    load_dotenv(REPO_ROOT / ".env")
    args = build_parser().parse_args(argv)
    commands = {
        "verify-connectivity": cmd_verify_connectivity,
        "run-baseline": cmd_run_baseline,
        "collect-run": cmd_collect_run,
        "package-evidence": cmd_package_evidence,
        "validate-evidence": cmd_validate_evidence,
    }
    return commands[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
