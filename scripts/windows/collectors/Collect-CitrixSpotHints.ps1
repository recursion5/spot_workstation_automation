[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'citrix_spot_hints'
$runId = $Context.run_id
$outputs = @()

try {
    $dirHits = @()
    foreach ($p in Get-SpotInterestingPaths) {
        $exists = Test-Path $p
        $dirHits += [ordered]@{ path = $p; exists = [bool]$exists }
        if ($exists) {
            Get-ChildItem $p -ErrorAction SilentlyContinue | Select-Object -First 50 | ForEach-Object {
                $dirHits += [ordered]@{ path = $_.FullName; exists = $true; size = (Get-SpotProp $_ 'Length'); mode = [string]$_.Attributes }
            }
        }
    }

    $ica = @()
    $search = @(
        "$env:PUBLIC\Desktop",
        "$env:ProgramData",
        'C:\Users\ZenithUser\Desktop',
        'C:\Users\ZenithUser\Documents',
        'C:\Users\ZenithUser\Downloads',
        'C:\Users\ZenithUser\AppData\Roaming',
        'C:\Users\ZenithUser\AppData\Local',
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop"
    )
    foreach ($root in $search) {
        if (-not (Test-Path $root)) { continue }
        Get-ChildItem -Path $root -Include *.ica,*.cr -Recurse -ErrorAction SilentlyContinue -Force |
            Select-Object -First 40 |
            ForEach-Object {
                $ica += [ordered]@{
                    path           = $_.FullName
                    size           = Get-SpotProp $_ 'Length'
                    sha256         = Get-SpotSha256 -Path $_.FullName
                    last_write_utc = $_.LastWriteTimeUtc.ToString('o')
                    content        = '[not exported; ica files often contain credentials]'
                }
            }
    }

    $handlers = @()
    foreach ($prot in @('ica', 'citrix', 'receiver', 'workspace')) {
        $k = "HKLM:\SOFTWARE\Classes\$prot"
        if (Test-Path $k) {
            $handlers += [ordered]@{ protocol = $prot; key = $k; default = (Get-ItemProperty $k).'(default)' }
        }
    }

    $procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -match 'citrix|wfica|selfservice|receiver|workspace|spot|connectlink|wfcrun|redirector'
    } | ForEach-Object {
        [ordered]@{
            name     = $_.ProcessName
            id       = $_.Id
            path     = $_.Path
            start    = if ($_.StartTime) { $_.StartTime.ToUniversalTime().ToString('o') } else { $null }
        }
    })

    $payload = [ordered]@{
        directory_hits     = $dirHits
        ica_or_cr_files    = $ica
        protocol_handlers  = $handlers
        matching_processes = $procs
        vendor_paths       = @{
            citrix_expected      = 'Citrix Workspace / Receiver / SPOTLauncher'
            spotweb_expected     = 'ConnectLink tray app + browser shortcut'
            operator_expectation = 'Citrix-receiver-style local setup; confirm which files exist'
        }
        note = 'Do not export ICA file bodies. Hosted SPOT workstation identity may live only in the remote session.'
    }
    $out = Join-Path $RunRoot 'launch\citrix_spot_hints.json'
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
