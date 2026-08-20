#Requires -RunAsAdministrator
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $here 'CollectorCommon.psm1') -Force

$statePath = Join-Path $env:ProgramData 'spot-discovery\staging\active-trace.json'
if (-not (Test-Path $statePath)) {
    Write-Host 'No active-trace.json found.'
    exit 1
}
$state = Get-Content -Raw $statePath | ConvertFrom-Json
$scenarioRoot = $state.scenario_root
$ended = [DateTime]::UtcNow

# Stop Procmon if running
Get-Process Procmon64, Procmon -ErrorAction SilentlyContinue | ForEach-Object {
    $pm = Join-Path $env:ProgramData 'spot-discovery\staging\Procmon64.exe'
    if (Test-Path $pm) {
        Start-Process -FilePath $pm -ArgumentList '/Terminate' -Wait -WindowStyle Hidden
    }
    Start-Sleep -Seconds 2
    try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch {}
}

# Stop watcher
if ($state.watcher_pid) {
    try { Stop-Process -Id ([int]$state.watcher_pid) -Force -ErrorAction SilentlyContinue } catch {}
}
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'ProcessWatcher.ps1' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Unregister-Event -SourceIdentifier SpotProcStart -ErrorAction SilentlyContinue
Unregister-Event -SourceIdentifier SpotProcStop -ErrorAction SilentlyContinue

$log = Join-Path $env:TEMP 'spot-procstart.jsonl'
if (Test-Path $log) {
    Copy-Item $log (Join-Path $scenarioRoot 'process-events.jsonl') -Force
}

Get-Process | Select-Object Id, ProcessName, Path, StartTime |
    ConvertTo-Json -Depth 4 |
    ForEach-Object {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [IO.File]::WriteAllText((Join-Path $scenarioRoot 'processes-after.json'), $_, $utf8)
    }

# Print and application events in the last 2 hours (window includes this trace)
$since = (Get-Date).AddHours(-2)
$evtxDir = Join-Path $scenarioRoot 'eventlogs'
New-Item -ItemType Directory -Path $evtxDir -Force | Out-Null
foreach ($logName in @('System', 'Application', 'Microsoft-Windows-PrintService/Operational', 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational')) {
    try {
        $safe = ($logName -replace '[\\/]', '_')
        wevtutil epl $logName (Join-Path $evtxDir "$safe.evtx") /ow:true 2>$null
    } catch {}
}

$jobs = @()
try { $jobs = @(Get-PrintJob -ErrorAction SilentlyContinue | Select-Object PrinterName, Id, JobStatus, UserName, SubmittedTime, Size) } catch {}
Write-Utf8Json -Path (Join-Path $scenarioRoot 'print-jobs.json') -Object @($jobs)

$stop = [ordered]@{
    ended_at_utc = $ended.ToString('o')
    local_time   = [DateTime]::Now.ToString('o')
    run_id       = $state.run_id
    scenario     = $state.scenario
}
Write-Utf8Json -Path (Join-Path $scenarioRoot 'stop-marker.json') -Object $stop
Remove-Item $statePath -Force -ErrorAction SilentlyContinue

Write-Host "TRACE_STOPPED run_id=$($state.run_id)"
Write-Host "TRACE_DIR=$scenarioRoot"
