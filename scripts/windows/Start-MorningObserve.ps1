#Requires -RunAsAdministrator
# Low-overhead daytime observer. No Procmon. Survives this shell exiting.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'spot-morning-loop' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

$stamp = [DateTime]::UtcNow.ToString('yyyyMMdd')
$dir = Join-Path $env:ProgramData "spot-discovery\observe\$stamp"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$loop = @'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$stamp = [DateTime]::UtcNow.ToString("yyyyMMdd")
$dir = Join-Path $env:ProgramData "spot-discovery\observe\$stamp"
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$out = Join-Path $dir "process-events.jsonl"
function Write-Line($o) {
    Add-Content -Path $out -Value ($o | ConvertTo-Json -Compress -Depth 5) -Encoding UTF8
}
Write-Line @{ t = [DateTime]::UtcNow.ToString("o"); event = "observe-start"; computer = $env:COMPUTERNAME; user = $env:USERNAME }
try {
    Register-CimIndicationEvent -ClassName Win32_ProcessStartTrace -SourceIdentifier SpotMorningStart -Action {
        $e = $Event.SourceEventArgs.NewEvent
        $n = [string]$e.ProcessName
        if ($n -match "SPOT|mstsc|Citrix|Receiver|wfcrun|SelfService|spool|EPSON|Star|PCSVC|redirector|SPOTLauncher") {
            $line = (@{ t=[DateTime]::UtcNow.ToString("o"); event="start"; process=$n; pid=$e.ProcessId; parent=$e.ParentProcessId } | ConvertTo-Json -Compress)
            $log = Join-Path $env:ProgramData ("spot-discovery\observe\" + [DateTime]::UtcNow.ToString("yyyyMMdd") + "\process-events.jsonl")
            Add-Content -Path $log -Value $line -Encoding UTF8
        }
    } | Out-Null
} catch {}
while ($true) {
    Start-Sleep -Seconds 120
    $keep = Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessName -match "SPOT|mstsc|Citrix|Receiver|wfcrun|SelfService|spoolsv|PCSVC|redirector|SPOTLauncher" } |
        ForEach-Object { "{0} pid={1}" -f $_.ProcessName, $_.Id }
    $snap = Join-Path $dir ("snapshot-" + [DateTime]::UtcNow.ToString("HHmmss") + ".txt")
    Set-Content -Path $snap -Value (@((Get-Date).ToUniversalTime().ToString("o")) + $keep) -Encoding UTF8
}
'@

$loopPath = Join-Path $env:ProgramData 'spot-discovery\staging\spot-morning-loop.ps1'
New-Item -ItemType Directory -Path (Split-Path $loopPath) -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText($loopPath, $loop, $utf8)

$errLog = Join-Path $dir 'observer-stderr.txt'
$outLog = Join-Path $dir 'observer-stdout.txt'
$p = Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $loopPath) `
    -WindowStyle Hidden -RedirectStandardError $errLog -RedirectStandardOutput $outLog -PassThru
Start-Sleep -Seconds 2
$alive = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
"MORNING_OBSERVE_STARTED computer=$env:COMPUTERNAME pid=$($p.Id) dir=$dir alive=$([bool]$alive)"
if (-not $alive -and (Test-Path $errLog)) {
    Get-Content $errLog
}
