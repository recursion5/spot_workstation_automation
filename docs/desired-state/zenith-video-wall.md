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

Always-on display: Synology Surveillance Station Client camera wall plus a custom **CallerIdOverlay**. **No SPOT.** After reboot, nobody types a password: Windows auto-logon, then SS Client auto-starts and auto-logs into the NAS.

---

## Apply after USB identity choice

1. Windows 11 Pro unattend. Product key: OEM/COA (ADR-0013).
2. Pull the pack from `\\zenith-dsm.vogueclean.int\spot-rebuild` (overlay + SS Client settings; DSM password for SS Client in `rows/zenith-video-wall/ss-client/dsm-login.txt`).
3. Create accounts, wallpaper, RustDesk, SS Client, CallerIdOverlay logon task.
4. Recreate SS Client HKCU + Startup shortcut (below). **Do not** import live DPAPI password blobs onto a new PC.
5. Validate (checklist below).

Computer name: **`Z-SSTATION`**.

---

## Accounts

| Role | Live (Discovery) | Desired |
| --- | --- | --- |
| Local admin | `Zenith Admin` (space) | **`ZenithAdmin`** (no space), Administrators |
| Display user | `Zenith User` (space), **already standard** | **`ZenithUser`** (no space), **standard**. Live Windows auto-logon is classic `AutoAdminLogon=1` / `DefaultUserName=Zenith User` / `DisableCAD=1`. Reproduce **behavior**. |
| Built-in Administrator | disabled | Stay disabled. |

Do not put the display user in Administrators.

---

## Surveillance Station Client (Discovery 2026-08-27 + Requirement)

Live: **2.2.1.2565** at `C:\Program Files\Synology\SynologySurveillanceStationClient`. Running as `…\Synology Surveillance Station Client.exe --standalone 0`.

### Auto-start (Windows)

| Item | Live | Desired |
| --- | --- | --- |
| Startup `.lnk` | `C:\Users\Zenith User\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Synology Surveillance Station Client.lnk` | Same under **`ZenithUser`**. Target: SS Client exe. No extra args. Working dir: `…\bin`. |
| App setting | HKCU `RunOnStartup=true` | Same |

### Auto-login (app, not Windows)

HKCU `Software\Synology\Surveillance Station Client` (shop-floor user):

| Value | Live |
| --- | --- |
| `AutoLogin` | `true` |
| `RememberPassword` | `true` |
| `LoginLang` | `enu` |
| `WinGeometry` | `-11,-11,3862,2182` (near-fullscreen on the live display) |
| `EnableGpuDecoder` | `true` |
| `AutoBalance` | `true` |
| `MaxGpuDecoderNum` | `4` |

`LoginHistory` (4 saved servers, same NAS **Zenith-DSM** DS1821+):

| Host | Port | HTTPS | User |
| --- | --- | --- | --- |
| `10.0.253.110` | 9901 | yes | `ATestUserson` |
| `10.0.253.123` | 5000 | no | `mmorris` |
| `zcactus.dyndns.biz` | 9901 | yes | `ATestUserson` |
| `47.190.138.13` | 9901 | yes | `ATestUserson` |

**Primary for the LAN rebuild:** `10.0.253.110:9901` HTTPS as `ATestUserson`.

Passwords in that history are **Windows DPAPI** blobs. They decrypt only for this user on this PC. Importing `ss-client.reg` onto a new box will **not** auto-login until the DSM password is entered once (or the build writes a new Remember-password blob). Live export is on the NAS for reference: `rows/zenith-video-wall/ss-client/`.

Installer for **2.2.1** was not in Downloads (only older 2.0.x). Official setup still missing.

---

## CallerIdOverlay

Scheduled task `\CallerIdOverlay` **At logon** as the display user → `C:\ProgramData\CallerIdOverlay\CallerIdOverlay.exe`. Config: `store_id` **103**, listen **47990**, admin `http://10.0.253.113:8080`, overlay 900×260 top-center, 8s, font 64. Exe is on the controller and NAS; token on NAS only.

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
- Cloning the live disk; putting overlay token or DSM password in git
- Expecting live DPAPI password blobs to work on a new PC

---

## Secrets this row needs (existence only)

NAS `rows/zenith-video-wall/`: `ZenithAdmin` password, `ZenithUser` Windows auto-logon secret, RustDesk public key, CallerIdOverlay token, **DSM password for SS Client** (`dsm-login.txt`). Layout: [secret-pack.md](secret-pack.md).

---

## Validation (after a future USB build)

1. Reboot: `ZenithUser` desktop, no Windows password prompt.
2. Surveillance Station Client starts by itself (Startup `.lnk`).
3. SS Client **auto-logs into** `10.0.253.110:9901` as `ATestUserson` and shows the camera wall (no click through a login dialog).
4. CallerIdOverlay is running (task `\CallerIdOverlay`).
5. No SPOT shortcut.
6. RustDesk reaches `rustdesk.vogueclean.int`.
7. WinRM from `10.0.253.225` as `ZenithAdmin`.
8. Wallpaper shows Zenith + `Z-SSTATION` only.

Live `Z-SSTATION` is **not** rebuilt until a replacement is built and tested. Exact camera grid inside SS Client is whatever the live session had; it was not a separate layout file (settings live in that HKCU key).
