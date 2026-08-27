# Desired state: Zenith Mark-In 1 (front mark-in)

**Status:** draft (Phase 2). Not an installer. **Not** a guarantee of a production-ready USB cutover.  
**Catalog:** `store=zenith`, `register=mark-in-1`, `runs_spot=true`  
**USB menus:** Store 3 **Zenith** → **Mark-In 1 (front mark-in)**  
**SPOT `ClientName`:** `VGCTX03COUNTER2`  
**Windows computer name:** `ZENITH-WS2` (Decision: keep the live names)  
**Live specimen:** `ZENITH-WS2` `10.0.253.205` (Win11 Pro, MINIX NEO Z100-0dB) — replace, do not clone. This PC **is** the Citrix launch-path template (ADR-0012).  
**Replacement OS:** Windows 11 Pro. Skip retail OOBE.

Classification: **Requirement** / **Decision** unless labeled Discovery, Hypothesis, or Open question.

---

## What this station is for

Front mark-in: hosted Xplor Spot, thermal invoices, USB tag printer, Brother reports, HID barcode scanner. **No cash drawer.** Payments stay on an external tokenizing terminal.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend (no “new PC” screens). Product key: Open question (Q-071).
2. Pull the secret pack for this row from the NAS (`dsm.vogueclean.int` / share still Q-074).
3. Create accounts, wallpaper, RustDesk, printers, SPOTLauncher, Citrix Workspace, browser policy.
4. Bind printers to **whatever USB/WSD PnP the new box sees**. Live Tag is `USB002` — do not copy that instance id.
5. Validate (checklist below).

Computer name: **`ZENITH-WS2`**.

---

## Accounts

| Role | Live on WS2 (Discovery) | Desired |
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
| `ConnectionMode` | **0** (Citrix). This live box is the template. |
| `ClientName` | `VGCTX03COUNTER2` |
| `RDGatewayAddress` | `https://rds.mydrycleaner.com` |
| `APIURL` | `https://api.mydrycleaner.com` |
| Desktop shortcut | `SPOT (VGCTX03COUNTER2).lnk`, args `"/launch:SPOT"`, under `ZenithUser` |
| Citrix | **Workspace** (live: `26.3.10.69`), not Receiver 4.9 |
| Session | ICA `wfica32`, published app **`SPOT - Auto Login`** |
| Print | Local Windows printer **names**; Citrix mapping **Hypothesis** until a *new* Citrix box is tested (this PC already works) |

Live `PrintingClientInstallCount` is **1** (Discovery). Recreate `EPSON` + `Tag` (no `CashDrawer`).

---

## Printers and scanner

| Windows name | Role | Driver / port (logical) | Notes |
| --- | --- | --- | --- |
| `EPSON` | Invoice / receipt | EPSON TM-T88V Receipt5, Epson APD5, port `ESDPRT001`, service `PCSVC` | Bind to the new USB TM-T88V. Paper **80×3276**. Do not set as default. |
| `Tag` | Garment tags | Generic / Text Only | Live port `USB002`. Hardware **Hypothesis:** Star SP742 (`VID_0519`). **Not** shared; no `net use` / `Tag Fix.bat` (specimen over vendor USB-tag article). |
| Brother HL-L2380DW series Printer | Reports | WSD / IPP class driver | Re-discover on the LAN. |
| — | Cash drawer | **none** | |

Scanner: USB HID keyboard-wedge. No extra driver.

Vendor kits (same controller copies as Front Counter): **Epson APD 5.11**, **Star PRNT 3.8.1** (USB vendor class **Hypothesis** + full MSI is what they left), **WASP fonts** for `ZenithUser`. See [zenith-front-counter.md](zenith-front-counter.md) and [DISCOVERIES.md](../DISCOVERIES.md) vendor-kit analysis. Installing the zips is necessary, not sufficient: still create named queues and bind new PnP.

---

## Browser, RustDesk, wallpaper, UPS, WinRM

Same as Front Counter except wallpaper SPOT id **`VGCTX03COUNTER2`**. Edge; home/new tab `https://help.spotpos.com`. RustDesk `rustdesk.vogueclean.int`. UPS present (live WS2 CyberPower HID). WinRM HTTP 5985 to `10.0.253.225/32`, admin only.

---

## Explicitly out of this row

- RDS `mstsc` / `ConnectionMode` 1
- `CashDrawer` printer
- Shop-floor user as Administrator
- Cloning USB instance IDs / WSD GUIDs
- SPOTWeb + ConnectLink
- Converting this live PC in place (it already launches Citrix)

---

## Secrets this row needs (existence only)

NAS pack (Q-074), at least: shop-floor auto-logon, local admin, SPOTLauncher/Citrix material for `VGCTX03COUNTER2`, RustDesk public key. Layout: [secret-pack.md](secret-pack.md).

---

## Validation (after a future USB build)

1. Reboot: shop-floor desktop, no password prompt.
2. Shortcut `SPOT (VGCTX03COUNTER2)` opens hosted SPOT via **Citrix** (`wfica32` / `SPOT - Auto Login`).
3. Windows test page: `EPSON`, `Tag`, Brother.
4. SPOT invoice on `EPSON`; SPOT tags on `Tag`; SPOT report on Brother.
5. Scanner types into SPOT like a keyboard.
6. Edge opens `https://help.spotpos.com`.
7. RustDesk reaches `rustdesk.vogueclean.int`.
8. WinRM from `10.0.253.225` as `ZenithAdmin`.
9. Wallpaper shows Zenith + `ZENITH-WS2` + `VGCTX03COUNTER2`.

Live WS2 is **not** rebuilt until a replacement is built and tested.
