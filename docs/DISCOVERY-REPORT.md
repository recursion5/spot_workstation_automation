# Phase 1 discovery report

**Date:** 2026-08-22  
**Store:** Zenith (store 3)  
**Controller:** `utility-agent` `10.0.253.225`  
**Phase:** 1 complete for Zenith evidence. Phase 2 started (Front Counter desired-state draft). **Do not** implement USB/OOBE until that recipe is accepted and blocking opens (NAS, accounts, browser) are decided.  
**This document is the handoff.** Prefer it plus ADRs, `config/catalog/workstations.yml`, and evidence pointers over chat history.

Classification: **Discovery** unless labeled Requirement, Decision, Hypothesis, Assumption, or Open question.

---

## How to start (next agent)

Read, in order: [AGENTS.md](../AGENTS.md), [project-spec.md](../project-spec.md), this report, [STATUS.md](STATUS.md), [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md), [DECISIONS/README.md](DECISIONS/README.md), [REQUIREMENTS.md](REQUIREMENTS.md), [RUNBOOK.md](RUNBOOK.md), [DISCOVERIES.md](DISCOVERIES.md).

Secrets: gitignored `.env` (`SPOT_WINRM_PASSWORD`) and `ansible/inventory/local/hosts.yml`. Never commit them. ICA files on disk can contain encrypted passwords; do not git them.

WinRM is HTTP 5985 NTLM from `10.0.253.225` only. Users:

| Host | IP | WinRM user |
| --- | --- | --- |
| ZENITH-WS3 | 10.0.253.204 | `ZenithAdmin` |
| ZENITH-WS2 | 10.0.253.205 | `ZenithAdmin` |
| ZENITH-WS1 | 10.0.253.212 | `Zenith Admin` (space) |
| ZENITH-WORKDESK | 10.0.253.162 | `Zenith Admin` |
| Z-SSTATION | 10.0.253.164 | `Zenith Admin` |

