#Requires -RunAsAdministrator
# Writes a boot/logon marker and starts the detached observer after reboot.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$observe = Join-Path $here 'Start-MorningObserve.ps1'
$marker = Join-Path $env:ProgramData 'spot-discovery\staging\Write-BootMarker.ps1'
New-Item -ItemType Directory -Path (Split-Path $marker) -Force | Out-Null

@'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$dir = Join-Path $env:ProgramData ("spot-discovery\observe\" + [DateTime]::UtcNow.ToString("yyyyMMdd"))
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$obj = @{
  t = [DateTime]::UtcNow.ToString("o")
  computer = $env:COMPUTERNAME
  logged_on = $cs.UserName
  boot = $os.LastBootUpTime.ToUniversalTime().ToString("o")
  user = "$env:USERDOMAIN\$env:USERNAME"
}
$line = $obj | ConvertTo-Json -Compress
Add-Content -Path (Join-Path $dir "boot-logon.jsonl") -Value $line -Encoding UTF8
$start = "C:\ProgramData\spot-discovery\staging\windows\Start-MorningObserve.ps1"
if (Test-Path $start) {
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File $start
}
'@ | Set-Content -Path $marker -Encoding UTF8

$tr = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$marker`""
schtasks /Create /F /TN "SPOT-discovery-boot-observe" /SC ONSTART /RU SYSTEM /RL HIGHEST /TR $tr | Out-Null
schtasks /Create /F /TN "SPOT-discovery-logon-observe" /SC ONLOGON /RU SYSTEM /RL HIGHEST /TR $tr | Out-Null
"BOOT_TASKS_INSTALLED computer=$env:COMPUTERNAME"
