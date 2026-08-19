# 001 — Connect WinRM from controller to specimen-01

**Class:** Open question / blocker  
**Status:** open

The Linux controller (`utility-agent` at `10.0.253.225`) cannot yet reach a POS workstation over WinRM. TCP 5985/5986 was not open on `10.0.253.0/24` neighbors.

Needed from the operator:

1. Run `Bootstrap-WinRM.ps1 -ControllerCidr '10.0.253.225/32'` elevated on the specimen.
2. Hostname, IPv4, local admin username.
3. OPNsense allow rule if the PC is on another VLAN: `10.0.253.225` → specimen TCP 5985.
4. Admin password only in controller `.env`.

Refs: Q-001–Q-003, ADR-0002, `docs/RUNBOOK.md`.
