# Project status

**Phase:** 1 — discovery (remote access working)  
**Date:** 2026-08-21  
**Specimen:** `ZENITH-WS3` at `10.0.253.204`  
**Store:** Store 3 **Zenith** (`store=zenith`)  
**This PC:** Mark-In 2 (back mark-in) — `VGCTX03COUNTER3`  
**Identity:** `store=zenith`, `register=mark-in-2`, `role=mark-in-back`  
**Provisioning:** not started

## Done

- Repository scaffold, ADRs, collectors, controller CLI, Ansible.
- WinRM from this controller to ZENITH-WS3 as `ZenithAdmin` (password only in gitignored `.env`).
- Two Level A baseline runs. Latest: `20260819T203635Z-43b3934a` (evidence outside git).
- Collector StrictMode bugs fixed; shop-floor user context collector added.
- Boot-time tmux/Grok service on this VM (`grok-tmux.service`).

## Workstations

| USB menu | Windows name | IP | SPOT name | OS | Notes |
| --- | --- | --- | --- | --- | --- |
| Mark-In 2 (back mark-in) | ZENITH-WS3 | 10.0.253.204 | VGCTX03COUNTER3 | Win11 | First specimen |
| Mark-In 1 (front mark-in) | ZENITH-WS2 | 10.0.253.205 | VGCTX03COUNTER2 | Win11 | Tag on USB002; Citrix leftover |
| Front Counter (cash drawer) | ZENITH-WS1 | 10.0.253.212 | VGCTX03COUNTER1 | **Win10 Pro 1809** | CashDrawer. Replacement candidate. |

## In progress

- Launch path is **station-dependent today**. WS1 and WS3: SPOTLauncher `ConnectionMode` 1 → **`mstsc`** (RDS RemoteApp). WS2: `ConnectionMode` 0 → Citrix ICA **`wfica32`** (`SPOT - Auto Login`). **Decision (ADR-0009):** replacements use the RDS path, not Citrix. Operator: they are moving off Citrix; stations are not all converted yet.
- Operator workflow 2026-08-20: tag print failed (not repaired). Invoice/scan/relaunch were attempted. Details in DISCOVERIES.
- Printer/PnP correlation (logical names captured; USB mapping still partly hypothesis).
- Reboot test: `ZenithUser` auto-signed in; WinRM still works. Auto-logon mechanism still not the classic registry switch.
- Replacement policy notes recorded (ADR-0011): UPS, RustDesk `dsm.vogueclean.int`, identity wallpaper, admin + standard SPOT user, secrets on NAS, skip retail OOBE. Refinement list: [issue 007](issues/007-replacement-refinements.md).

## Morning observation

- systemd timer `spot-morning-observe.timer` fires at store open in `America/Chicago`: **weekdays 06:00**, **Saturday 08:00**. No Sunday fire until hours are known. Next: Saturday 2026-08-22 08:00 CDT (13:00 UTC).
- Targets: **WS1, WS2, and WS3**. Low-overhead process snapshots every 2 minutes plus process-start events for SPOT/RDP/Citrix/print. No Procmon all day.
- 2026-08-21 06:00 CDT (Friday) job succeeded on WS1/WS2/WS3. See DISCOVERIES morning-open section.
- Coordinated reboot: **all three done**. WS3 two clicks + `mstsc`; WS1 one click + `mstsc` (no Citrix); WS2 SPOT launched as Citrix ICA (`wfica32`), no `mstsc`.
- Operator: SPOT is not left running overnight; the remote session also disconnects when idle. Expect launch activity at open.

## Not running

- Sysmon. No all-day Procmon.
- Phase 2 provisioning.

## Latest evidence

- Controller path: `/home/grok-agent/spot-discovery/evidence/20260819T203635Z-43b3934a/`
- Pointer: [evidence/20260819T203635Z-43b3934a.pointer.md](../evidence/20260819T203635Z-43b3934a.pointer.md)
- Do not commit the zip or JSON bodies (may contain host identifiers; keep out of git except the pointer).

## Next (when operator returns)

1. Saturday 2026-08-22 open is **08:00** CDT (watchers start then). Weekdays remain 06:00.
2. Optional later: a real sale on WS1 if we should capture the cash-drawer **kick**.
3. USB menus are recorded. Vogue SPOT license names still unknown (Q-063). Sunday hours unknown (Q-051).
4. Replacement **implementation** stays later phases. Open refinements: wallpaper design, NAS share path, account names, UPS percent (issue 007).
5. Phase 1 write-up `docs/DISCOVERY-REPORT.md` can be drafted.
