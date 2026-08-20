[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'user_context'
$runId = $Context.run_id
$outputs = @()

try {
    $auto = Get-SpotWinlogonAutoLogon
    $targetNames = @()
    if ($auto.default_user_name) { $targetNames += $auto.default_user_name }
    $targetNames += 'ZenithUser'
    $targetNames += 'Zenith User'
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    if ($cs -and $cs.UserName -and $cs.UserName -match '\\(.+)$') {
        $targetNames += $Matches[1]
    }
    $targetNames = @($targetNames | Where-Object { $_ } | Select-Object -Unique)

    $profiles = @()
    foreach ($name in $targetNames) {
        $local = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $local) {
            $warnings += "no local user $name"
            continue
        }
        $sid = $local.SID.Value
        $profilePath = Join-Path 'C:\Users' $name
        $hkcu = "Registry::HKEY_USERS\$sid"
        $hiveLoaded = Test-Path $hkcu
        $runKeys = @()
        $citrixKeys = @()
        if ($hiveLoaded) {
            foreach ($rk in @(
                "$hkcu\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                "$hkcu\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
            )) {
                if (Test-Path $rk) {
                    $item = Get-ItemProperty $rk
                    $item.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
                        $runKeys += [ordered]@{
                            key   = $rk
                            name  = $_.Name
                            value = if (Test-SpotSecretName $_.Name -or Test-SpotSecretName ([string]$_.Value)) { '[redacted]' } else { [string]$_.Value }
                        }
                    }
                }
            }
            $citrixRoot = "$hkcu\SOFTWARE\Citrix"
            if (Test-Path $citrixRoot) {
                Get-ChildItem $citrixRoot -Recurse -ErrorAction SilentlyContinue | Select-Object -First 80 | ForEach-Object {
                    $citrixKeys += $_.PSPath.Replace('Microsoft.PowerShell.Core\Registry::', '')
                }
            }
        } else {
            $warnings += "HKCU for $name is not loaded (user may not be logged on). Did not load NTUSER.DAT."
        }

        $desktopLinks = @()
        $desk = Join-Path $profilePath 'Desktop'
        if (Test-Path $desk) {
            Get-ChildItem $desk -Filter *.lnk -ErrorAction SilentlyContinue | ForEach-Object {
                $desktopLinks += Get-SpotShortcutInfo -Path $_.FullName
            }
        }

        $profiles += [ordered]@{
            user_name            = $name
            sid                  = $sid
            profile_path         = $profilePath
            profile_exists       = [bool](Test-Path $profilePath)
            hkcu_loaded          = $hiveLoaded
            enabled              = $local.Enabled
            in_administrators    = $false
            run_keys             = $runKeys
            citrix_registry_keys = $citrixKeys
            desktop_shortcuts    = $desktopLinks
        }
    }

    $adminMembers = @(Get-LocalGroupMember -Group Administrators -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    foreach ($p in $profiles) {
        $p.in_administrators = [bool]($adminMembers | Where-Object { $_ -match [regex]::Escape($p.user_name) })
    }

    $payload = [ordered]@{
        winlogon           = $auto
        shop_floor_targets = $targetNames
        profiles           = $profiles
        administrators     = $adminMembers
        note               = 'Passwords are never exported. HKCU is read from the loaded HKEY_USERS SID while the user is logged on.'
    }
    $out = Join-Path $RunRoot 'accounts\user_context.json'
    Write-Utf8Json -Path $out -Object $payload
    $outputs += $out
    $status = 'success'
} catch {
    $status = 'failed'
    $warnings += $_.Exception.Message
}

$ended = [DateTime]::UtcNow.ToString('o')
Write-Utf8Json -Path (Join-Path $RunRoot "status\$collector.json") -Object (
    New-SpotCollectorStatus -Collector $collector -RunId $runId -StartedAt $started -EndedAt $ended -Status $status -OutputFiles $outputs -Warnings $warnings
)