**Watchers:** store-open systemd timer still starts a low-overhead loop **on WS1/WS2/WS3** (`C:\ProgramData\spot-discovery\observe\`). Boot/logon scheduled tasks do the same after reboot. Files stay on the PCs until an agent pulls them. That does **not** spend Grok tokens. The 12-hour Grok chat loop was **cancelled** 2026-08-22. Do not recreate it unless the operator asks.

**Do not** collect more from SPOT PCs unless asked. Cash-drawer kick and scanners are closed. Do not reverse-engineer POS auto-logon. Do not convert live WS1/WS3 from RDS to Citrix to experiment.

---

## Confirmed discoveries

### Site

- This site is **Zenith**, not Vogue. Two Vogue stores exist separately (Krum, Denton).
- POS product: **Xplor Spot**, hosted. No ConnectLink/SPOTWeb on these PCs.
- Gateway `https://rds.mydrycleaner.com`, API `https://api.mydrycleaner.com`.
- Card data is not on the PCs (external tokenizing terminals). No memory dumps.

### USB catalog (Requirement + Decision)

Source of truth: `config/catalog/workstations.yml`. License form **`VGCTXssCOUNTERn`** (operator confirmed store number after `VGCTX`).

| Store | Menu | SPOT `ClientName` | Live Windows name |
| --- | --- | --- | --- |
| Vogue Krum | Front Counter (cash drawer) | VGCTX01COUNTER1 | not inventoried |
| Vogue Krum | Mark-In | VGCTX01COUNTER2 | not inventoried |
| Vogue Denton | Front Counter (cash drawer) | VGCTX02COUNTER1 | not inventoried |
| Vogue Denton | Mark-In | VGCTX02COUNTER2 | not inventoried |
| Zenith | Front Counter (cash drawer) | VGCTX03COUNTER1 | ZENITH-WS1 10.0.253.212 Win10 17763 |
| Zenith | Mark-In 1 (front mark-in) | VGCTX03COUNTER2 | ZENITH-WS2 10.0.253.205 Win11 |
| Zenith | Mark-In 2 (back mark-in) | VGCTX03COUNTER3 | ZENITH-WS3 10.0.253.204 Win11 |
| Zenith | Management desk | — | ZENITH-WORKDESK 10.0.253.162 Win10 19045 |
| Zenith | Video wall | — | Z-SSTATION 10.0.253.164 Win10 19044 |

### Launch path (SPOT)

| PC | `ConnectionMode` | What carries the SPOT window |
| --- | --- | --- |
| WS1, WS3 | 1 | `mstsc` RemoteApp (`||spot`), `/rdsvirtualchannel` |
| WS2 | 0 | Citrix ICA `wfica32`, published app `SPOT - Auto Login` |

**Decision (ADR-0012, supersedes 0009):** replacements use SPOTLauncher **Citrix** (`ConnectionMode` 0, Workspace, `wfica32` / `SPOT - Auto Login`). Live WS1/WS3 stay RDS until replaced. WS2 is the launch-path template.

Shortcut pattern: `SPOT (VGCTX03COUNTERn).lnk` → SPOTLauncher 1.1.169.3, args `"/launch:SPOT"`.

RDP (WS1/WS3 `apps.json`): `redirectprinters:i:0`; username `VGCTX03COUNTERn` @ `mydrycleaner.com`; brokers `RDCB.MYDRYCLEANER.COM`. Print uses **SBSRDPAddin** + ScrewDrivers, not native RDP printer redirect.

**Operational:** SPOT **Exit** disconnects and leaves the hosted session (reattach). **Logoff** ends `VGCTX03COUNTERn` on the farm; relaunch is a new session. That recovered a WS1 invoice/report outage after Windows test pages already worked. A PC reboot only helps if the hosted session is already gone.

### Peripherals

| Station | Tag | Invoice | Cash drawer | Brother reports |
| --- | --- | --- | --- | --- |
| WS1 Front Counter | none | EPSON TM-T88V `ESDPRT001` | `CashDrawer` same Epson port | HL-L2380DW WSD |
| WS2 Mark-In 1 | Tag USB002 Generic/Text | EPSON TM-T88V | none | Brother WSD |
| WS3 Mark-In 2 | Tag USB001 Generic/Text (Star SP742 USB) | EPSON TM-T88V | none | Brother WSD |

Tag jobs often **never** appear in PrintService even when tags print. Invoice/report from SPOT also may not show as Windows jobs. Windows test pages do.

Cash-drawer **kick** = standard Epson pulse on `CashDrawer`. **Check-in** is not a Windows print event. Operator: no live-sale capture.

Scanners: USB HID keyboard-wedge like WS3 (`VID_0536`). All stations the same.

**Vendor install kits (SPOT leftover Downloads):** captured on the controller 2026-08-27 — Epson APD 5.11 (`APD_511R1_T88V_EWM.zip`), Star PRNT 3.8.1, WASP fonts (49 ttf; ~30 installed per-user for the shop-floor account), older SPOTLauncher 1.1.167.1. Pointer: [vendor-installers.pointer.md](../evidence/vendor-installers.pointer.md). Rebuilds install those packages, not only printer objects.

### Accounts and auto-logon

| PC | Admin | Shop-floor | Shop-floor is admin? | AutoAdminLogon |
| --- | --- | --- | --- | --- |
| WS3, WS2 | ZenithAdmin | ZenithUser | yes | 0 (still auto-signs in) |
| WS1 | Zenith Admin | Zenith User | yes | 0 (still auto-signs in) |
| Video wall | Zenith Admin | Zenith User | **no** | **1** |
| Workdesk | Zenith Admin | Gayla (Yevhen present, **do not rebuild**) | no | unset; people sign in |

**Decision:** reproduce auto-logon **behavior** on POS/video-wall replacements; do not reverse-engineer POS mechanism. Replacements: admin + **standard** auto-logon user (video wall already matches). Workdesk: interactive logon, named **Gayla**.

### Non-SPOT

- Video wall: Synology Surveillance Station Client 2.2.1 running, Startup for Zenith User. Custom **CallerIdOverlay** at logon via scheduled task `\CallerIdOverlay` (`C:\ProgramData\CallerIdOverlay\CallerIdOverlay.exe`); talks to `http://10.0.253.113:8080`, `store_id` 103. RustDesk to `rustdesk.vogueclean.int`.
- Workdesk: MSI Cubi2; Chrome/Acrobat/3CX; SS Client installed but unused. OneLaunch/OneBrowser/Cash Catch and `velis-browser.com` start-page hijack **removed**; operator confirmed Chrome is good.

### RustDesk / UPS

- All reached PCs have RustDesk. **Requirement** and live config (2026-08-27): **`rustdesk.vogueclean.int`** (DNS A `10.0.253.110`).
- UPS HID: WS1 APC, WS2 CyberPower, WS3 none, workdesk none, video wall HID present.

### Hours

Weekdays 06:00, Saturday 08:00 America/Chicago. Sunday unknown. SPOT not left overnight.

---

## Dependency map (SPOT RDS station)

```
Desktop shortcut  SPOT (VGCTX03COUNTERn).lnk
  -> SPOTLauncher 1.1.169.3  (settings.json ClientName, ConnectionMode 1)
    -> mstsc -Embedding  gateway rds.mydrycleaner.com / RDCB.MYDRYCLEANER.COM
      -> RemoteApp ||spot  user VGCTX03COUNTERn@mydrycleaner.com
        -> virtual channel  SBSRDPAddin + ScrewDrivers
          -> local printers by Windows name (EPSON, Tag, CashDrawer, Brother)
               EPSON/CashDrawer: Epson APD5, port ESDPRT001, USB VID_04B8 PID_0202, service PCSVC
               Tag: Generic/Text, USB00n, Star SP742 VID_0519 (WS2/WS3)
               Brother: WSD / IPP class driver
```

**Live:** WS1/WS3 use the RDS hop above; WS2 substitutes Citrix Workspace / `wfica32` / ICA `SPOT - Auto Login`. **Replacements (ADR-0012):** copy the WS2 Citrix hop, not `mstsc`.

---

## Workstation-specific state (copy as identity, not as disk)

- `ClientName` / RDP user / shortcut name `VGCTXssCOUNTERn`
- Role: cash drawer vs tag vs back mark-in vs desk vs video wall
- Printer **names** and whether `CashDrawer` / `Tag` exist
- `ConnectionMode` **0** + Citrix Workspace (desired, ADR-0012); live WS1/WS3 `ConnectionMode` 1 / RDS is not the replacement path
- Windows computer names keep the live hostnames (`ZENITH-WS1`, `ZENITH-WS2`, `ZENITH-WS3`, `ZENITH-WORKDESK`, `Z-SSTATION`)
- Video wall: SS Client auto-start; CallerIdOverlay logon task + config (token lives with NAS secrets, not git)
- Workdesk: Gayla, no auto-logon, 3CX
- Vendor kits: Epson APD 5.11, Star PRNT 3.8.1, WASP per-user fonts, SPOTLauncher (live 1.1.169.3)

---

## Hardware-bound (do not copy literally)

- USB instance IDs, `USB001` vs `USB002`, WSD port GUIDs
- MINIX N42C-4 (WS1), NEO Z100, MSI Cubi2 as required hardware
- Win10 17763 vs 19044/19045 vs Win11 26200
- Receiver 4.9 autostart / leftover ICA on RDS boxes (replacement Citrix is **Workspace**, WS2 template)
- POS shop-floor users in Administrators
- Old RustDesk IP `10.0.253.110` (live and rebuilds use `rustdesk.vogueclean.int`)
- Chrome hijack leftovers; OneLaunch
- Yevhen account

---

## Candidate reproducible state (Phase 2/3)

**Requirement / Decision** already locked:

1. USB boot → store → workstation ([ADR-0010](DECISIONS/0010-usb-store-then-workstation.md)).
2. Windows 11 Pro; skip retail OOBE.
3. SPOT rows: SPOTLauncher **Citrix Workspace / ICA**, not RDS ([ADR-0012](DECISIONS/0012-citrix-launch-path.md)).
4. Secrets from NAS `dsm.vogueclean.int`, applied at build ([ADR-0005](DECISIONS/0005-secrets-handling.md), [ADR-0011](DECISIONS/0011-replacement-policy-notes.md)).
5. RustDesk → `rustdesk.vogueclean.int`.
6. UPS; stay on battery; **shut down** when the UPS cannot continue (not hibernate).
7. Black wallpaper: store, computer name, SPOT id if `runs_spot`.
8. Admin + standard user; SPOT and video wall auto-logon as standard user.
9. SPOT shop-floor: **Edge**; home/new tab **`https://help.spotpos.com`**. Further lockdown still open.
10. Accounts **`ZenithAdmin`** / **`ZenithUser`**. Computer names keep the live hostnames.
11. First POS replacement candidate: **Zenith Front Counter** (WS1).
12. Vendor kits: Epson APD 5.11 + WASP fonts for `ZenithUser` (Star PRNT on tag rows). Binaries on the controller, not git.

---

## Unknowns (do not block more POS scraping)

See [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md). Highest leverage for Phase 2:

| ID | Topic |
| --- | --- |
| Q-072 | Wallpaper layout |
| Q-074 | NAS **share path** and how the USB authenticates |
| Q-062 | What lives on the USB if NAS is down |
| Q-071 | Retail Win11 product key |
| Q-075 | UPS critical percent; WS3 missing UPS HID |
| Q-082 | Video-wall camera layout / NAS target for SS Client |
| Q-084 | How far to lock down Edge |
| Q-051 | Sunday hours |
| Q-013 | Hosted SPOT Account Key (not on the PC as a clear field) |

Vogue POS printers are **by analogy** until a Vogue PC is read (not required to start Zenith Front Counter).

---

## Proposed experiments

None currently. Operator: no more SPOT-PC collection unless asked. Do not install Sysmon (ADR-0007) or all-day Procmon.

If printing sticks again: Windows test page first; if that works, SPOT **Logoff** then relaunch ([RUNBOOK.md](RUNBOOK.md) §9).

---

## Vendor / host questions (if someone must call SPOT)

- Confirm workstation printer names inside hosted Setup for `VGCTX03COUNTERn`.
- How to log off / reset RDS user `VGCTX03COUNTERn` from the farm (Logoff in the app did this once).
- Hosted Account Key if the build must store it.

Prefer not to call SPOT for a routine rebuild; that is why secrets go on the NAS.

---

## Evidence (outside git)

Controller: `/home/grok-agent/spot-discovery/evidence/`

| Pointer | What |
| --- | --- |
| [20260819T203635Z-43b3934a](../evidence/20260819T203635Z-43b3934a.pointer.md) | WS3 Level A baseline (latest) |
| [20260820T001911Z-9af4f7de](../evidence/20260820T001911Z-9af4f7de.pointer.md) | Operator workflow / launch |
| [observe-20260821](../evidence/observe-20260821.pointer.md) | Watcher pulls, reboot inspects, WS1 print diag (redacted) |

On PCs: `C:\ProgramData\spot-discovery\` (staging, observe snapshots, connection cards).

---

## Next steps (Phase 2 — analysis, still no installer)

1. Desired-state document per catalog row. **Front Counter draft:** [desired-state/zenith-front-counter.md](desired-state/zenith-front-counter.md).
2. Secret-pack layout on the NAS (no values in git).
3. USB/WinPE design: store menu → workstation menu → unattend Win11 + apply row.
4. Account-name and computer-name decisions (Q-073, Q-070).
5. Video-wall SS Client config capture when the operator wants that replacement.
6. Optional: read one Vogue POS if those printers might differ.

Phase 1 acceptance in [project-spec.md](../project-spec.md) §25 is met for Zenith evidence, WinRM, inventories, launch/print observation, watchers, and this report. Provisioning remains Phase 3.
