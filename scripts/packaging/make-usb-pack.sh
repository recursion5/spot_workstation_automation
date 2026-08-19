#!/usr/bin/env bash
# Build a zip the operator can copy to the specimen over USB/SMB.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
out="${1:-/tmp/spot-discovery-usb.zip}"
rm -f "$out"
python3 - <<PY
import zipfile
from pathlib import Path
root = Path("$root")
out = Path("$out")
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
    for rel in [
        "README.md",
        "docs/RUNBOOK.md",
        "scripts/windows",
    ]:
        path = root / rel
        if path.is_file():
            zf.write(path, rel)
        else:
            for f in path.rglob("*"):
                if f.is_file():
                    zf.write(f, f.relative_to(root).as_posix())
print(out)
PY
echo "Copy this zip to the POS PC. Extract, then elevated PowerShell:"
echo "  .\\scripts\\windows\\Bootstrap-WinRM.ps1 -ControllerCidr '10.0.253.225/32'"
echo "  .\\scripts\\windows\\Invoke-Discovery.ps1 -Profile baseline"
