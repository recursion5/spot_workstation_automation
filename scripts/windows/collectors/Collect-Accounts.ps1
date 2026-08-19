[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'accounts'
$runId = $Context.run_id
$outputs = @()

try {
    $users = @(Get-LocalUser | ForEach-Object {
        $last = Get-SpotProp $_ 'LastLogon'
        $expires = Get-SpotProp $_ 'PasswordExpires'
        [ordered]@{
            name                     = $_.Name
            enabled                  = $_.Enabled
            description              = Get-SpotProp $_ 'Description'
            principal_source         = [string](Get-SpotProp $_ 'PrincipalSource')
            last_logon               = if ($last) { $last.ToUniversalTime().ToString('o') } else { $null }
            password_required        = Get-SpotProp $_ 'PasswordRequired'
            password_expires         = if ($expires) { $expires.ToUniversalTime().ToString('o') } else { $null }
            user_may_change_password = Get-SpotProp $_ 'UserMayChangePassword'
            sid                      = $_.SID.Value
        }
    })
    $groups = @()
    Get-LocalGroup | ForEach-Object {
        $g = $_
        $members = @()
        try {
            $members = @(Get-LocalGroupMember -Group $g.Name -ErrorAction SilentlyContinue | ForEach-Object {
                [ordered]@{ name = $_.Name; sid = $_.SID.Value; object_class = [string]$_.ObjectClass }
            })
        } catch {
            $warnings += "group $($g.Name): $($_.Exception.Message)"
        }
        $groups += [ordered]@{ name = $g.Name; sid = $g.SID.Value; members = $members }
    }

    $payload = [ordered]@{
        local_users          = $users
        local_groups         = $groups
        winlogon_autologon   = Get-SpotWinlogonAutoLogon
        logged_on            = Get-SpotLoggedOnUsers
        note                 = 'DefaultPassword and any other secret values are omitted. Existence is recorded as default_password_present.'
    }
    $out = Join-Path $RunRoot 'accounts\accounts.json'
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
