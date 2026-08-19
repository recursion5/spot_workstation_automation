# Project status

**Phase:** 1 — discovery (remote access working)  
**Date:** 2026-08-19  
**Specimen:** `ZENITH-WS3` at `10.0.253.204`  
**Identity placeholders:** `store=unassigned`, `register=specimen-01`, `role=back-office`  
**Provisioning:** not started

## Done

- Repository scaffold, ADRs, collectors, controller CLI, Ansible.
- WinRM from this controller to ZENITH-WS3 as `ZenithAdmin` (password only in gitignored `.env`).
- Two Level A baseline runs. Latest: `20260819T203635Z-43b3934a` (evidence outside git).
- Collector StrictMode bugs fixed; shop-floor user context collector added.
- Boot-time tmux/Grok service on this VM (`grok-tmux.service`).

## In progress

- Launch path: SPOTLauncher is configured for **RDS RemoteApp** (`rds.mydrycleaner.com`, client `VGCTX03COUNTER3`). Citrix Receiver is also installed. A launch trace is still needed.
- Printer/PnP correlation (logical names captured; USB mapping still partly hypothesis).
- How the desktop returns after reboot (`AutoAdminLogon` is currently `0`).

## Not running

- Sysmon, ProcMon, or other all-day traces.
- Phase 2 provisioning.

## Latest evidence

- Controller path: `/home/grok-agent/spot-discovery/evidence/20260819T203635Z-43b3934a/`
- Pointer: [evidence/20260819T203635Z-43b3934a.pointer.md](../evidence/20260819T203635Z-43b3934a.pointer.md)
- Do not commit the zip or JSON bodies (may contain host identifiers; keep out of git except the pointer).

## Next (when operator returns)

1. Confirm whether employees expect auto-logon after reboot (registry currently says no).
2. Short approved traces: POS shortcut launch, one tag print, one invoice print.
3. Decide store/register codes (Q-040).
4. Optional: remove admin rights from `ZenithUser` later — not a Phase 1 task unless asked.
