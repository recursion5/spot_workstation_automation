# Project status

**Phase:** 1 — discovery (remote access working)  
**Date:** 2026-08-21  
**Specimen:** `ZENITH-WS3` at `10.0.253.204`  
**Store:** Zenith (operator: two Vogue stores exist separately; this site is Zenith)  
**SPOT license name (this PC):** `VGCTX03COUNTER3`  
**Identity placeholders:** `store=unassigned`, `register=VGCTX03COUNTER3`, `role=back-office`  
**Provisioning:** not started

## Done

- Repository scaffold, ADRs, collectors, controller CLI, Ansible.
- WinRM from this controller to ZENITH-WS3 as `ZenithAdmin` (password only in gitignored `.env`).
- Two Level A baseline runs. Latest: `20260819T203635Z-43b3934a` (evidence outside git).
- Collector StrictMode bugs fixed; shop-floor user context collector added.
- Boot-time tmux/Grok service on this VM (`grok-tmux.service`).

## Workstations

| Windows name | IP | SPOT name | OS | Remote | Notes |
| --- | --- | --- | --- | --- | --- |
| ZENITH-WS3 | 10.0.253.204 | VGCTX03COUNTER3 | Win11 | yes (`ZenithAdmin`) | First specimen |
| ZENITH-WS2 | 10.0.253.205 | VGCTX03COUNTER2 | Win11 | yes (`ZenithAdmin`) | Tag on USB002; Citrix **Workspace** shortcut |
| ZENITH-WS1 | 10.0.253.212 | VGCTX03COUNTER1 | **Win10 Pro 1809** (17763) | yes (`Zenith Admin`) | MINIX N42C-4. Has **CashDrawer**. Replacement candidate. |

## In progress

- Launch path: live trace saw **`mstsc.exe`** start ~2 minutes after recording began (RDS). Citrix processes were already long-running.
- Operator workflow 2026-08-20: tag print failed (not repaired). Invoice/scan/relaunch were attempted. Details in DISCOVERIES.
- Printer/PnP correlation (logical names captured; USB mapping still partly hypothesis).
- Reboot test: `ZenithUser` auto-signed in; WinRM still works. Auto-logon mechanism still not the classic registry switch.

## Morning observation

- systemd timer `spot-morning-observe.timer` fires **06:00 America/Chicago** (11:00 UTC).
- Targets: **WS1, WS2, and WS3**. Low-overhead process snapshots every 2 minutes plus process-start events for SPOT/RDP/Citrix/print. No Procmon all day.
- 2026-08-21 06:00 CDT job succeeded on WS1/WS2/WS3; watchers still alive at 09:20 with hundreds of snapshots. See DISCOVERIES morning-open section.
- Coordinated reboot: **WS3 done** (two clicks); **WS1 done** (one click, no Citrix after reboot). Waiting on **WS2**.
- Cash-drawer check-in on WS1 can be observed after open (operator: not until morning).
- Operator: SPOT is not left running overnight; the remote session also disconnects when idle. Expect launch activity at open, not leftover `mstsc` from the previous day.

## Not running

- Sysmon. No all-day Procmon.
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
