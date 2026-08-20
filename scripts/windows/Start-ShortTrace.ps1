#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]$Scenario = 'operator-workflow',
    [string]$RunId
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $here 'CollectorCommon.psm1') -Force

if (-not $RunId) { $RunId = New-SpotRunId }
$runRoot = New-SpotRunDirectory -RunId $RunId
$traceRoot = Join-Path $runRoot 'traces'
$scenarioRoot = Join-Path $traceRoot $Scenario
New-Item -ItemType Directory -Path $scenarioRoot -Force | Out-Null

$started = [DateTime]::UtcNow
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem

$marker = [ordered]@{
    scenario         = $Scenario
    run_id           = $RunId
    started_at_utc   = $started.ToString('o')
    local_time       = [DateTime]::Now.ToString('o')
    timezone         = [TimeZoneInfo]::Local.Id
    last_boot        = $os.LastBootUpTime
    logged_on        = $cs.UserName
    computer         = $env:COMPUTERNAME
}
Write-Utf8Json -Path (Join-Path $scenarioRoot 'start-marker.json') -Object $marker

Get-Process | Select-Object Id, ProcessName, Path, StartTime |
    ConvertTo-Json -Depth 4 |
    ForEach-Object {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [IO.File]::WriteAllText((Join-Path $scenarioRoot 'processes-before.json'), $_, $utf8)
    }

# Persistent process-create log (survives this WinRM shell exiting).
$watcher = @'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$out = Join-Path $env:TEMP "spot-procstart.jsonl"
if (Test-Path $out) { Remove-Item $out -Force }
function Write-Evt($obj) {
    $line = ($obj | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $out -Value $line -Encoding UTF8
}
Write-Evt @{ t = [DateTime]::UtcNow.ToString("o"); event = "watcher-start"; pid = $PID }
Register-CimIndicationEvent -ClassName Win32_ProcessStartTrace -SourceIdentifier SpotProcStart -Action {
    $e = $Event.SourceEventArgs.NewEvent
    $line = (@{
        t = [DateTime]::UtcNow.ToString("o")
        event = "start"
        process = $e.ProcessName
        pid = $e.ProcessId
        parent = $e.ParentProcessId
    } | ConvertTo-Json -Compress)
    Add-Content -Path $env:TEMP\spot-procstart.jsonl -Value $line -Encoding UTF8
} | Out-Null
Register-CimIndicationEvent -ClassName Win32_ProcessStopTrace -SourceIdentifier SpotProcStop -Action {
    $e = $Event.SourceEventArgs.NewEvent
    $line = (@{
        t = [DateTime]::UtcNow.ToString("o")
        event = "stop"
        process = $e.ProcessName
        pid = $e.ProcessId
    } | ConvertTo-Json -Compress)
    Add-Content -Path $env:TEMP\spot-procstart.jsonl -Value $line -Encoding UTF8
} | Out-Null
while ($true) { Start-Sleep -Seconds 5 }
'@
$watcherPath = Join-Path $env:ProgramData 'spot-discovery\staging\ProcessWatcher.ps1'
New-Item -ItemType Directory -Path (Split-Path $watcherPath) -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText($watcherPath, $watcher, $utf8)

$existing = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'ProcessWatcher.ps1' }
foreach ($p in @($existing)) {
    try { Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue } catch {}
}

$w = Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $watcherPath) `
    -WindowStyle Hidden -PassThru

$procmonStarted = $false
$procmonPath = Join-Path $env:ProgramData 'spot-discovery\staging\Procmon64.exe'
if (Test-Path $procmonPath) {
    $pml = Join-Path $scenarioRoot 'procmon.pml'
    Start-Process -FilePath $procmonPath -ArgumentList @(
        '/AcceptEula', '/Quiet', '/Minimized', '/BackingFile', $pml
    ) | Out-Null
    $procmonStarted = $true
}

$state = [ordered]@{
    run_id            = $RunId
    scenario          = $Scenario
    run_root          = $runRoot
    scenario_root     = $scenarioRoot
    watcher_pid       = $w.Id
    procmon_started   = $procmonStarted
    proc_log          = Join-Path $env:TEMP 'spot-procstart.jsonl'
}
Write-Utf8Json -Path (Join-Path $env:ProgramData 'spot-discovery\staging\active-trace.json') -Object $state
Write-Utf8Json -Path (Join-Path $scenarioRoot 'trace-state.json') -Object $state

Write-Host "TRACE_STARTED run_id=$RunId"
Write-Host "TRACE_DIR=$scenarioRoot"
Write-Host "WATCHER_PID=$($w.Id)"
Write-Host "PROCMON=$procmonStarted"
Write-Host "BEGIN_OPERATOR_STEPS"
