# Desired state: Zenith Video wall

**Status:** draft (Phase 2). Not an installer. **Not** a guarantee of a production-ready USB cutover.  
**Catalog:** `store=zenith`, `register=video-wall`, `runs_spot=false`  
**USB menus:** Store 3 **Zenith** → **Video wall**  
**SPOT `ClientName`:** none  
**Windows computer name:** `Z-SSTATION` (Decision: keep the live names)  
**Live specimen:** `Z-SSTATION` `10.0.253.164` (Win10 Pro 19044) — replace, do not clone.  
**Replacement OS:** Windows 11 Pro. Skip retail OOBE.

Classification: **Requirement** / **Decision** unless labeled Discovery, Hypothesis, or Open question.

---

## What this station is for

Always-on display: Synology Surveillance Station Client camera wall plus a custom **CallerIdOverlay**. **No SPOT.** Auto-logon a standard user.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend. Product key: Open question (Q-071).
2. Pull the secret pack for this row from the NAS (Q-074), including overlay token and SS Client connection (not git).
3. Create accounts, wallpaper, RustDesk, SS Client, CallerIdOverlay logon task.
4. Validate (checklist below). Desktop after reboot with no password typed.

Computer name: **`Z-SSTATION`**.

---

## Accounts

| Role | Live (Discovery) | Desired |
| --- | --- | --- |
| Local admin | `Zenith Admin` (space) | **`ZenithAdmin`** (no space), Administrators |
| Display user | `Zenith User` (space), **already standard** | **`ZenithUser`** (no space), **standard**. Auto-logon **behavior**. Live uses classic `AutoAdminLogon=1` (unlike POS). Mechanism on the new box is our choice. |
| Built-in Administrator | disabled | Stay disabled. |

Do not put the display user in Administrators.

---

## Applications

| App | Desired |
| --- | --- |
| SPOTLauncher / Citrix / `VGCTX` | **Absent** |
| Synology Surveillance Station Client | **2.2.1.2565** (live). Auto-start at logon for `ZenithUser`. Path live: `C:\Program Files\Synology\SynologySurveillanceStationClient`. NAS/camera layout: Open question (Q-082). Installer **not** in controller `vendor-installers/`. |
| CallerIdOverlay | Custom. Scheduled task `\CallerIdOverlay` **At logon** as the display user → `C:\ProgramData\CallerIdOverlay\CallerIdOverlay.exe` (~173 MB on the live box). Config (no token in git): `store_id` **103**, listen **47990**, admin `http://10.0.253.113:8080`, overlay 900×260 top-center, 8s, font 64. Binary and token are **not** on the controller yet. |
| Edge / Chrome lockdown | Not the SPOT shop-floor recipe unless asked. |
| Epson APD / Star / WASP | **Not** this row. |

---

## RustDesk, wallpaper, UPS, WinRM

| Item | Desired |
| --- | --- |
| RustDesk | Installed; **`rustdesk.vogueclean.int`**. |
| Wallpaper (all local users) | Black; text: store **Zenith**, Windows computer name **`Z-SSTATION`**. **No** SPOT id line. Layout still Q-072. |
| UPS | Present. Live has HID battery. Critical action **Shut down**. Percent Q-075. |
| WinRM | HTTP 5985 NTLM to `10.0.253.225/32`, admin only. |

---

## Explicitly out of this row

- SPOT, Citrix, SPOTLauncher
- SPOT Edge-only lockdown
- Cloning the live disk or overlay token into git

---

## Secrets this row needs (existence only)

NAS pack (Q-074): `ZenithAdmin` password, `ZenithUser` auto-logon secret, RustDesk public key, **CallerIdOverlay token**, SS Client NAS/login (Q-082). Layout: [secret-pack.md](secret-pack.md).

---

## Validation (after a future USB build)

1. Reboot: `ZenithUser` desktop, no password prompt.
2. Surveillance Station Client is running (layout still Q-082).
3. CallerIdOverlay is running (task `\CallerIdOverlay`); overlay appears as on the live wall.
4. No SPOT shortcut.
5. RustDesk reaches `rustdesk.vogueclean.int`.
6. WinRM from `10.0.253.225` as `ZenithAdmin`.
7. Wallpaper shows Zenith + `Z-SSTATION` only.

Live `Z-SSTATION` is **not** rebuilt until a replacement is built and tested. Camera layout remains Open (Q-082).
