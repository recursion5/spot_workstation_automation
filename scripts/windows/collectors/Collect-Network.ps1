[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'network'
$runId = $Context.run_id
$outputs = @()

try {
    $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{
            name         = $_.Name
            status       = [string]$_.Status
            mac          = $_.MacAddress
            link_speed   = [string]$_.LinkSpeed
            if_desc      = $_.InterfaceDescription
            if_index     = $_.ifIndex
        }
    })
    $addrs = @(Get-NetIPAddress -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{
            if_index   = $_.InterfaceIndex
            family     = [string]$_.AddressFamily
            ip         = $_.IPAddress
            prefix     = $_.PrefixLength
        }
    })
    $routes = @(Get-NetRoute -ErrorAction SilentlyContinue | Select-Object -First 200 | ForEach-Object {
        [ordered]@{
            dest       = $_.DestinationPrefix
            next_hop   = $_.NextHop
            if_index   = $_.InterfaceIndex
            metric     = $_.RouteMetric
        }
    })
    $dns = @(Get-DnsClientServerAddress -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{
            interface = $_.InterfaceAlias
            family    = [string]$_.AddressFamily
            servers   = @($_.ServerAddresses)
        }
    })
    $proxy = [ordered]@{
        winhttp = @((netsh winhttp show proxy 2>$null))
    }
    $fwProfiles = @(Get-NetFirewallProfile -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{ name = $_.Name; enabled = $_.Enabled; default_inbound = [string]$_.DefaultInboundAction }
    })
    $payload = [ordered]@{
        adapters     = $adapters
        addresses    = $addrs
        routes       = $routes
        dns          = $dns
        proxy        = $proxy
        firewall     = $fwProfiles
        connections  = @()
        note         = 'No packet capture. TCP connections can be added in a short trace later, filtered to Citrix/SPOT processes.'
    }
    try {
        $payload.connections = @(Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
            Select-Object -First 200 |
            ForEach-Object {
                [ordered]@{
                    local  = "$($_.LocalAddress):$($_.LocalPort)"
                    remote = "$($_.RemoteAddress):$($_.RemotePort)"
                    owning_pid = $_.OwningProcess
                }
            })
    } catch {
        $warnings += "tcp: $($_.Exception.Message)"
    }
    $out = Join-Path $RunRoot 'network\network.json'
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
