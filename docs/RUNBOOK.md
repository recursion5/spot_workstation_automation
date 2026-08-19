# Runbook

## 1. Controller

Linux host `utility-agent` at `10.0.253.225`. Git remote: `git@github.com:recursion5/spot_workstation_automation.git`.

Clone/open this repo. Optional:

```bash
cp .env.example .env   # then fill locally; never commit
python3 scripts/controller/spotctl.py --help
```

Evidence root (outside git): `$SPOT_EVIDENCE_ROOT` or `/home/grok-agent/spot-discovery/evidence`.

## 2. One-time Windows bootstrap (operator, on the specimen)

Run from an **elevated** PowerShell window on the POS PC. This enables WinRM and opens TCP 5985 only from the controller.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Bootstrap-WinRM.ps1 -ControllerCidr '10.0.253.225/32'
```

What it does:

- `Enable-PSRemoting -Force`
- Sets `LocalAccountTokenFilterPolicy=1` (required for local-admin remoting on workgroup PCs)
- Restricts the Windows Remote Management firewall rule to the controller CIDR
- Creates `C:\ProgramData\spot-discovery`
- Writes a connection card to `C:\ProgramData\spot-discovery\connection-card.json`
- Does **not** change printers, Citrix, auto-logon, or the standard-user session

What it does **not** do:

- Install Sysmon, ProcMon, or any always-on tracer
- Create a new admin user
- Open WinRM to the internet

If the POS PC is not on `10.0.253.0/24`, add an OPNsense rule:

- Source: `10.0.253.225`
- Destination: specimen IPv4
- Port: TCP 5985 (and 5986 later if HTTPS is enabled)
- Description: `SPOT discovery WinRM from utility-agent`

Copy the connection card contents back to the operator/agent. Do not put the admin password in that file.

## 3. Verify connectivity (controller)

```bash
export SPOT_WINRM_HOST='<specimen-ip>'
export SPOT_WINRM_USER='<local-admin>'
export SPOT_WINRM_PASSWORD='...'   # shell only, not git
python3 scripts/controller/spotctl.py verify-connectivity
```

Expected: WinRM identity, computer name, OS caption, and a successful `$PSVersionTable` probe.

## 4. Local baseline if remoting is not ready

On the specimen, elevated or admin PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Invoke-Discovery.ps1 -Profile baseline
```

Copy `C:\ProgramData\spot-discovery\runs\<run-id>\` to the controller evidence root with USB or SMB (for example the Synology `zenith-dsm`, if approved). Then:

```bash
python3 scripts/controller/spotctl.py package-evidence --run-dir /path/to/run-id
python3 scripts/controller/spotctl.py validate-evidence --run-dir /path/to/run-id
```

## 5. Remote baseline (after WinRM works)

```bash
python3 scripts/controller/spotctl.py run-baseline
# or
ansible-playbook -i ansible/inventory/local/hosts.yml ansible/playbooks/verify-connectivity.yml
ansible-playbook -i ansible/inventory/local/hosts.yml ansible/playbooks/baseline-inventory.yml
```

Printer/PnP collection is part of `baseline` and can also be run alone:

```powershell
.\Invoke-Discovery.ps1 -Profile printers
```

## 6. Level B / C traces

Not enabled by default.

- Sysmon: requires ADR-0007 reversal and operator approval.
- ProcMon: short, filtered, around a named scenario. See `scripts/windows/` once those wrappers are added after connectivity.

## 7. Cleanup

```powershell
.\Invoke-Discovery.ps1 -Profile cleanup   # removes copied collector scripts from ProgramData temp; keeps evidence
```

Do not disable WinRM after leaving the site unless collection is finished; the controller needs it.

## 8. Secrets

| Secret | Where it may live | Where it must not |
| --- | --- | --- |
| Local admin password | Operator memory, controller `.env` (mode 600) | Git, issues, evidence JSON, chat logs if avoidable |
| Auto-logon password | Windows LSA/Winlogon on the PC | Any project artifact |
| Citrix/ICA/ConnectLink keys | Protected evidence store, redacted in git-safe JSON | Git |
| WinRM over HTTP | Private LAN only, firewall-restricted to controller | Internet exposure |
