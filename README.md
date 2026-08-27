# SPOT workstation automation

Make a Windows 11 Pro Xplor Spot POS workstation **reproducible** from evidence, not from a cloned disk image.

This repository has finished **Phase 1 discovery for Zenith**. Phase 2 desired-state starts at [docs/desired-state/zenith-front-counter.md](docs/desired-state/zenith-front-counter.md). It does not yet provision replacement PCs.

Canonical intent: [project-spec.md](project-spec.md). Agent rules: [AGENTS.md](AGENTS.md). Handoff: [docs/DISCOVERY-REPORT.md](docs/DISCOVERY-REPORT.md). Current state: [docs/STATUS.md](docs/STATUS.md).

## What Phase 1 is

Collect enough structured evidence from one known-good workstation that a later agent can answer, from artifacts rather than this chat:

- what launches SPOT (Citrix / SPOTLauncher / SPOTWeb / ConnectLink — discover, do not assume; **replacements use SPOTLauncher RDS, not Citrix** — [ADR-0009](docs/DECISIONS/0009-rds-not-citrix.md));
- which local software, services, shortcuts, and identity values are required;
- how logical printer names map to drivers, ports, and USB/PnP devices;
- what is workstation-specific versus hardware-bound.

The POS application is **Xplor Spot** ([xplorspot.com](https://xplorspot.com)). Vendor documentation describes a Citrix + SPOTLauncher path and a newer SPOTWeb + ConnectLink path. On the Zenith floor the live mix is SPOTLauncher → **RDS RemoteApp** (WS1, WS3) or leftover **Citrix ICA** (WS2). Replacements follow RDS.

## Operator: connect the first workstation before leaving the site

The controller for this project is a Linux host on `10.0.253.0/24` (this agent). WinRM is **not** yet enabled on any POS PC, and POS workstations are probably not on this management subnet.

Do these on the specimen Windows 11 Pro PC, elevated PowerShell:

1. Copy `scripts/windows/Bootstrap-WinRM.ps1` onto the PC (USB, SMB, or paste).
2. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Bootstrap-WinRM.ps1 -ControllerCidr '10.0.253.225/32'
```

3. Leave the printed **connection card** (hostname, IPs, logged-on user) with the operator or paste it back to the agent.
4. Tell the agent:
   - specimen hostname and IPv4 address;
   - local admin username (not the password in git);
   - whether an OPNsense rule is needed from `10.0.253.225` to that IPv4 on TCP `5985`.
5. Keep the admin password out of the repo. On the controller it belongs in a gitignored `.env` (see `.env.example`).

If WinRM cannot be opened from this controller before you leave, run a **local baseline** on the PC so work can continue from a USB/SMB evidence bundle:

```powershell
.\Invoke-Discovery.ps1 -Profile baseline
```

Output lands in `C:\ProgramData\spot-discovery\runs\<run-id>\`. Copy that folder to the controller evidence root. Do not copy it into git.

Full procedure: [docs/RUNBOOK.md](docs/RUNBOOK.md).

## Repository layout

| Path | Role |
| --- | --- |
| `project-spec.md` | Constitution and Phase 1 requirements |
| `ansible/` | Repeatable remote orchestration (WinRM/PSRP) |
| `scripts/windows/` | Bootstrap and collectors that run *on* Windows |
| `scripts/controller/` | Linux-side connectivity, packaging, validation |
| `schemas/` | JSON Schema for collector status and inventories |
| `docs/` | Status, discoveries, ADRs, runbook |
| `evidence/` | Manifests and pointers only — no raw traces |

## Safety

- Phase 1 is read-only observation plus a one-time, operator-approved management bootstrap.
- Do not rename printers, reinstall drivers, or change auto-logon/Citrix settings to “see what happens.”
- Never commit passwords, auto-logon secrets, ICA credentials, WinRM credentials, or raw ProcMon/ETW/EVTX bundles.
- Payment card data is not expected on these PCs (external tokenizing terminal). Still do not capture PAN/PIN or memory dumps.

## Tooling on the controller

Ansible + `pywinrm` for remote management. PowerShell collectors on the target. Python 3 for packaging and schema checks.

```bash
python3 scripts/controller/spotctl.py --help
```
