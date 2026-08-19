#Requires -RunAsAdministrator
# Finish remote access after the first setup script. Safe for printers/SPOT/auto-logon.
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host 'Setting connected networks to Private (needed for remote access)...' -ForegroundColor Cyan
Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' } | ForEach-Object {
    Write-Host ("  {0} was Public" -f $_.InterfaceAlias)
    try {
        Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private
        Write-Host ("  {0} is now Private" -f $_.InterfaceAlias) -ForegroundColor Green
    } catch {
        Write-Host ("  could not change {0}: {1}" -f $_.InterfaceAlias, $_.Exception.Message) -ForegroundColor Yellow
    }
}

Write-Host 'Turning remote access on again...' -ForegroundColor Cyan
Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null
Set-Service WinRM -StartupType Automatic
Start-Service WinRM

Write-Host 'Allowing the encrypted-over-HTTP login this Linux computer uses...' -ForegroundColor Cyan
winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
winrm set winrm/config/service/auth '@{Negotiate="true"; Kerberos="true"; Basic="false"}' | Out-Null

$latfpPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
New-ItemProperty -Path $latfpPath -Name LocalAccountTokenFilterPolicy -PropertyType DWord -Value 1 -Force | Out-Null

Write-Host ''
Write-Host '==== TELL THE AGENT ====' -ForegroundColor Green
Write-Host 'Network profiles:'
Get-NetConnectionProfile | ForEach-Object {
    Write-Host ("  {0}: {1}" -f $_.InterfaceAlias, $_.NetworkCategory)
}
Write-Host 'Local users:'
Get-LocalUser | ForEach-Object {
    Write-Host ("  {0}  enabled={1}" -f $_.Name, $_.Enabled)
}
Write-Host 'Administrators group:'
Get-LocalGroupMember -Group Administrators | ForEach-Object {
    Write-Host ("  {0}" -f $_.Name)
}
Write-Host 'WinRM localhost test:'
try {
    $w = Test-WSMan
    Write-Host '  OK'
} catch {
    Write-Host ("  FAILED: {0}" -f $_.Exception.Message)
}
Write-Host '========================'
