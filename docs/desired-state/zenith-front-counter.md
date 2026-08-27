# Desired state: Zenith Front Counter (cash drawer)

**Status:** draft (Phase 2). Not an installer. **Not** a guarantee of a production-ready USB cutover.  
**Catalog:** `store=zenith`, `register=front-counter`, `runs_spot=true`  
**USB menus:** Store 3 **Zenith** → **Front Counter (cash drawer)**  
**SPOT `ClientName`:** `VGCTX03COUNTER1`  
**Windows computer name:** `ZENITH-WS1` (Decision: keep the live names)  
**Live specimen:** `ZENITH-WS1` `10.0.253.212` (Win10 Pro 17763, MINIX N42C-4) — replace, do not clone.  
**Replacement OS:** Windows 11 Pro. Skip retail OOBE.

Classification: **Requirement** / **Decision** unless labeled Discovery, Hypothesis, or Open question.

---

## What this station is for

Customer-facing register: hosted Xplor Spot, thermal invoices, cash-drawer kick through the Epson, Brother reports, HID barcode scanner. **No tag printer.** Payments stay on an external tokenizing terminal.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend (no “new PC” screens). Product key: Open question (Q-071).
2. Pull the secret pack for this row from `\\zenith-dsm.vogueclean.int\spot-rebuild`. Do not bake passwords into the USB.
3. Create accounts, wallpaper, RustDesk, printers, SPOTLauncher, browser policy.
4. Bind printers to **whatever USB/WSD PnP the new box sees**. Do not copy `USB001` or WSD GUIDs from WS1.
5. Validate (checklist below). Staff: desktop → SPOT shortcut; shop-floor user already signed in.

Computer name: **`ZENITH-WS1`** (Decision 2026-08-27).

---

## Accounts

| Role | Live on WS1 (Discovery) | Desired |
| --- | --- | --- |
| Local admin | `Zenith Admin` (space) | **`ZenithAdmin`** (no space), Administrators |
| Shop-floor | `Zenith User` (space), **is** an admin today | **`ZenithUser`** (no space), **standard** (not admin). Auto-logon **behavior**: desktop after reboot, no password typed. |
| Built-in Administrator | disabled | Stay disabled. |

Do not put the shop-floor user in Administrators. Do not reverse-engineer WS1’s `AutoAdminLogon=0` path.

---

## SPOT launch (Decision ADR-0012, supersedes 0009)

| Item | Value |
| --- | --- |
| Client | SPOTLauncher **1.1.169.3** (or current vendor build of the same product) |
| `ConnectionMode` | **0** (Citrix). Template: WS2. |
| `ClientName` | `VGCTX03COUNTER1` |
| `RDGatewayAddress` | `https://rds.mydrycleaner.com` |
| `APIURL` | `https://api.mydrycleaner.com` |
| Desktop shortcut | `SPOT (VGCTX03COUNTER1).lnk`, args `"/launch:SPOT"`, under `ZenithUser` |
| Citrix | **Workspace** (live WS2: `26.3.10.69`), not Receiver 4.9 |
| Session | ICA `wfica32`, published app **`SPOT - Auto Login`** |
| Print | Local Windows printer **names**; Citrix/ScrewDrivers mapping **Hypothesis** until first Citrix replacement is tested |

**Do not** use RDS `mstsc` / `ConnectionMode` 1 as the SPOT window on new boxes. Do not convert live WS1 to Citrix to experiment.

`PrintingClientInstallCount` on the live box is **2** (Discovery: Epson + CashDrawer pair). Recreate that pair.

SPOT-related secrets (Citrix/ICA, launcher) come from the NAS pack. Not git.

**Ops:** if SPOT prints fail but Windows test pages work, use SPOT **Logoff** then relaunch, not Exit. See [RUNBOOK.md](../RUNBOOK.md) §9.

---

## Printers and scanner

Logical names must match hosted SPOT Setup for this workstation.

| Windows name | Role | Driver / port (logical) | Notes |
| --- | --- | --- | --- |
| `EPSON` | Invoice / receipt | EPSON TM-T88V Receipt5, Epson APD5, port `ESDPRT001`, service `PCSVC` | USB TM-T88V (`VID_04B8` `PID_0202` on the live box — Discovery). Bind to the new USB instance. |
| `CashDrawer` | Drawer kick | Same driver, **same port as `EPSON`** | Standard Epson pulse on sale. Check-in is not a Windows job. |
| Brother HL-L2380DW series Printer | Reports | WSD / IPP class driver | Re-discover on the LAN; do not copy the old WSD GUID. |
| — | Tags | **none** | Front Counter has no `Tag` printer. |

Scanner: USB HID keyboard-wedge (same as WS3). No extra driver.

### Vendor driver / font packages (Discovery 2026-08-27)

SPOT’s manual new-PC setup leaves these in Downloads. **Installed products were already in Level A software inventory.** The **installer files** are now copied to the controller (`/home/grok-agent/spot-discovery/evidence/vendor-installers/`, pointer in git). Large binaries stay off git; copy to NAS when Q-074 exists.

