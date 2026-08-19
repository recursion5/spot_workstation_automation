[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'pnp_usb'
$runId = $Context.run_id
$outputs = @()

try {
    $devices = @(Get-PnpDevice -ErrorAction SilentlyContinue | ForEach-Object {
        [ordered]@{
            instance_id     = $_.InstanceId
            class           = $_.Class
            class_guid      = $_.ClassGuid
            friendly_name   = $_.FriendlyName
            status          = [string]$_.Status
            problem         = $_.Problem
            problem_code    = $_.ProblemCode
            manufacturer    = $_.Manufacturer
            service         = $_.Service
            present         = [bool]$_.Present
        }
    })

    $usb = @($devices | Where-Object {
        $_.instance_id -match '^USB\\' -or $_.class -match 'USB|Printer|HID|Image|Ports|POS'
    })

    $hwIds = @()
    Get-PnpDevice -ErrorAction SilentlyContinue | ForEach-Object {
        $dev = $_
        try {
            $ids = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_HardwareIds' -ErrorAction SilentlyContinue
            $compat = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_CompatibleIds' -ErrorAction SilentlyContinue
            $loc = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_LocationPaths' -ErrorAction SilentlyContinue
            $container = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_ContainerId' -ErrorAction SilentlyContinue
            $parent = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_Parent' -ErrorAction SilentlyContinue
            if ($dev.InstanceId -match '^USB\\' -or $dev.Class -match 'Printer|USB|HID|Image|Ports|POS') {
                $hwIds += [ordered]@{
                    instance_id    = $dev.InstanceId
                    friendly_name  = $dev.FriendlyName
                    class          = $dev.Class
                    hardware_ids   = @($ids.Data)
                    compatible_ids = @($compat.Data)
                    location_paths = @($loc.Data)
                    container_id   = $container.Data
                    parent         = $parent.Data
                }
            }
        } catch {
            $warnings += "props $($dev.InstanceId): $($_.Exception.Message)"
        }
    }

    $pnputilDevices = @(pnputil /enum-devices /connected 2>$null)

    $payload = [ordered]@{
        device_count        = $devices.Count
        usb_and_pos_related = $usb
        usb_printer_hid_detail = $hwIds
        pnputil_connected   = @($pnputilDevices)
        note                = 'Full Get-PnpDevice list omitted from usb_and_pos_related filter only; add --all later if needed. Hardware IDs are the stable-ish identity; instance IDs and location paths are often port-bound.'
    }
    $out = Join-Path $RunRoot 'pnp\pnp_usb.json'
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
