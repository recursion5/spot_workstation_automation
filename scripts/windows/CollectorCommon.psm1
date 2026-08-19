# Shared helpers for SPOT discovery collectors (Windows PowerShell 5.1).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Get-SpotDiscoveryBase {
    $root = Join-Path $env:ProgramData 'spot-discovery'
    if (-not (Test-Path -LiteralPath $root)) {
        New-Item -ItemType Directory -Path $root -Force | Out-Null
    }
    return $root
}

function New-SpotRunId {
    $stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
    $suffix = [Guid]::NewGuid().ToString('N').Substring(0, 8)
    return "$stamp-$suffix"
}

function New-SpotRunDirectory {
    param(
        [string]$RunId,
        [string]$OutputRoot
    )
    if (-not $OutputRoot) {
        $OutputRoot = Join-Path (Get-SpotDiscoveryBase) 'runs'
    }
    if (-not $RunId) {
        $RunId = New-SpotRunId
    }
    $runRoot = Join-Path $OutputRoot $RunId
    foreach ($child in @('', 'baseline', 'printers', 'pnp', 'software', 'registry', 'files', 'eventlogs', 'traces', 'network', 'accounts', 'launch', 'hashes', 'reports', 'status')) {
        $path = if ($child -eq '') { $runRoot } else { Join-Path $runRoot $child }
        if (-not (Test-Path -LiteralPath $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
    return $runRoot
}

function Write-Utf8Json {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$Object,
        [int]$Depth = 10
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $json = $Object | ConvertTo-Json -Depth $Depth -Compress:$false
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $json, $utf8)
    return $Path
}

function Get-SpotSha256 {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Test-SpotSecretName {
    param([string]$Name)
    if (-not $Name) { return $false }
    $n = $Name.ToLowerInvariant()
    $needles = @(
        'password', 'passwd', 'pwd', 'secret', 'token', 'credential', 'cred',
        'authticket', 'cleartext', 'connectionstring', 'privatekey', 'pin'
    )
    foreach ($needle in $needles) {
        if ($n.Contains($needle)) { return $true }
    }
    return $false
}

function New-SpotCollectorStatus {
    param(
        [Parameter(Mandatory)][string]$Collector,
        [Parameter(Mandatory)][string]$RunId,
        [Parameter(Mandatory)][string]$StartedAt,
        [Parameter(Mandatory)][string]$EndedAt,
        [Parameter(Mandatory)][string]$Status,
        [string]$Version = '1',
        [string[]]$OutputFiles = @(),
        [string[]]$Warnings = @(),
        [string]$ErrorMessage
    )
    $obj = [ordered]@{
        collector     = $Collector
        version       = $Version
        run_id        = $RunId
        started_at    = $StartedAt
        ended_at      = $EndedAt
        status        = $Status
        output_files  = @($OutputFiles)
        warnings      = @($Warnings)
    }
    if ($ErrorMessage) {
        $obj.error = $ErrorMessage
    }
    return $obj
}

function Get-SpotUninstallEntries {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $rows = @()
    foreach ($path in $paths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
            if (-not $_.DisplayName) { return }
            $rows += [ordered]@{
                display_name     = $_.DisplayName
                display_version  = $_.DisplayVersion
                publisher        = $_.Publisher
                install_location = $_.InstallLocation
                install_date     = $_.InstallDate
                uninstall_string = if (Test-SpotSecretName $_.UninstallString) { '[redacted]' } else { $_.UninstallString }
                quiet_uninstall  = $null
                modify_path      = $_.ModifyPath
                psn              = $_.PSChildName
                wow64            = ($_.PSPath -match 'WOW6432Node')
                estimated_size_kb = $_.EstimatedSize
            }
        }
    }
    return $rows
}

function Get-SpotShortcutInfo {
    param([Parameter(Mandatory)][string]$Path)
    $shell = $null
    try {
        $shell = New-Object -ComObject WScript.Shell
        $lnk = $shell.CreateShortcut($Path)
        $item = Get-Item -LiteralPath $Path -ErrorAction Stop
        $acl = Get-Acl -LiteralPath $Path -ErrorAction SilentlyContinue
        return [ordered]@{
            path             = $Path
            target           = $lnk.TargetPath
            arguments        = if (Test-SpotSecretName $lnk.Arguments) { '[redacted-args]' } else { $lnk.Arguments }
            working_directory = $lnk.WorkingDirectory
            icon_location    = $lnk.IconLocation
            window_style     = $lnk.WindowStyle
            description      = $lnk.Description
            size             = $item.Length
            sha256           = Get-SpotSha256 -Path $Path
            last_write_utc   = $item.LastWriteTimeUtc.ToString('o')
            owner            = if ($acl) { $acl.Owner } else { $null }
        }
    } catch {
        return [ordered]@{
            path  = $Path
            error = $_.Exception.Message
        }
    } finally {
        if ($shell) {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
        }
    }
}

function Get-SpotWinlogonAutoLogon {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
    if (-not $props) {
        return [ordered]@{ source = 'winlogon'; present = $false }
    }
    $defaultPasswordPresent = $false
    try {
        $raw = Get-ItemProperty -Path $key -Name DefaultPassword -ErrorAction SilentlyContinue
        if ($null -ne $raw -and $null -ne $raw.DefaultPassword -and "$($raw.DefaultPassword)".Length -gt 0) {
            $defaultPasswordPresent = $true
        }
    } catch {
        $defaultPasswordPresent = $false
    }
    return [ordered]@{
        source                    = 'winlogon'
        auto_admin_logon          = [string]$props.AutoAdminLogon
        default_user_name         = [string]$props.DefaultUserName
        default_domain_name       = [string]$props.DefaultDomainName
        default_password_present  = $defaultPasswordPresent
        auto_logon_count_present  = ($null -ne $props.AutoLogonCount)
        force_auto_logon          = [string]$props.ForceAutoLogon
        shell                     = [string]$props.Shell
        # DefaultPassword value is never exported.
    }
}

function Get-SpotLoggedOnUsers {
    $rows = @()
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        if ($cs.UserName) {
            $rows += [ordered]@{ source = 'Win32_ComputerSystem'; user = $cs.UserName }
        }
    } catch {}
    try {
        $q = quser 2>$null
        if ($q) {
            $rows += [ordered]@{ source = 'quser'; raw_lines = @($q | ForEach-Object { $_.TrimEnd() }) }
        }
    } catch {}
    return $rows
}

function Get-SpotInterestingPaths {
    @(
        "$env:ProgramFiles\Citrix",
        "${env:ProgramFiles(x86)}\Citrix",
        "$env:ProgramFiles\SPOT",
        "${env:ProgramFiles(x86)}\SPOT",
        "$env:ProgramFiles\SPOTLauncher",
        "${env:ProgramFiles(x86)}\SPOTLauncher",
        "$env:ProgramFiles\ConnectLink",
        "${env:ProgramFiles(x86)}\ConnectLink",
        "$env:ProgramData\Citrix",
        "$env:ProgramData\SPOT",
        "$env:PUBLIC\Desktop"
    )
}

Export-ModuleMember -Function *
