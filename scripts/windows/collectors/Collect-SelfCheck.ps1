[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'selfcheck'
$runId = $Context.run_id

try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $payload = [ordered]@{
        computer_name        = $env:COMPUTERNAME
        os_caption           = $os.Caption
        os_version           = $os.Version
        os_build             = $os.BuildNumber
        architecture         = $os.OSArchitecture
        powershell_version   = $PSVersionTable.PSVersion.ToString()
        clr_version          = $PSVersionTable.CLRVersion.ToString()
        current_user         = "$env:USERDOMAIN\$env:USERNAME"
        elevated             = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        winrm_service        = (Get-Service WinRM -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Status)
        logged_on            = Get-SpotLoggedOnUsers
        programdata_writable = $true
    }
    $out = Join-Path $RunRoot "baseline\selfcheck.json"
    Write-Utf8Json -Path $out -Object $payload
    $status = 'success'
    $outputs = @($out)
} catch {
    $status = 'failed'
    $outputs = @()
    $warnings += $_.Exception.Message
}

$ended = [DateTime]::UtcNow.ToString('o')
Write-Utf8Json -Path (Join-Path $RunRoot "status\$collector.json") -Object (
    New-SpotCollectorStatus -Collector $collector -RunId $runId -StartedAt $started -EndedAt $ended -Status $status -OutputFiles $outputs -Warnings $warnings
)
