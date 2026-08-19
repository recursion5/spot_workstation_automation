# Coding conventions

## PowerShell (runs on Windows)

- Windows PowerShell 5.1 compatible unless a collector proves it needs PowerShell 7.
- `Set-StrictMode -Version Latest`; avoid silent `$null` property access.
- Collectors are non-interactive. No `Read-Host`, no GUI.
- Emit UTF-8 JSON without BOM. One status object per collector (`schemas/collector-status.schema.json`).
- Catch per-subsystem failures; record them as `warnings` or `status=failed` without aborting the whole run unless the dispatcher is told to stop.
- Never write secret values. If a registry value name looks like a password, record existence, type, and length only.
- Version collectors via the `version` field in the status object.

## Python (controller)

- Python 3.12+ (controller currently has 3.14).
- Standard library plus `pywinrm` and `jsonschema`.
- No network calls that bypass TLS verification except the documented WinRM HTTP bootstrap on a private LAN.
- CLI entry: `python3 scripts/controller/spotctl.py`.

## YAML / Ansible

- Two-space indent.
- Real inventory and vault files stay under `ansible/inventory/local/` (gitignored).
- Prefer `ansible.windows` modules over `win_shell` when a module exists; `win_shell`/`win_powershell` is acceptable for invoking project collectors.
- Target OS is Windows; `ansible_connection` is `psrp` or `winrm`.

## JSON

- UTF-8, pretty-printed with 2-space indent for artifacts humans will diff.
- Timestamps in UTC ISO-8601 with `Z`.
- Validate against `schemas/` in tests.

## Git

- Small commits. No secrets. No raw evidence.
- `main` is the default branch.
- CRLF for PowerShell via `.gitattributes`; LF for everything else.
