# Desired state: Zenith Mark-In 2 (back mark-in)

**Status:** draft (Phase 2). Not an installer. **Not** a guarantee of a production-ready USB cutover.  
**Catalog:** `store=zenith`, `register=mark-in-2`, `runs_spot=true`  
**USB menus:** Store 3 **Zenith** → **Mark-In 2 (back mark-in)**  
**SPOT `ClientName`:** `VGCTX03COUNTER3`  
**Windows computer name:** `ZENITH-WS3` (Decision: keep the live names)  
**Live specimen:** `ZENITH-WS3` `10.0.253.204` (Win11 Pro 26200, MINIX NEO Z100-0dB) — first Phase 1 specimen. Live SPOT is **RDS**; replacement is **Citrix**. Replace, do not clone.  
**Replacement OS:** Windows 11 Pro. Skip retail OOBE.

Classification: **Requirement** / **Decision** unless labeled Discovery, Hypothesis, or Open question.

---

## What this station is for

Back mark-in: hosted Xplor Spot, thermal invoices, USB tag printer (Star SP742), Brother reports, HID barcode scanner. **No cash drawer.** Not customer-facing. Payments stay on an external tokenizing terminal.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend (no “new PC” screens). Product key: Open question (Q-071).
2. Pull the secret pack for this row from `\\zenith-dsm.vogueclean.int\spot-rebuild`.
3. Create accounts, wallpaper, RustDesk, printers, SPOTLauncher, Citrix Workspace, browser policy.
4. Bind printers to **whatever USB/WSD PnP the new box sees**. Live Tag is `USB001` — do not copy that instance id.
5. Validate (checklist below).

Computer name: **`ZENITH-WS3`**.

---

## Accounts

| Role | Live on WS3 (Discovery) | Desired |
| --- | --- | --- |
| Local admin | `ZenithAdmin` | **`ZenithAdmin`**, Administrators |
| Shop-floor | `ZenithUser`, **is** an admin today | **`ZenithUser`**, **standard**. Auto-logon **behavior**: desktop after reboot, no password typed. |
| Built-in Administrator | disabled | Stay disabled. |

Do not reverse-engineer the live `AutoAdminLogon=0` path.

---

## SPOT launch (Decision ADR-0012)

| Item | Value |
| --- | --- |
| Client | SPOTLauncher **1.1.169.3** (or current same product) |
| `ConnectionMode` | **0** (Citrix). Template: WS2, **not** this live RDS box. |
| `ClientName` | `VGCTX03COUNTER3` |
| `RDGatewayAddress` | `https://rds.mydrycleaner.com` |
| `APIURL` | `https://api.mydrycleaner.com` |
| Desktop shortcut | `SPOT (VGCTX03COUNTER3).lnk`, args `"/launch:SPOT"`, under `ZenithUser` |
| Citrix | **Workspace** (live WS2: `26.3.10.69`). Do **not** copy Receiver 4.9 LTSR leftover on this PC. |
| Session | ICA `wfica32`, published app **`SPOT - Auto Login`** |
| Print | Local Windows printer **names**; Citrix mapping **Hypothesis** until first Citrix replacement is tested |

**Do not** use RDS `mstsc` / `ConnectionMode` 1 on the new box. Do not convert live WS3 to Citrix to experiment.

Live `PrintingClientInstallCount` is **1** (Discovery). Recreate `EPSON` + `Tag` (no `CashDrawer`).

Live shortcut target string pointed at a missing ZenithAdmin AppData path; working files were under ZenithUser (Discovery). New shortcut must target the shop-floor launcher install.

---

## Printers and scanner

| Windows name | Role | Driver / port (logical) | Notes |
| --- | --- | --- | --- |
| `EPSON` | Invoice / receipt | EPSON TM-T88V Receipt5, Epson APD5, port `ESDPRT001`, service `PCSVC` | USB TM-T88V `VID_04B8` `PID_0202` on the live box. Paper **80×3276**. |
| `Tag` | Garment tags | Generic / Text Only | Live port `USB001`. USB **Star SP742 (ESP-001)** `VID_0519` `PID_0001` (Discovery). **Not** shared; no `net use` / `Tag Fix.bat` (specimen over vendor USB-tag article). |
| Brother HL-L2380DW series Printer | Reports | WSD / IPP class driver | Re-discover on the LAN. |
| — | Cash drawer | **none** | |

Scanner: USB HID keyboard-wedge `VID_0536`. No extra driver.

Vendor kits: **Epson APD 5.11**, **Star PRNT 3.8.1**, **WASP fonts** for `ZenithUser`. Same controller copies. See [zenith-front-counter.md](zenith-front-counter.md) and [DISCOVERIES.md](../DISCOVERIES.md). Installing zips is necessary, not sufficient.

---

## Browser, RustDesk, wallpaper, UPS, WinRM

Same as Front Counter except wallpaper SPOT id **`VGCTX03COUNTER3`**. Edge; home/new tab `https://help.spotpos.com`. RustDesk `rustdesk.vogueclean.int`. **UPS:** desired present; live WS3 has **no** UPS HID in Windows (repair? Q-075). WinRM HTTP 5985 to `10.0.253.225/32`, admin only.

---

## Explicitly out of this row

- RDS `mstsc` / `ConnectionMode` 1 as the SPOT window (ADR-0012)
- Receiver 4.9 as the Citrix package
- `CashDrawer` printer
- Shop-floor user as Administrator
- Cloning USB instance IDs / WSD GUIDs
- SPOTWeb + ConnectLink
- Converting live WS3 from RDS to Citrix in place

---

## Secrets this row needs (existence only)

NAS pack (Q-074), at least: shop-floor auto-logon, local admin, SPOTLauncher/Citrix material for `VGCTX03COUNTER3`, RustDesk public key. Layout: [secret-pack.md](secret-pack.md).

---

## Validation (after a future USB build)

1. Reboot: shop-floor desktop, no password prompt.
2. Shortcut `SPOT (VGCTX03COUNTER3)` opens hosted SPOT via **Citrix** (`wfica32` / `SPOT - Auto Login`), not `mstsc`.
3. Windows test page: `EPSON`, `Tag`, Brother.
4. SPOT invoice on `EPSON`; SPOT tags on `Tag`; SPOT report on Brother.
5. Scanner types into SPOT like a keyboard.
6. Edge opens `https://help.spotpos.com`.
7. RustDesk reaches `rustdesk.vogueclean.int`.
8. WinRM from `10.0.253.225` as `ZenithAdmin`.
9. Wallpaper shows Zenith + `ZENITH-WS3` + `VGCTX03COUNTER3`.

Live WS3 is **not** converted to this recipe until a replacement is built and tested.
