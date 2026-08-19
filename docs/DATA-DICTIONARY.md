# Data dictionary

## Run identity

| Field | Meaning |
| --- | --- |
| `run_id` | `YYYYMMDDTHHMMSSZ-<short>` UTC. Unique per collection. |
| `store` | Business store identifier. Placeholder `unassigned` until operator supplies one. |
| `register` | Workstation/register identifier. Placeholder `specimen-01`. |
| `role` | Optional. Examples: `back-office`, `customer-facing`. Specimen expected `back-office`. |
| `target_hostname` | Windows computer name as observed. |
| `collector` | Collector id (`printer_inventory`, `system_identity`, …). |
| `status` | `success`, `failed`, `skipped`, `partial`. |

## Printer correlation

| Field | Meaning |
| --- | --- |
| `logical_printer` | Exact Windows printer name (application contract). |
| `share_name` | SMB share name if shared (tag printers often shared as `Tag`). |
| `port_name` | Windows port (`USB001`, `LPT1`, `ES0001`, TCP, WSD, vendor virtual). |
| `port_monitor` | Port monitor / provider. |
| `driver_name` | Print driver display name. |
| `driver_inf` | INF / driver-store package if known. |
| `pnp_instance_id` | Device instance ID. Hardware-bound. |
| `hardware_ids` | PnP hardware IDs. More stable across ports than instance IDs. |
| `mapping_confidence` | `proven` or `hypothesis`. |

Vendor-documented default names (confirm on specimen): `EPSON` (invoice), `Tag` (tag), `Cash Drawer` (kick-out printer object).

## Launch path

| Field | Meaning |
| --- | --- |
| `shortcut_path` | `.lnk` used by employees. |
| `shortcut_target` | Resolved target. |
| `arguments` | Command line. Redact secrets. |
| `initial_process` | First process of the tree. |
| `citrix_or_spot_component` | Product name/version if identified. |

## Evidence package

See `schemas/run-manifest.schema.json`. SHA-256 of every file is listed in `hashes/SHA256SUMS`.
