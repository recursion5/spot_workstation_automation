# Desired state: Zenith Management desk

**Status:** draft (Phase 2). Not an installer. **Not** a guarantee of a production-ready USB cutover.  
**Catalog:** `store=zenith`, `register=management-desk`, `runs_spot=false`  
**USB menus:** Store 3 **Zenith** → **Management desk**  
**SPOT `ClientName`:** none  
**Windows computer name:** `ZENITH-WORKDESK` (Decision: keep the live names)  
**Live specimen:** `ZENITH-WORKDESK` `10.0.253.162` (Win10 Pro 19045, MSI Cubi2 MS-B142) — replace, do not clone.  
**Replacement OS:** Windows 11 Pro. Skip retail OOBE.

Classification: **Requirement** / **Decision** unless labeled Discovery, Hypothesis, or Open question.

---

## What this station is for

Office / management PC. Named user **Gayla** signs in interactively. 3CX phone, Chrome, Acrobat. **No SPOT**, no auto-logon, no cash drawer, no tag printer.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend. Product key: Open question (Q-071).
2. Pull the secret pack for this row from `\\zenith-dsm.vogueclean.int\spot-rebuild`.
3. Create accounts, wallpaper, RustDesk, 3CX, Chrome/Acrobat. Do **not** apply the SPOT Edge-only lockdown.
4. Validate (checklist below). Person at the keyboard types Gayla’s password.

Computer name: **`ZENITH-WORKDESK`**.

---

## Accounts

| Role | Live (Discovery) | Desired |
| --- | --- | --- |
| Local admin | `Zenith Admin` (space) | **`ZenithAdmin`** (no space), Administrators |
| Named user | **Gayla** (standard) | **Gayla**, standard. **Interactive logon.** No auto-logon. |
| Yevhen | present on disk | **Do not recreate.** |
| Built-in Administrator | disabled | Stay disabled. |

WinRM as the admin user only.

---

## Applications

| App | Desired |
| --- | --- |
| SPOTLauncher / Citrix / `VGCTX` | **Absent** |
| Chrome | Present (Gayla’s browser). Do not leave OneLaunch, OneBrowser, Cash Catch, or `velis-browser.com` hijacks (cleaned on the live box 2026-08-22; operator confirmed). |
| Adobe Acrobat | Present |
| 3CX Phone | Present; live is in Public Startup. Keep click-to-call unless later told otherwise. |
| Synology SS Client | Live is **installed unused**. **Do not** auto-start it here. |
| Edge | May exist (inbox). Not the locked shop-floor browser. |
| Epson APD / Star / WASP | **Not** this row unless a later inventory shows office printers we must recreate. Live inventory did not list SPOT printers. |

Browser home for Gayla is **not** `help.spotpos.com` unless asked.

---

## RustDesk, wallpaper, UPS, WinRM

| Item | Desired |
| --- | --- |
| RustDesk | Installed; **`rustdesk.vogueclean.int`**. Public key from NAS pack. |
| Wallpaper (all local users) | Black; text: store **Zenith**, Windows computer name **`ZENITH-WORKDESK`**. **No** SPOT id line. Layout still Q-072. |
| UPS | Desired present. Live: **no** HID UPS in Windows. |
| WinRM | HTTP 5985 NTLM to `10.0.253.225/32`, admin only. |
| Bloat | No OneLaunch / extra Store junk / coupon extensions. |

---

## Explicitly out of this row

- SPOT, Citrix, SPOTLauncher, `VGCTX` identity
- Auto-logon
- Recreating **Yevhen**
- SPOT Edge-only lockdown
- Auto-start Surveillance Station Client
- Cloning the Cubi2 disk

---

## Secrets this row needs (existence only)

NAS pack (Q-074): `ZenithAdmin` password, **Gayla** password (no auto-logon secret), RustDesk public key. Layout: [secret-pack.md](secret-pack.md).

---

## Validation (after a future USB build)

1. Reboot: **logon screen**, not an auto-signed-in desktop.
2. Gayla can sign in; Gayla is not an administrator.
3. Yevhen is absent.
4. 3CX starts (or is launchable) as on the live desk.
5. Chrome has no OneLaunch / velis hijack.
6. No SPOT shortcut.
7. RustDesk reaches `rustdesk.vogueclean.int`.
8. WinRM from `10.0.253.225` as `ZenithAdmin`.
9. Wallpaper shows Zenith + `ZENITH-WORKDESK` only.

Live workdesk is **not** rebuilt until a replacement is built and tested.