| Package | Captured | What it is |
| --- | --- | --- |
| `APD_511R1_T88V_EWM.zip` | Yes (controller) | Epson APD 5.11 R1 for TM-T88V (`APD_511R1_T88V.exe`) |
| `starprnt_v3.8.1.zip` | Yes (controller) | Star Micronics Printer Software 3.8.1 (tag stations; Front Counter has no Tag printer) |
| `WASP_Fonts.zip` | Yes (controller) | 49 WASP barcode/MICR `.ttf` fonts |
| `SPOTLauncherSetup_1.1.169.3.exe` | Yes (NAS `common/packages/` + controller) | Official setup (operator). Prefer this over 1.1.167.1 leftover. |
| `SPOTLauncherSetup_1.1.167.1.exe` | Yes (controller) | Older leftover; do not prefer |

WASP fonts on the live PCs are **per-user** for the shop-floor account (`AppData\Local\Microsoft\Windows\Fonts`), not `C:\Windows\Fonts`. About 30 of 49 files from the zip are installed (Code 39/93/128, Codabar, MICR, OCR, UPC). Rebuilds must **run Epson APD + install WASP fonts for `ZenithUser`** (and Star PRNT on tag rows), not only “create a printer object.” Silent switches are not extracted yet.

**Running the installers is necessary, not sufficient.** After APD, the wizard still has to register a printer named **`EPSON`** (not default), paper **80×3276**, port auto (`ESDPRT001` / `PCSVC` on the live boxes). Front Counter also registers a second APD printer named **`CashDrawer`** on that same port, no feed/cut, drawer #1 open (SPOT APD_511R1 article + live WS1). Hosted SPOT Setup for `VGCTX03COUNTER1` already exists; local Windows names must match it. Citrix Workspace + SPOTLauncher identity are separate from these zips. See [DISCOVERIES.md](../DISCOVERIES.md) vendor-kit analysis.

---

## Browser (SPOT shop-floor only)

**Requirement:** exactly **one** browser on the standard-user profile.

| Setting | Value |
| --- | --- |
| Browser | **Microsoft Edge** (included with Windows) |
| Home / default / new tab | `https://help.spotpos.com` |
| Search provider | Controlled (Google unless later specified) |
| Extra browsers, coupon extensions, OneLaunch | Absent |

Further lockdown (Start menu, Store): still Open (Q-084 remainder). Do not apply this recipe to Gayla’s desk unless asked.

---

## RustDesk, wallpaper, UPS, WinRM

| Item | Desired |
| --- | --- |
| RustDesk | Installed; rendezvous/relay **`rustdesk.vogueclean.int`**. Public key from NAS pack. |
| Wallpaper (all local users) | Black; text: store **Zenith**, Windows computer name, SPOT id **`VGCTX03COUNTER1`**. Font/layout: Open question (Q-072). |
| UPS | Present. Stay up on battery. Critical action **Shut down** (not hibernate; live WS1 cannot hibernate). Percent: Open question (Q-075). |
| WinRM | HTTP 5985 NTLM, firewall to controller `10.0.253.225/32`, admin user only. Same bootstrap as discovery. |
| Bloat | Remove consumer junk (OneLaunch, extra Store apps, second browsers). Exact list still part of lockdown discussion. |

---

## Explicitly out of this row

- RDS `mstsc` / `ConnectionMode` 1 as the SPOT window (ADR-0012)
- `Tag` printer / Star SP742
- Shop-floor user as Administrator
- Cloning WS1’s disk, USB instance IDs, or WSD port IDs
- SPOTWeb + ConnectLink
- Capturing a live sale to “prove” the drawer

---

## Secrets this row needs (existence only in git)

NAS pack (paths TBD, Q-074), at least:

- Shop-floor auto-logon secret
- Local admin password
- SPOTLauncher `settings.json` (not a secret: `ClientName` + API + `ConnectionMode` 0) — already known
- RustDesk public key (and ID if we pre-register)

Citrix ICA tickets are **not** pack secrets (ephemeral). Farm “SPOT - Auto Login” **Hypothesis:** no stored Citrix password required.

Layout: [secret-pack.md](secret-pack.md). ScrewDrivers is live on RDS boxes; Citrix replacements may not need that license (**Hypothesis**).

---

## Validation (after a future USB build)

1. Reboot: shop-floor desktop, no password prompt.
2. Shortcut `SPOT (VGCTX03COUNTER1)` opens hosted SPOT via **Citrix** (`wfica32` / `SPOT - Auto Login`), not `mstsc`.
3. Windows test page: `EPSON` and Brother.
4. SPOT invoice on `EPSON`; sale kicks `CashDrawer`.
5. SPOT report on Brother.
6. Scanner types into SPOT like a keyboard.
7. Browser opens `https://help.spotpos.com` as new tab/home.
8. RustDesk reaches `rustdesk.vogueclean.int`.
9. WinRM from `10.0.253.225` as the admin user.
10. Wallpaper shows Zenith + computer name + `VGCTX03COUNTER1`.

---

## Open on this row (do not invent)

| ID | Blocks USB coding? |
| --- | --- |
| Q-070 computer name | **Answered:** `ZENITH-WS1`. |
| Q-073 account names | **Answered:** `ZenithAdmin` / `ZenithUser`. |
| Q-072 wallpaper layout | No. |
| Q-084 Edge vs Chrome | **Edge.** Lockdown depth still open. |
| Q-074 NAS share | Yes before a real build. |
| Q-071 product key | Yes before a real build. |
| Q-075 UPS percent | No. |

Live WS1 is **not** converted to this recipe until a replacement is built.
