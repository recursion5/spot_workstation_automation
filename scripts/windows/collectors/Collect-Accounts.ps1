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
        [ordered]@{
            name                     = $_.Name
            enabled                  = $_.Enabled
            description              = $_.Description
            principal_source         = [string]$_.PrincipalSource
            last_logon               = if ($_.LastLogon) { $_.LastLogon.ToUniversalTime().ToString('o') } else { $null }
            password_required        = $_.PasswordRequired
            password_expires         = if ($_.PasswordExpires) { $_.PasswordExpires.ToUniversalTime().ToString('o') } else { $null }
            user_may_change_password = $_.UserMayChangePassword
            sid                      = $_.SID.Value
            # never export password hashes or values
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
