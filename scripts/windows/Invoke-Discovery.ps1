#Requires -Version 5.1
<#
.SYNOPSIS
  Dispatch SPOT discovery collectors on the local Windows workstation.

.EXAMPLE
  .\Invoke-Discovery.ps1 -Profile baseline
  .\Invoke-Discovery.ps1 -Profile printers
#>
[CmdletBinding()]
param(
    [ValidateSet('baseline', 'printers', 'selfcheck', 'cleanup')]
    [string]$Profile = 'baseline',
    [string]$RunId,
    [string]$OutputRoot,
    [string]$Store = 'unassigned',
    [string]$Register = 'specimen-01',
    [string]$Role = 'back-office'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $here 'CollectorCommon.psm1') -Force

$started = [DateTime]::UtcNow.ToString('o')
if (-not $RunId) { $RunId = New-SpotRunId }
$runRoot = New-SpotRunDirectory -RunId $RunId -OutputRoot $OutputRoot

$context = @{
    run_id   = $RunId
    run_root = $runRoot
    store    = $Store
    register = $Register
    role     = $Role
    here     = $here
}

$profiles = @{
    selfcheck = @('Collect-SelfCheck.ps1')
    printers  = @('Collect-Printers.ps1', 'Collect-PnpUsb.ps1')
    baseline  = @(
        'Collect-SelfCheck.ps1',
        'Collect-SystemIdentity.ps1',
        'Collect-Accounts.ps1',
        'Collect-Software.ps1',
        'Collect-ServicesTasksStartup.ps1',
        'Collect-Printers.ps1',
        'Collect-PnpUsb.ps1',
        'Collect-Network.ps1',
        'Collect-Shortcuts.ps1',
        'Collect-CitrixSpotHints.ps1',
        'Collect-UserContext.ps1',
        'Collect-EventLogInventory.ps1'
    )
    cleanup   = @()
}

if ($Profile -eq 'cleanup') {
    $staging = Join-Path (Get-SpotDiscoveryBase) 'staging'
    if (Test-Path -LiteralPath $staging) {
        Remove-Item -LiteralPath $staging -Recurse -Force
    }
    Write-Host "Removed $staging if it existed. Evidence under runs\ was kept."
    exit 0
}

$collectorDir = Join-Path $here 'collectors'
$statusFiles = @()
$warnings = @()

foreach ($scriptName in $profiles[$Profile]) {
    $scriptPath = Join-Path $collectorDir $scriptName
    Write-Host "--> $scriptName"
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        $warnings += "missing collector $scriptName"
        continue
    }
    try {
        & $scriptPath -RunRoot $runRoot -Context $context
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            $warnings += "$scriptName exit $LASTEXITCODE"
        }
    } catch {
        $warnings += "$scriptName $($_.Exception.Message)"
        Write-Warning $_
    }
}

Get-ChildItem -Path (Join-Path $runRoot 'status') -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object {
    $statusFiles += $_.FullName
}

$hashLines = @()
Get-ChildItem -Path $runRoot -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($runRoot.Length).TrimStart('\')
    $hash = Get-SpotSha256 -Path $_.FullName
    $hashLines += "$hash  $rel"
}
$hashPath = Join-Path $runRoot 'hashes\SHA256SUMS'
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($hashPath, ($hashLines -join "`n") + "`n", $utf8)

$ended = [DateTime]::UtcNow.ToString('o')
$cs = Get-CimInstance Win32_ComputerSystem
$manifest = [ordered]@{
    run_id            = $RunId
    schema            = 'run-manifest/v1'
    profile           = $Profile
    store             = $Store
    register          = $Register
    role              = $Role
    target_hostname   = $env:COMPUTERNAME
    dns_hostname      = $cs.DNSHostName
    started_at        = $started
    ended_at          = $ended
    timezone          = [TimeZoneInfo]::Local.Id
    collector_version = '1'
    status            = $(if ($warnings.Count -eq 0) { 'success' } else { 'partial' })
    warnings          = @($warnings)
    output_root       = $runRoot
    redaction_status  = 'git-safe collectors; secret values omitted'
    known_gaps        = @(
        'Level B Sysmon not installed',
        'Level C ProcMon traces not captured',
        'Hosted SPOT Program Configuration is not visible without the running session'
    )
}
Write-Utf8Json -Path (Join-Path $runRoot 'manifest.json') -Object $manifest

Write-Host ''
Write-Host "Run $RunId  status=$($manifest.status)"
Write-Host "Output: $runRoot"
Write-Host 'Copy this folder to the controller evidence root. Do not commit it to git.'
