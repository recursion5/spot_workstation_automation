[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'shortcuts'
$runId = $Context.run_id
$outputs = @()

try {
    $roots = @(
        "$env:PUBLIC\Desktop",
        "$env:PUBLIC\Start Menu",
        "$env:ProgramData\Microsoft\Windows\Start Menu",
        'C:\Users\ZenithUser\Desktop',
        'C:\Users\ZenithUser\AppData\Roaming\Microsoft\Windows\Start Menu',
        "$env:USERPROFILE\Desktop",
        "$env:APPDATA\Microsoft\Windows\Start Menu"
    )
    $links = @()
    foreach ($root in $roots) {
        if (-not (Test-Path $root)) { continue }
        Get-ChildItem -Path $root -Filter *.lnk -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $info = Get-SpotShortcutInfo -Path $_.FullName
            $blob = "$($info.path) $($info.target) $($info.arguments) $($info.description)".ToLowerInvariant()
            $info.flagged = ($blob -match 'spot|citrix|ica|receiver|workspace|connectlink|epson|tag')
            $links += $info
        }
    }
    $payload = [ordered]@{
        shortcuts     = $links
        flagged_only  = @($links | Where-Object { $_.flagged })
        search_roots  = $roots
        note          = 'Includes Public plus ZenithUser (shop-floor) Desktop/Start Menu when those folders are readable. Admin profile is also scanned if this collector runs as ZenithAdmin.'
    }
    $out = Join-Path $RunRoot 'launch\shortcuts.json'
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
