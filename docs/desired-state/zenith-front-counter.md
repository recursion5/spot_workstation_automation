# Desired state: Zenith Front Counter (cash drawer)

**Status:** draft (Phase 2). Not an installer.  
**Catalog:** `store=zenith`, `register=front-counter`, `runs_spot=true`  
**USB menus:** Store 3 **Zenith** → **Front Counter (cash drawer)**  
**SPOT `ClientName` / RDS user:** `VGCTX03COUNTER1`  
**Live specimen:** `ZENITH-WS1` `10.0.253.212` (Win10 Pro 17763, MINIX N42C-4) — replace, do not clone.  
**Replacement OS:** Windows 11 Pro. Skip retail OOBE.

Classification: **Requirement** / **Decision** unless labeled Discovery, Hypothesis, or Open question.

---

## What this station is for

Customer-facing register: hosted Xplor Spot, thermal invoices, cash-drawer kick through the Epson, Brother reports, HID barcode scanner. **No tag printer.** Payments stay on an external tokenizing terminal.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend (no “new PC” screens). Product key: Open question (Q-071).
2. Pull the secret pack for this row from the NAS (`dsm.vogueclean.int` / share still Q-074). Do not bake passwords into the USB.
3. Create accounts, wallpaper, RustDesk, printers, SPOTLauncher, browser policy.
4. Bind printers to **whatever USB/WSD PnP the new box sees**. Do not copy `USB001` or WSD GUIDs from WS1.
5. Validate (checklist below). Staff: desktop → SPOT shortcut; shop-floor user already signed in.

Computer name: **Open question (Q-070)**. Live name `ZENITH-WS1` is hardware history, not a requirement.

---

## Accounts

| Role | Live on WS1 (Discovery) | Desired |
| --- | --- | --- |
| Local admin (WinRM, RustDesk admin) | `Zenith Admin` (space) | One local **Administrators** account. Exact name: Open question (Q-073). |
| Shop-floor | `Zenith User` (space), **is** an admin today | One local **standard** (non-admin) user. Auto-logon **behavior**: desktop after reboot, no password typed. Mechanism is our choice (video wall already uses `AutoAdminLogon=1`). |
| Built-in Administrator | disabled | Stay disabled. |

Do not put the shop-floor user in Administrators. Do not reverse-engineer WS1’s `AutoAdminLogon=0` path.

---

## SPOT launch (Decision ADR-0009)

| Item | Value |
| --- | --- |
| Client | SPOTLauncher **1.1.169.3** (or current vendor build of the same product) |
| `ConnectionMode` | **1** (RDS). Not 0 / Citrix. |
| `ClientName` | `VGCTX03COUNTER1` |
| `RDGatewayAddress` | `https://rds.mydrycleaner.com` |
| `APIURL` | `https://api.mydrycleaner.com` |
| Desktop shortcut | `SPOT (VGCTX03COUNTER1).lnk`, args `"/launch:SPOT"`, under the shop-floor profile |
| RemoteApp | `||spot`, cmdline `/autologin /useaduser /rdsvirtualchannel` |
| RDP user | `VGCTX03COUNTER1` @ `mydrycleaner.com` |
| `redirectprinters` | `0` |
| Print path | SBSRDPAddin + ScrewDrivers to **local Windows printer names** |

**Do not install** Citrix Receiver, Workspace, or ICA.

`PrintingClientInstallCount` on the live box is **2** (Discovery: Epson + CashDrawer pair). Recreate that pair, not the integer for its own sake.

SPOT-related secrets (RDS password, ScrewDrivers if any, launcher crypto) come from the NAS pack. Not git.

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

---

## Browser (SPOT shop-floor only)

**Requirement:** exactly **one** browser on the standard-user profile.

| Setting | Value |
| --- | --- |
| Home / default / new tab | `https://help.spotpos.com` |
| Search provider | Controlled (Google unless later specified) |
| Extra browsers, coupon extensions, OneLaunch | Absent |

Which product (Edge vs Chrome) and further lockdown: Open question (Q-084). Do not apply this recipe to Gayla’s desk unless asked.

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

- Citrix / ICA / `ConnectionMode` 0
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
- Hosted RDS / SPOTLauncher secret for `VGCTX03COUNTER1`
- RustDesk public key (and ID if we pre-register)
- ScrewDrivers license if required

---

## Validation (after a future USB build)

1. Reboot: shop-floor desktop, no password prompt.
2. Shortcut `SPOT (VGCTX03COUNTER1)` opens hosted SPOT via `mstsc` (no Citrix).
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
| Q-070 computer name | No for a first draft; yes before unattend hostname. |
| Q-073 account names | Prefer a decision before the first stick. |
| Q-072 wallpaper layout | No. |
| Q-084 Edge vs Chrome + lockdown depth | Prefer a decision before the first stick. |
| Q-074 NAS share | Yes before a real build. |
| Q-071 product key | Yes before a real build. |
| Q-075 UPS percent | No. |

Live WS1 is **not** converted to this recipe until a replacement is built.
