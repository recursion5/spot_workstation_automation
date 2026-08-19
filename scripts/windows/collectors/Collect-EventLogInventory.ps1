[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'eventlog_inventory'
$runId = $Context.run_id
$outputs = @()

try {
    $logs = @(Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object { $_.RecordCount -gt 0 } | ForEach-Object {
        [ordered]@{
            log_name       = $_.LogName
            record_count   = $_.RecordCount
            file_size      = $_.FileSize
            is_classic     = $_.IsClassicLog
            is_enabled     = $_.IsEnabled
            log_mode       = [string]$_.LogMode
            last_write     = if ($_.LastWriteTime) { $_.LastWriteTime.ToUniversalTime().ToString('o') } else { $null }
        }
    })
    $interesting = @($logs | Where-Object {
        $_.log_name -match 'Print|System|Application|Setup|Citrix|Microsoft-Windows-PrintService|Microsoft-Windows-UserPnp|Microsoft-Windows-DriverFrameworks|TerminalServices|RemoteDesktop|WinRM'
    })
    $payload = [ordered]@{
        log_count           = $logs.Count
        interesting_logs    = $interesting
        all_logs_with_events = $logs
        note                = 'No .evtx export in Level A. Do not clear logs. Targeted exports belong to a later approved trace.'
    }
    $out = Join-Path $RunRoot 'eventlogs\inventory.json'
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
