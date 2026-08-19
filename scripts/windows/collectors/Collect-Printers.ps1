[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunRoot,
    [hashtable]$Context
)
Set-StrictMode -Version Latest
$started = [DateTime]::UtcNow.ToString('o')
$warnings = @()
$collector = 'printer_inventory'
$runId = $Context.run_id
$outputs = @()

function Get-Safe {
    param($Script)
    try { & $Script } catch { $script:warnings += $_.Exception.Message; @() }
}

try {
    Import-Module PrintManagement -ErrorAction SilentlyContinue | Out-Null

    $printers = @(Get-Safe {
        Get-Printer -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                name              = $_.Name
                share_name        = $_.ShareName
                shared            = [bool]$_.Shared
                driver_name       = $_.DriverName
                port_name         = $_.PortName
                print_processor   = $_.PrintProcessor
                datatype          = $_.Datatype
                device_type       = [string]$_.Type
                published         = [bool]$_.Published
                permission_sd     = $null
                location          = $_.Location
                comment           = $_.Comment
                job_count         = $_.JobCount
                printer_status    = [string]$_.PrinterStatus
                rendering_mode    = [string]$_.RenderingMode
                workflow_policy   = [string]$_.WorkflowPolicy
            }
        }
    })

    $drivers = @(Get-Safe {
        Get-PrinterDriver -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                name             = $_.Name
                manufacturer     = $_.Manufacturer
                driver_version   = [string]$_.DriverVersion
                major_version    = $_.MajorVersion
                environment      = $_.PrinterEnvironment
                inf_path         = $_.InfPath
                config_file      = $_.ConfigFile
                data_file        = $_.DataFile
                help_file        = $_.HelpFile
                dependent_files  = @($_.DependentFiles)
                is_package_aware = $_.IsPackageAware
            }
        }
    })

    $ports = @(Get-Safe {
        Get-PrinterPort -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                name           = $_.Name
                description    = $_.Description
                port_monitor   = $_.PortMonitor
                printer_host   = $_.PrinterHostAddress
                port_number    = $_.PortNumber
                snmp_community = if ($_.SNMPCommunity) { '[present]' } else { $null }
                protocol       = $_.Protocol
            }
        }
    })

    $wmiPrinters = @(Get-Safe {
        Get-CimInstance Win32_Printer | ForEach-Object {
            [ordered]@{
                name            = $_.Name
                share_name      = $_.ShareName
                driver_name     = $_.DriverName
                port_name       = $_.PortName
                print_processor = $_.PrintProcessor
                datatype        = $_.PrintJobDataType
                location        = $_.Location
                comment         = $_.Comment
                default         = [bool]$_.Default
                network         = [bool]$_.Network
                local           = [bool]$_.Local
                shared          = [bool]$_.Shared
                work_offline    = [bool]$_.WorkOffline
                detected_error  = $_.DetectedErrorState
                device_id       = $_.DeviceID
                pnp_device_id   = $_.PNPDeviceID
                attributes      = $_.Attributes
            }
        }
    })

    $tcpPorts = @(Get-Safe {
        Get-CimInstance Win32_TCPIPPrinterPort -ErrorAction SilentlyContinue | ForEach-Object {
            [ordered]@{
                name    = $_.Name
                host    = $_.HostAddress
                port    = $_.PortNumber
                protocol = $_.Protocol
                snmp    = $_.SNMPEnabled
            }
        }
    })

    $shares = @(Get-Safe {
        Get-SmbShare -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'print$' } | ForEach-Object {
            [ordered]@{
                name         = $_.Name
                path         = $_.Path
                description  = $_.Description
                share_type   = [string]$_.ShareType
            }
        }
    })

    $netUse = @(Get-Safe {
        $raw = net use
        @($raw)
    })

    $pnpUtilDrivers = @(Get-Safe {
        $raw = pnputil /enum-drivers
        @($raw)
    })

    $printKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Print'
    $registryPrinters = @()
    $monitors = @()
    try {
        $pKey = Join-Path $printKey 'Printers'
        if (Test-Path $pKey) {
            Get-ChildItem $pKey | ForEach-Object {
                $p = Get-ItemProperty $_.PSPath
                $registryPrinters += [ordered]@{
                    name      = $_.PSChildName
                    port      = $p.Port
                    driver    = $p.PrinterDriverData
                    print_processor = $p.'Print Processor'
                    datatype  = $p.Datatype
                    share     = $p.ShareName
                }
            }
        }
    } catch {
        $warnings += "registry printers: $($_.Exception.Message)"
    }
    try {
        $mKey = Join-Path $printKey 'Monitors'
        if (Test-Path $mKey) {
            $monitors = @(Get-ChildItem $mKey | ForEach-Object { $_.PSChildName })
        }
    } catch {
        $warnings += "registry monitors: $($_.Exception.Message)"
    }

    $tagFixCandidates = @()
    $searchRoots = @(
        "$env:PUBLIC\Desktop",
        "$env:USERPROFILE\Desktop",
        "$env:ProgramData\Microsoft\Windows\Start Menu",
        'C:\Users'
    )
    foreach ($root in $searchRoots) {
        if (Test-Path $root) {
            Get-ChildItem -Path $root -Filter '*Tag*.bat' -Recurse -ErrorAction SilentlyContinue -Force |
                Select-Object -First 20 |
                ForEach-Object {
                    $tagFixCandidates += [ordered]@{
                        path   = $_.FullName
                        sha256 = Get-SpotSha256 -Path $_.FullName
                        size   = $_.Length
                    }
                }
        }
    }

    $vendorExpected = @{
        invoice_windows_name = 'EPSON'
        tag_windows_name     = 'Tag'
        cash_drawer_name     = 'Cash Drawer'
        tag_share_and_lpt    = 'USB tag printers documented as needing net use LPT1'
    }

    $correlation = @()
    foreach ($p in $printers) {
        $wmi = $wmiPrinters | Where-Object { $_.name -eq $p.name } | Select-Object -First 1
        $port = $ports | Where-Object { $_.name -eq $p.port_name } | Select-Object -First 1
        $driver = $drivers | Where-Object { $_.name -eq $p.driver_name } | Select-Object -First 1
        $confidence = 'hypothesis'
        if ($p.port_name -and $port) { $confidence = 'proven-port' }
        if ($wmi -and $wmi.pnp_device_id) { $confidence = 'proven-port-pnp-id-present' }
        $correlation += [ordered]@{
            logical_printer     = $p.name
            windows_port        = $p.port_name
            port_monitor        = if ($port) { $port.port_monitor } else { $null }
            driver              = $p.driver_name
            pnp_device_id       = if ($wmi) { $wmi.pnp_device_id } else { $null }
            share_name          = $p.share_name
            mapping_confidence  = $confidence
            vendor_name_hint    = $(
                if ($p.name -eq 'EPSON') { 'invoice-default' }
                elseif ($p.name -eq 'Tag') { 'tag-default' }
                elseif ($p.name -eq 'Cash Drawer') { 'cash-drawer-default' }
                else { $null }
            )
        }
    }

    $payload = [ordered]@{
        printers              = $printers
        drivers               = $drivers
        ports                 = $ports
        wmi_printers          = $wmiPrinters
        tcp_ports             = $tcpPorts
        smb_shares            = $shares
        net_use               = $netUse
        print_monitors        = $monitors
        registry_printers     = $registryPrinters
        pnputil_enum_drivers  = $pnpUtilDrivers
        tag_fix_bat_candidates = $tagFixCandidates
        correlation_table     = $correlation
        vendor_expected_names = $vendorExpected
        note                  = 'PnP topology is in pnp_usb.json. Correlation pnp_device_id is from Win32_Printer when present; treat as hypothesis until cross-checked.'
    }

    $out = Join-Path $RunRoot 'printers\printers.json'
    Write-Utf8Json -Path $out -Object $payload
    $outputs += $out
    $corrOut = Join-Path $RunRoot 'printers\correlation.json'
    Write-Utf8Json -Path $corrOut -Object @{ run_id = $runId; mappings = $correlation }
    $outputs += $corrOut
    $status = 'success'
} catch {
    $status = 'failed'
    $warnings += $_.Exception.Message
}

$ended = [DateTime]::UtcNow.ToString('o')
Write-Utf8Json -Path (Join-Path $RunRoot "status\$collector.json") -Object (
    New-SpotCollectorStatus -Collector $collector -RunId $runId -StartedAt $started -EndedAt $ended -Status $status -OutputFiles $outputs -Warnings $warnings
)
