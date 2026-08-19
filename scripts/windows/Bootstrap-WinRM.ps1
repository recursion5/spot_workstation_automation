#Requires -RunAsAdministrator
<#
.SYNOPSIS
  One-time WinRM bootstrap for SPOT discovery. Does not change printers, Citrix, or auto-logon.

.EXAMPLE
  .\Bootstrap-WinRM.ps1 -ControllerCidr '10.0.253.225/32'
#>
[CmdletBinding()]
param(
    [string]$ControllerCidr = '10.0.253.225/32',
    [switch]$AllowAnyRemote,
    [int]$HttpPort = 5985
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step { param($m) Write-Host "[*] $m" -ForegroundColor Cyan }
function Write-Ok   { param($m) Write-Host "[ok] $m" -ForegroundColor Green }
function Write-Warn2 { param($m) Write-Host "[!!] $m" -ForegroundColor Yellow }

$base = Join-Path $env:ProgramData 'spot-discovery'
New-Item -ItemType Directory -Path $base -Force | Out-Null

Write-Step 'Enabling PowerShell remoting (WinRM HTTP)'
Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM
Write-Ok 'WinRM service is running'

Write-Step 'Allowing local-admin remoting on workgroup (LocalAccountTokenFilterPolicy=1)'
$latfpPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
New-ItemProperty -Path $latfpPath -Name LocalAccountTokenFilterPolicy -PropertyType DWord -Value 1 -Force | Out-Null
Write-Ok 'LocalAccountTokenFilterPolicy=1'

Write-Step 'Configuring WinRM auth (NTLM/Negotiate; Basic remains off unless already enabled)'
try {
    winrm set winrm/config/service '@{AllowUnencrypted="false"}' | Out-Null
} catch {
    Write-Warn2 "AllowUnencrypted leave-as-is: $($_.Exception.Message)"
}

Write-Step 'Restricting firewall to the controller'
$ruleName = 'SPOT discovery WinRM HTTP from controller'
Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule

if ($AllowAnyRemote) {
    Write-Warn2 'AllowAnyRemote: WinRM HTTP will accept any source. Do not use this on a public network.'
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort $HttpPort -Action Allow -Profile Any | Out-Null
} else {
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort $HttpPort -RemoteAddress $ControllerCidr -Action Allow -Profile Any | Out-Null
    foreach ($default in @('WINRM-HTTP-In-TCP', 'WINRM-HTTP-In-TCP-PUBLIC')) {
        $existing = Get-NetFirewallRule -Name $default -ErrorAction SilentlyContinue
        if ($existing) {
            try {
                Set-NetFirewallRule -Name $default -RemoteAddress $ControllerCidr -Enabled True
            } catch {
                Write-Warn2 "Could not tighten $default : $($_.Exception.Message)"
            }
        }
    }
    Write-Ok "Inbound TCP $HttpPort allowed from $ControllerCidr"
}

Write-Step 'Local WinRM self-test'
$wsman = Test-WSMan -ErrorAction SilentlyContinue
if (-not $wsman) {
    throw 'Test-WSMan failed on localhost. WinRM is not ready.'
}
Write-Ok 'Test-WSMan succeeded'

$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$nics = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike '127.*' } |
    Select-Object InterfaceAlias, IPAddress, PrefixLength

$card = [ordered]@{
    generated_at_utc           = [DateTime]::UtcNow.ToString('o')
    computer_name              = $env:COMPUTERNAME
    dns_hostname               = $cs.DNSHostName
    domain                     = $cs.Domain
    part_of_domain             = [bool]$cs.PartOfDomain
    manufacturer               = $cs.Manufacturer
    model                      = $cs.Model
    os_caption                 = $os.Caption
    os_version                 = $os.Version
    os_build                   = $os.BuildNumber
    logged_on_user             = $cs.UserName
    winrm_http_port            = $HttpPort
    controller_cidr            = $(if ($AllowAnyRemote) { 'any' } else { $ControllerCidr })
    ipv4_addresses             = @($nics | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength) ($($_.InterfaceAlias))" })
    localaccount_token_filter  = 1
    notes                      = @(
        'Admin password is NOT in this file.',
        'Give hostname + IPv4 + admin username to the controller operator.',
        'If this PC is not on 10.0.253.0/24, allow TCP 5985 from 10.0.253.225 on OPNsense.'
    )
}

$cardPath = Join-Path $base 'connection-card.json'
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($cardPath, ($card | ConvertTo-Json -Depth 6), $utf8)

Write-Host ''
Write-Host '==== CONNECTION CARD ====' -ForegroundColor Green
$card | ConvertTo-Json -Depth 6
Write-Host "Wrote $cardPath"
Write-Host 'Do not put the administrator password in git or in this file.'
Write-Host '========================='
