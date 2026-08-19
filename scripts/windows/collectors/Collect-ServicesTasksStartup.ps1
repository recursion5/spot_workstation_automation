[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'services_tasks_startup'
$runId = $Context.run_id
$outputs = @()
$needles = 'citrix|ica|spot|epson|star|print|receiver|workspace|connectlink|autologon'

try {
    $services = @(Get-CimInstance Win32_Service | ForEach-Object {
        $flag = $_.Name -match $needles -or $_.DisplayName -match $needles -or $_.PathName -match $needles
        [ordered]@{
            name         = $_.Name
            display_name = $_.DisplayName
            state        = $_.State
            start_mode   = $_.StartMode
            start_name   = $_.StartName
            path_name    = $_.PathName
            flagged      = [bool]$flag
        }
    })
    $tasks = @()
    try {
        $tasks = @(Get-ScheduledTask | ForEach-Object {
            $info = $_ | Get-ScheduledTaskInfo
            $execs = @($_.Actions | ForEach-Object { Get-SpotProp $_ 'Execute' })
            $args = @($_.Actions | ForEach-Object {
                $a = Get-SpotProp $_ 'Arguments'
                if (Test-SpotSecretName $a) { '[redacted]' } else { $a }
            })
            $blob = "$($_.TaskName) $($_.TaskPath) $($execs -join ' ')"
            [ordered]@{
                task_name   = $_.TaskName
                path        = $_.TaskPath
                state       = [string]$_.State
                execute     = $execs
                arguments   = $args
                last_result = Get-SpotProp $info 'LastTaskResult'
                flagged     = [bool]($blob -match $needles)
            }
        })
    } catch {
        $warnings += "tasks: $($_.Exception.Message)"
    }
    $runKeys = @()
    $runPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
    )
    foreach ($rk in $runPaths) {
        if (Test-Path $rk) {
            $item = Get-ItemProperty $rk
            $item.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
                $runKeys += [ordered]@{
                    key     = $rk
                    name    = $_.Name
                    value   = if (Test-SpotSecretName $_.Name -or Test-SpotSecretName ([string]$_.Value)) { '[redacted]' } else { [string]$_.Value }
                    flagged = ([string]$_.Value -match $needles -or $_.Name -match $needles)
                }
            }
        }
    }
    $startupFolders = @()
    foreach ($sf in @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )) {
        if (Test-Path $sf) {
            Get-ChildItem $sf -ErrorAction SilentlyContinue | ForEach-Object {
                $startupFolders += [ordered]@{ path = $_.FullName; name = $_.Name }
            }
        }
    }
    $payload = [ordered]@{
        services        = $services
        scheduled_tasks = $tasks
        run_keys        = $runKeys
        startup_folder  = $startupFolders
        flagged_note    = 'flagged=true means name/path matched citrix/spot/printer/autologon needles. Not proof of POS relevance.'
    }
    $out = Join-Path $RunRoot 'baseline\services_tasks_startup.json'
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
