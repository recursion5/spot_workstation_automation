#Requires -Version 5.1
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $here 'Invoke-Discovery.ps1') -Profile selfcheck
