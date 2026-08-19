[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'system_identity'
$runId = $Context.run_id
$outputs = @()

try {
    $cs = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    $bios = Get-CimInstance Win32_BIOS
    $board = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $disks = @(Get-CimInstance Win32_DiskDrive | ForEach-Object {
        [ordered]@{
            model           = $_.Model
            serial          = $_.SerialNumber
            size_bytes      = $_.Size
            interface_type  = $_.InterfaceType
            pnp_device_id   = $_.PNPDeviceID
        }
    })
    $tz = Get-TimeZone
    $license = $null
    try {
        $license = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND LicenseDependsOn IS NULL" -ErrorAction SilentlyContinue |
            Select-Object Name, Description, LicenseStatus, PartialProductKey, ProductKeyChannel |
            ForEach-Object {
                [ordered]@{
                    name                 = $_.Name
                    description          = $_.Description
                    license_status       = $_.LicenseStatus
                    partial_product_key  = $_.PartialProductKey
                    product_key_channel  = $_.ProductKeyChannel
                }
            }
    } catch {
        $warnings += "license query: $($_.Exception.Message)"
    }

    $payload = [ordered]@{
        computer_name      = $env:COMPUTERNAME
        dns_hostname       = $cs.DNSHostName
        domain             = $cs.Domain
        part_of_domain     = [bool]$cs.PartOfDomain
        workgroup          = $cs.Workgroup
        manufacturer       = $cs.Manufacturer
        model              = $cs.Model
        total_physical_ram = $cs.TotalPhysicalMemory
        bios_serial        = $bios.SerialNumber
        bios_version       = $bios.SMBIOSBIOSVersion
        bios_release       = $bios.ReleaseDate
        board_product      = $board.Product
        board_serial       = $board.SerialNumber
        cpu_name           = $cpu.Name
        cpu_address_width  = $cpu.AddressWidth
        os_caption         = $os.Caption
        os_version         = $os.Version
        os_build           = $os.BuildNumber
        os_arch            = $os.OSArchitecture
        install_date       = $os.InstallDate
        last_boot          = $os.LastBootUpTime
        locale             = $os.Locale
        timezone_id        = $tz.Id
        timezone_base_utc  = $tz.BaseUtcOffset.ToString()
        disks              = $disks
        license_channel    = @($license)
        windows_features   = @()
        power_plan         = $null
    }
    try {
        $payload.windows_features = @(Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue |
            Where-Object { $_.State -eq 'Enabled' } |
            Select-Object -ExpandProperty FeatureName)
    } catch {
        $warnings += "features: $($_.Exception.Message)"
    }
    try {
        $plan = powercfg /getactivescheme
        $payload.power_plan = [string]$plan
    } catch {}

    $out = Join-Path $RunRoot 'baseline\system_identity.json'
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
