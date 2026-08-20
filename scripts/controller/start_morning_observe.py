#!/usr/bin/env python3
"""Start a low-overhead daytime observer on Zenith WS1 and WS2."""

from __future__ import annotations

import os
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "scripts" / "controller"))

WATCHER = r"""
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
$stamp = [DateTime]::UtcNow.ToString('yyyyMMdd')
$dir = Join-Path $env:ProgramData "spot-discovery\observe\$stamp"
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$out = Join-Path $dir 'process-events.jsonl'
function Write-Evt($o) {
    Add-Content -Path $out -Value ($o | ConvertTo-Json -Compress -Depth 4) -Encoding UTF8
}
Write-Evt @{ t = [DateTime]::UtcNow.ToString('o'); event = 'observe-start'; computer = $env:COMPUTERNAME }
try {
    Register-CimIndicationEvent -ClassName Win32_ProcessStartTrace -SourceIdentifier SpotMorningStart -Action {
        $e = $Event.SourceEventArgs.NewEvent
        $line = (@{ t=[DateTime]::UtcNow.ToString('o'); event='start'; process=$e.ProcessName; pid=$e.ProcessId; parent=$e.ParentProcessId } | ConvertTo-Json -Compress)
        Add-Content -Path $using:out -Value $line -Encoding UTF8
    } | Out-Null
} catch {}
while ($true) {
    Start-Sleep -Seconds 60
    $snap = Join-Path $dir ('snapshot-' + [DateTime]::UtcNow.ToString('HHmmss') + '.txt')
    $names = Get-Process | Select-Object -ExpandProperty ProcessName | Sort-Object -Unique
    $keep = $names | Where-Object { $_ -match 'SPOT|mstsc|Citrix|Receiver|wfcrun|SelfService|spool|EPSON|Star|PCSVC|redirector' }
    Set-Content -Path $snap -Value ((Get-Date).ToString('o') + "`n" + ($keep -join "`n")) -Encoding UTF8
}
"""


def load_env() -> None:
    env = REPO / ".env"
    if not env.is_file():
        return
    for raw in env.read_text().splitlines():
        if not raw.strip() or raw.startswith("#") or "=" not in raw:
            continue
        k, v = raw.split("=", 1)
        os.environ.setdefault(k.strip(), v.strip())


def session(host: str, user: str):
    import winrm

    password = os.environ["SPOT_WINRM_PASSWORD"]
    return winrm.Session(
        f"http://{host}:5985/wsman",
        auth=(user, password),
        transport="ntlm",
    )


def start_one(host: str, user: str) -> None:
    s = session(host, user)
    # stop previous observer if any
    s.run_ps(
        r"""
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
  Where-Object { $_.CommandLine -match 'spot-morning-observe' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
"""
    )
    staging = r"C:\ProgramData\spot-discovery\staging\spot-morning-observe.ps1"
    b64 = __import__("base64").b64encode(WATCHER.encode("utf-8")).decode("ascii")
    # write in chunks
    s.run_ps(
        f"$p='{staging}'; New-Item -ItemType Directory -Path (Split-Path $p) -Force | Out-Null; "
        "Remove-Item $p -ErrorAction SilentlyContinue"
    )
    for i in range(0, len(b64), 8000):
        chunk = b64[i : i + 8000]
        s.run_ps(
            f"$p='{staging}'; Add-Content -Path $p -Value '{chunk}' -Encoding ASCII"
        )
    s.run_ps(
        rf"""
$p='{staging}'
$bytes=[Convert]::FromBase64String(((Get-Content $p -Raw).Trim()))
[IO.File]::WriteAllBytes($p, $bytes)
Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',$p) -WindowStyle Hidden
'STARTED ' + $env:COMPUTERNAME
"""
    )
    print(f"observer requested on {host} as {user}", flush=True)


def main() -> int:
    load_env()
    print("morning observe", datetime.now(timezone.utc).isoformat(), flush=True)
    start_one("10.0.253.212", "Zenith Admin")  # WS1
    start_one("10.0.253.205", "ZenithAdmin")  # WS2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
