[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'software'
$runId = $Context.run_id
$outputs = @()

try {
    $entries = @(Get-SpotUninstallEntries)
    $needles = @(
        'citrix', 'ica', 'receiver', 'workspace', 'spot', 'spotlauncher',
        'connectlink', 'epson', 'star micronics', 'star ', 'bixolon', 'zebra',
        'jsprint', 'neodynamic', 'print manager', 'advanced printer'
    )
    $flagged = @($entries | Where-Object {
        $blob = ("$($_.display_name) $($_.publisher) $($_.install_location)").ToLowerInvariant()
        foreach ($n in $needles) { if ($blob.Contains($n)) { return $true } }
        $false
    })
    $payload = [ordered]@{
        uninstall_entries = $entries
        flagged_likely_pos = $flagged
        flag_needles      = $needles
    }
    $out = Join-Path $RunRoot 'software\uninstall.json'
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
