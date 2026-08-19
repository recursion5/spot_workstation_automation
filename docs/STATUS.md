# Project status

**Phase:** 1 — bootstrap and discovery  
**Date:** 2026-08-19  
**Specimen identity:** `store=unassigned`, `register=specimen-01` (placeholder; see ADR-0006)  
**Provisioning:** not started (forbidden in this phase)

## Done

- Repository scaffold matching [project-spec.md](../project-spec.md) §6.
- Agent startup rules in `AGENTS.md`.
- ADR mechanism and initial decisions.
- Gitignore rules excluding credentials and raw evidence.
- Example inventory with no real credentials.
- Windows WinRM bootstrap script and local discovery entrypoint.
- Baseline collectors (system, accounts, software, services/startup, printers, PnP/USB, network, shortcuts, event-log inventory, SPOT/Citrix hints).
- Evidence manifest schema and controller packaging/validation commands.
- Controller tooling packages identified: Ansible, `pywinrm`.

## In progress

- First live WinRM connection to the specimen workstation.
- First approved discovery run.

## Blocked

- Remote interrogation of the specimen. No POS hostname/IP or WinRM endpoint is known yet. Controller LAN observations are in [DISCOVERIES.md](DISCOVERIES.md).
- Admin credentials exist only with the operator; they must never enter git.

## Controller facts (this agent host)

| Item | Value | Class |
| --- | --- | --- |
| Hostname | `utility-agent` | Discovery |
| IPv4 | `10.0.253.225/24` | Discovery |
| Default gateway | `10.0.253.1` (`OPNsense.vogueclean.int`) | Discovery |
| Public IPv4 observed | `47.190.138.13` | Discovery |
| DNS suffix observed | `vogueclean.int` | Discovery |

WinRM ports 5985/5986 were not open on any host scanned on `10.0.253.0/24`.

## Next actions

1. Operator runs `scripts/windows/Bootstrap-WinRM.ps1` on the specimen.
2. Operator provides hostname, IPv4, and local admin username.
3. If the PC is not on `10.0.253.0/24`, add an OPNsense allow rule: `10.0.253.225` → specimen TCP 5985.
4. Controller `spotctl.py verify-connectivity`.
5. Remote baseline inventory, printer/PnP first.
6. Package evidence outside git; commit only the manifest pointer.

## Tool evaluation (Phase 1)

| Tool | Status |
| --- | --- |
| Native PowerShell / CIM / PrintManagement | Implemented for Level A |
| WinRM / PS Remoting | Bootstrap script ready; live test pending |
| Ansible `psrp` / `winrm` | Playbooks sketched; PSRP preferred after connectivity works |
| Process Monitor | Not installed. Short traces only, operator-approved. |
| Sysmon | Deferred (ADR-0007). Requires operator approval. |
| WPR/ETW | Deferred until a question ProcMon/Sysmon/inventory cannot answer. |
