# Discoveries

Directly observed facts, or facts taken from named vendor documentation. Interpretations go under Hypothesis.

## Controller / site network (observed 2026-08-19)

**Class: Discovery (controller host).**

- Controller hostname `utility-agent`, IPv4 `10.0.253.225/24`.
- Gateway `10.0.253.1` reverse-DNS `OPNsense.vogueclean.int`.
- `10.0.253.110` reverse-DNS `zenith-dsm.vogueclean.int`; HTTP banner `nginx`; ports 22, 139, 445, 80, 443, 5357 open. Consistent with a Synology DSM NAS, not a POS PC.
- DNS search/suffix `vogueclean.int`.
- Earlier ARP scan did not see WinRM. The specimen was later found at `10.0.253.204` on the **same** subnet (see specimen section).

**Superseded hypothesis:** POS PCs are not necessarily on another VLAN. This specimen is on `10.0.253.0/24`.

## POS product (vendor documentation)

**Class: Discovery (vendor docs, not yet confirmed on specimen).** Sources: [xplorspot.com/system-requirements](https://xplorspot.com/system-requirements/), [help.spotpos.com](https://help.spotpos.com/llms.txt).

- Product name: Xplor Spot (dry cleaning / laundry POS). Support identity also appears as `spotpos.com`.
- Hosted workstation requirement: Windows 11 Pro or Enterprise.
- Two documented access methods:
  1. **Citrix + SPOTLauncher** — desktop shortcut “SPOT”; SPOTLauncher can install/update the Citrix client; documented launcher version as of the update article: `1.1.169.3`.
  2. **SPOTWeb + ConnectLink** — browser session plus a tray app that bridges printers, scanners, and cash drawers. ConnectLink is bound to a workstation-specific URL and key. SPOTWeb removes the need for Citrix, Receiver/Workspace, and SPOTLauncher.
- Operator expected a Citrix-receiver-style setup. **Confirmed on the specimen** (see below). No ConnectLink/SPOTWeb client observed in the Level A inventory.
- Workstation selection (Account Key, store, workstation) is part of the hosted application login, not only the Windows hostname.
- SPOT program configuration for printers lives under Setup → Program Configuration → Workstation (printer path, tag printers, cash drawers). That state is **inside the hosted app** and may not exist as a local file.

## Printer contract (vendor documentation)

**Class: Discovery (vendor docs). Confirm names on the specimen before treating them as the local contract.**

- Invoice printers (USB or parallel): Epson TM-T88V/VI/VII, Star mcPrint3. Support often names the Windows printer `EPSON`. Epson Advanced Printer Driver (APD) packages (`APD_456E`, `APD_511R1`) are distributed from `install.spotpos.com`.
- Paper size commonly set to width 80, length 3276.
- Tag printers (USB or parallel): Star SP700 (most common in docs), Bixolon SRP-275III, Epson TM-U220b, Zebra GX420t, Zebra ZD621.
- Tag printer Windows object is commonly named `Tag`, often with `Generic / Text Only`.
- USB tag printers are documented to need printer sharing plus a persistent `net use LPT1 \\%computername%\Tag /P:Y` (desktop `Tag Fix.bat`). SPOT is documented to print tags only to LPT1 or LPT2.
- Cash drawer: typically kicked by the invoice printer. A second Windows printer named `Cash Drawer` shares the Epson port (`Share with EPSON` / `Open before printing`). Specimen is **not** expected to have this.
- Drivers and related packages also appear under `http://install.spotpos.com/Drivers/...`.
- Browser/Connect printing may involve Neodynamic JSPrintManager (`jspm`) for “Connect” — distinct from the Citrix workstation path.

## Payments (operator + vendor)

**Class: Operator-reported, supported by vendor PCI pages pointing at Clearent Protect Payments. Not observed on this specimen.**

- Card data is handled by an external terminal (tokenize/encrypt). Do not expect PAN on the PC.
- This specimen does not take payments.
- Still forbid memory dumps and do not collect PIN material.

### SPOTLauncher settings compared (2026-08-21 evening read)

Same gateway `https://rds.mydrycleaner.com` and API `https://api.mydrycleaner.com` on all three. `ClientName` matches the desktop shortcut.

| PC | ClientName | ConnectionMode | PrintingClientInstallCount | Notes |
| --- | --- | --- | --- | --- |
| WS1 | VGCTX03COUNTER1 | 1 | 2 | Win10; files include `MDCDDC.SPOT - Auto Login.ico` |
| WS2 | VGCTX03COUNTER2 | **0** | 1 | Win11; Citrix Workspace present |
| WS3 | VGCTX03COUNTER3 | 1 | 1 | Win11 |

**Discovery:** `ConnectionMode` 0 launches Citrix ICA; `ConnectionMode` 1 launches RDS (`mstsc`). Count 2 on WS1 may reflect Epson + cash-drawer printer pair.

**Operator (2026-08-21):** stations were mixed (RDS vs Citrix). **Decision (ADR-0012, 2026-08-27):** automated replacements use the **Citrix** path (WS2 template: Workspace, `ConnectionMode` 0, `wfica32`). Do not convert live WS1/WS3 in place. SPOTWeb + ConnectLink is still not the target.

Watchers are running on **all three** PCs. Open times (**operator**): weekdays **06:00**, Saturday **08:00** America/Chicago. Sunday hours unknown. The systemd timer follows those weekday/Saturday times and does not fire Sunday.

### Morning open 2026-08-21 (observer files + live check ~09:20 CDT)

**Class: Discovery.** Timer fired 11:00 UTC (06:00 CDT). All three watchers started `alive=True` and **kept running** (~383 snapshots on WS1/WS2 from overnight through 09:20). Process-start CIM events still only logged watcher restarts, not `mstsc`/`SPOTLauncher` (subscription gap). Snapshots every 2 minutes are the reliable source.

- **WS1 (COUNTER1, cash drawer):** `Zenith User` logged on. New `mstsc` **pid 6168 at 06:05:42 CDT**. Two **older** `mstsc` processes from **2026-08-20 06:07 CDT are still running**. So this station did **not** drop all Remote Desktop clients overnight. No Citrix processes. Printers including `CashDrawer` show 0 jobs at 09:20; cannot see SPOT drawer check-in from Windows.
- **WS2 (COUNTER2):** `ZenithUser` logged on. **No `mstsc`.** Two `SPOTLauncher` processes started **06:06:02 CDT**. Citrix Receiver stack still from boot 2026-08-13. Snapshots could not show `wfica32` (observer regex gap, fixed after the reboot inspect). Consistent with ConnectionMode 0 / Citrix ICA; confirmed on the afternoon reboot.
- **WS3 (COUNTER3):** `ZenithUser` logged on. Same `mstsc` as **2026-08-20 09:59 CDT** still running (no new morning launch by 09:20). Citrix stack from last reboot.

**Hypothesis:** operator “SPOT not left overnight / idle disconnect” is about the **hosted session**, not always the local `mstsc.exe` process. WS1 kept yesterday’s RDP clients and opened another at 06:05.

### Coordinated reboot WS3 (2026-08-21 ~12:13 CDT)

**Class: Discovery.**

- Boot `2026-08-21T17:13:19Z`. Console auto-logon **`ZenithUser`** at 12:13 PM local. No password prompt (operator).
- Yesterday’s leftover `mstsc` is **gone** (reboot cleared it).
- Citrix Receiver stack started ~**17:14:28Z** (about 1 minute after boot, at logon) **before** the successful SPOT window — logon autostart, not the desktop shortcut.
- One `mstsc` **pid 14096 at 17:15:15Z** (~2 minutes after boot).
- **Operator:** first SPOT launch attempt did not show the app; second attempt did. Snapshots are every 2 minutes and did not catch a failed first `SPOTLauncher`/`mstsc`. Hypothesis: first click started something that exited or never showed UI; second click produced the surviving RDP session.
- Boot marker and observer started as `ZENITH-WS3$` (SYSTEM scheduled task). Watcher running after reboot.

### Coordinated reboot WS1 (2026-08-21 ~12:17 CDT)

**Class: Discovery.**

- Boot `2026-08-21T17:17:29Z`. Console auto-logon **`Zenith User`** at 12:17 PM local. No password (operator).
- Yesterday’s leftover `mstsc` processes are **gone**.
- **No Citrix processes** after this reboot (unlike WS3). Epson `PCSVC` + spooler start at boot.
- SmartScreen `17:18:12Z`, then one `mstsc` **pid 9592 at 17:18:41Z** (~72 seconds after boot).
- **Operator:** one double-click of the desktop shortcut; SPOT appeared. Contrasts with WS3 needing two attempts.
- Observer running after reboot (`ZENITH-WS1$` scheduled task).

### Coordinated reboot WS2 (2026-08-21 ~12:22 CDT)

**Class: Discovery.**

- Boot `2026-08-21T17:22:07Z`. Console auto-logon **`ZenithUser`** at 12:22 PM local. No password (operator).
- Yesterday’s leftover processes are **gone**.
- Citrix Workspace stack autostarted at logon (~**17:23:02Z**, ~55 seconds after boot): `concentr` (HKLM Wow6432Node Run), `Receiver.exe -autoupdate -startplugins`, `SelfServicePlugin`, `wfcrun32`, `redirector`. Product path `Citrix Workspace 26.3.10.69`.
- **No `mstsc`.** Live SPOT session is Citrix ICA **`wfica32.exe`** pid 11816 at **17:23:22Z** (~75 seconds after boot). Command line `WFICA32.EXE MFService…`. Parent `wfcrun32`.
- ICA file written **17:23:21Z**: `C:\Users\ZenithUser\AppData\Local\Citrix\SelfService\Temp\MDCDDC.SPOT - Auto Login.ica`. Published app **`SPOT - Auto Login`**. ICA `ClientName=VGCTX03COUNTER2`. AutologonAllowed=ON. (ICA also contains encrypted ticket/password fields; not stored in git.)
- Prefetch `SPOTLAUNCHER.EXE` updated **17:23:25Z** — launcher ran and exited (not still in the process list). Matches operator “SPOT launched” plus `ConnectionMode` 0.
- Observer started as `ZENITH-WS2$` at 17:22:47Z (boot task 12:22:23, logon task 12:22:29, last result 0). First post-reboot snapshot at 17:24:49 listed Receiver/wfcrun32 but **not** `wfica32` because the snapshot regex omitted it.

### WS1 print outage (operator 2026-08-21, invoices + Brother reports)

**Class: Discovery.** Cause still a **hypothesis**, narrowed by operator tests.

Operator: ZENITH-WS1 (Front Counter) cannot print invoices (Epson) or reports (Brother) from SPOT. Jobs never appear in Windows queues. **Windows test pages to both printers succeeded.** **SPOT invoice print from WS3 succeeded.** Usual floor fix is a local reboot (often works); they already rebooted, closed/reopened SPOT, and logged off **inside** SPOT, then relaunched. Problem remained.

Live state after the **second** Windows reboot `2026-08-21T19:56:06Z` (2:56 p.m. CDT):

- Local printers `EPSON`, `CashDrawer`, Brother all `Normal`, 0 jobs. Spooler + Epson `PCSVC` running. USB Epson and Brother WSD present.
- PrintService Operational/Admin empty (jobs from SPOT often never show here even when printing works).
- SPOT RDS: `mstsc -Embedding` to `rds.mydrycleaner.com`. `ClientName` / RDP user `VGCTX03COUNTER1`. `redirectprinters:i:0`; `/rdsvirtualchannel`; loaded `SBSRDPAddin_x64.dll` + ScrewDrivers `sdrdp64.dll`.
- **Re-check 20:28Z after close/reopen and in-app logoff:** still the **same** `mstsc` pid 9836 created **19:56:55Z** (boot). TCP still to `68.220.19.78:443`. Close/reopen did not start a new client process.

**Hypothesis:** Windows and the physical printers are fine. WS3 proves the hosted farm can print. Front Counter uses RDS user `VGCTX03COUNTER1`; **Exit** disconnects and leaves that session; **Logoff** ends it. A PC reboot only drops the local client; the server session can stay disconnected and be reattached.

**Resolution (operator):** SPOT **Logoff** (not Exit), then relaunch. Printing worked. New `mstsc` pid **736** at **20:33:42Z** (old pid 9836 from 19:56:55Z is gone). Why the earlier logoff attempt did not drop `mstsc` is **unknown** (may have been Exit, a cashier-only logoff, or the session did not finish ending before relaunch).

### UPS, RustDesk, wallpaper (read 2026-08-21, no changes)

**Class: Discovery.** WinRM as the admin user (HKCU wallpaper is that admin, not the shop-floor session).

| PC | UPS visible to Windows | Critical battery | RustDesk server in config | Admin HKCU wallpaper |
| --- | --- | --- | --- | --- |
| WS3 Mark-In 2 | **None** (no battery/UPS PnP) | Hibernate at 5%; low 10% do nothing | now `rustdesk.vogueclean.int` (was IP) | Windows Spotlight |
| WS2 Mark-In 1 | HID UPS `VID_0764` (CyberPower) | same | `rustdesk.vogueclean.int` | Spotlight/Iris |
| WS1 Front Counter | APC USB UPS `VID_051D` | same, but **hibernate is not available** on this Win10 box | `rustdesk.vogueclean.int` | default `img0.jpg` |

RustDesk is installed under `C:\Program Files\RustDesk\` with a service and Startup tray. **2026-08-27:** live configs on WS1/WS2/WS3, ZENITH-WORKDESK, and Z-SSTATION now use **`rustdesk.vogueclean.int`** (resolves to `10.0.253.110`); service restarted. Shop-floor wallpaper was not read in this pass.

### Zenith non-SPOT PCs (operator 2026-08-22)

**Class: Requirement** (rebuild) + **Discovery** (video wall live). Both at Zenith. Replacements Windows 11 Pro. No SPOT.

| USB menu | Purpose | Live PC |
| --- | --- | --- |
| Management desk | Management/office | **ZENITH-WORKDESK** `10.0.253.162` |
| Video wall | Synology Surveillance Station Client | **Z-SSTATION** `10.0.253.164` |

#### Management desk ZENITH-WORKDESK (WinRM 2026-08-22)

**Class: Discovery.**

- Windows **10 Pro** build **19045**. Ethernet `10.0.253.162/24`. DNS `ZENITH-WORKDESK.vogueclean.int`.
- Hardware: Micro-Star **KBL-U Pro Cubi2 (MS-B142)**, AMI BIOS 8.60.
- Remoting user **`Zenith Admin`**. Enabled local users also **Gayla** and **Yevhen** (neither is an administrator). **Operator (rebuild):** do **not** recreate Yevhen.
- **PUP cleanup 2026-08-22 (operator-requested):** Gayla profile had **OneLaunch 5.42** (startup updater + tray), **OneBrowser** (scheduled task `OBUpdate` running), desktop/Start Menu shortcuts, and Chrome extension **Cash Catch** (`cjbmfmeflcomeifhpeglfmpgmmhcopdo`). Removed those. Start page was still hijacked via Chrome **Secure Preferences** (`velis-browser.com` labeled as Yahoo). Replaced those URLs; machine policy forces Google search and New Tab (`RestoreOnStartup=5`). **Operator confirmed** Chrome start page is good after that. Left 3CX Click to Call, Adobe Acrobat, Google Docs Offline. Yevhen account still on disk (not deleted).
- Console: **Gayla** logged on (session since 2026-08-04). **No** Winlogon `AutoAdminLogon` / `DefaultUserName` (people sign in). `DisableCAD=1`.
- RustDesk 1.4.9 running; config **`rustdesk.vogueclean.int`**. Chrome, Adobe Acrobat, Edge. **3CX Phone** in Public Startup.
- Synology Surveillance Station Client **is installed** (same 2.2.1 package as the video wall) but **not running** and not in Gayla’s Startup.
- No HID UPS visible to Windows. No SPOT / Citrix / mstsc.

**Hypothesis:** management-desk replacements should keep named standard users (or a generic standard user) with **interactive** logon, not auto-logon. Do not auto-start Surveillance Station Client here unless the operator wants that.

#### Video wall Z-SSTATION (WinRM 2026-08-22)

**Class: Discovery.**

- Windows **10 Pro** build **19044**. Ethernet `10.0.253.164/24`. DNS `Z-SSTATION.vogueclean.int`.
- Remoting user **`Zenith Admin`** (space), same pattern as WS1. Shop-floor **`Zenith User` is not an administrator** (unlike the POS PCs).
- Console: `Zenith User` logged on. Winlogon **`AutoAdminLogon=1`**, `DefaultUserName=Zenith User`, `DisableCAD=1` (classic auto-logon; POS PCs had AutoAdminLogon=0).
- **Synology Surveillance Station Client 2.2.1.2565** at `C:\Program Files\Synology\SynologySurveillanceStationClient`, running, in Zenith User Startup.
- **Caller ID overlay (custom):** **not** in Startup folder or Run keys. Scheduled task `\CallerIdOverlay` **At logon** as `Zenith User` → `C:\ProgramData\CallerIdOverlay\CallerIdOverlay.exe` (v1.0.0.0, ~173 MB, last written 2026-08-19). Process running. Config (no token in git): `store_id` 103, listen port 47990, admin UI `http://10.0.253.113:8080`, overlay 900×260 top-center, 8s, font 64. First inventory missed this because it only listed Win32_StartupCommand.
- RustDesk 1.4.9; config **`rustdesk.vogueclean.int`** as of 2026-08-27.
- HID UPS battery present. BIOS American Megatrends 5.13; board strings empty (“Default string”).
- No SPOT / Citrix / mstsc.

**Hypothesis:** video-wall replacements should auto-logon a standard user and start Surveillance Station Client. Management desk still unknown.

### Store and workstation catalog (operator 2026-08-21)

**Class: Requirement (labels) + Discovery (Zenith ClientName map).** Source: `config/catalog/workstations.yml`.

| Store # | Store menu | Workstation menu | Live PC (Discovery) | `ClientName` |
| --- | --- | --- | --- | --- |
| 1 | Vogue Krum | Front Counter (cash drawer) | not inventoried | `VGCTX01COUNTER1` |
| 1 | Vogue Krum | Mark-In | not inventoried | `VGCTX01COUNTER2` |
| 2 | Vogue Denton | Front Counter (cash drawer) | not inventoried | `VGCTX02COUNTER1` |
| 2 | Vogue Denton | Mark-In | not inventoried | `VGCTX02COUNTER2` |
| 3 | Zenith | Front Counter (cash drawer) | ZENITH-WS1 | `VGCTX03COUNTER1` |
| 3 | Zenith | Mark-In 1 (front mark-in) | ZENITH-WS2 | `VGCTX03COUNTER2` |
| 3 | Zenith | Mark-In 2 (back mark-in) | ZENITH-WS3 | `VGCTX03COUNTER3` |

Zenith mapping is operator 1/2/3 plus peripherals: only WS1 has `CashDrawer` and no `Tag`; WS2/WS3 have `Tag` and no cash drawer; WS3 was the non-customer-facing specimen (back mark-in). **Decision (operator-confirmed):** license names are `VGCTXssCOUNTERn` (store number after `VGCTX`). Live Zenith files match `03`. Vogue `01`/`02` follow the same rule; those PCs have not been read on disk.

### Coordinated reboot comparison (2026-08-21)

| PC | Boot (UTC) | Auto-logon | Citrix at logon | SPOT session | Operator |
| --- | --- | --- | --- | --- | --- |
| WS3 | 17:13:19 | `ZenithUser` | Receiver stack | `mstsc` ~17:15:15 | two clicks |
| WS1 | 17:17:29 | `Zenith User` | none | `mstsc` ~17:18:41 | one double-click |
| WS2 | 17:22:07 | `ZenithUser` | Workspace stack | **`wfica32` ~17:23:22** | SPOT launched |

## Other Zenith PCs (access in progress)

- **ZENITH-WS2** (USB: **Mark-In 1 (front mark-in)**) `10.0.253.205`: WinRM works as `ZenithAdmin`. Windows 11 Pro, same MINIX NEO Z100-0dB. Shortcut `SPOT (VGCTX03COUNTER2).lnk`. Printers `Tag` (USB002), `EPSON` TM-T88V, Brother. No `Cash Drawer` printer. Citrix **Workspace 26.3.10.69** (WS3 has Receiver 4.9 LTSR). Post-reboot SPOT is ICA `wfica32` / published app `SPOT - Auto Login`, not `mstsc`. `ZenithUser` is logged on and is an administrator.
- **ZENITH-WS1** (USB: **Front Counter (cash drawer)**) `10.0.253.212`: WinRM works as **`Zenith Admin`** (space in the name; same password as the other Zenith PCs). Windows **10 Pro** build **17763** (version 1809). Hardware **MINIX N42C-4** (older than the NEO Z100 boxes). Shortcut `SPOT (VGCTX03COUNTER1).lnk`. Printers: `EPSON` TM-T88V, **`CashDrawer`** on the same Epson port, Brother. **No `Tag` printer.** SPOTLauncher 1.1.169.3 under `Zenith User` AppData. Citrix folder present. Shop-floor account `Zenith User` (space) is an administrator. **Best first replacement candidate** (old OS + old hardware + cash drawer).

## Specimen ZENITH-WS3 (observed 2026-08-19, run `20260819T203635Z-43b3934a`)

**Class: Discovery** unless labeled otherwise. Collected over WinRM as `ZenithAdmin` while `ZenithUser` was logged on.

### Computer

- Hostname `ZENITH-WS3`, workgroup (not a domain).
- Windows 11 Pro build 26200.
- Hardware: MINIX Technology Limited **NEO Z100-0dB**.
- Ethernet IPv4 `10.0.253.204/24`.

### Accounts

- Enabled local users: `ZenithUser`, `ZenithAdmin`. Built-in `Administrator` is disabled.
- Administrators group contains `Administrator` (disabled), `ZenithAdmin`, and `ZenithUser`.
- Shop-floor session: `ZENITH-WS3\ZenithUser`.
- Winlogon: `DefaultUserName=ZenithUser`, `AutoAdminLogon=0`, no `DefaultPassword` value present.
- **Open question:** operator described auto-logon after reboot. The registry currently does not enable classic Winlogon auto-logon. The desktop may simply stay logged on, or another mechanism exists.
- **Operator decision (2026-08-21):** do **not** reverse-engineer the old auto-logon implementation. New builds only need the **behavior**: shop-floor user at the desktop after reboot with no password typed. Mechanism on new PCs is our choice.
- **Operator on cash drawer:** drawer **check-in** (counting money, closing the drawer) will not show up in Windows print logs. The thermal printer **kick** only happens when a customer transaction needs the drawer open (standard Epson POS pulse on WS1 `CashDrawer` / `ESDPRT001`). **2026-08-22:** do **not** capture a live sale for this; it would not change the replacement design. Scanners at all stations are the same HID wedge as WS3.

### Reboot test (2026-08-20 ~00:53Z)

**Class: Discovery.**

- `LastBootUpTime` 2026-08-20T00:53:32Z. This was a real reboot, not just a sleep.
- Console session after boot: **`ZenithUser`**. Local accounts are `ZenithUser` and `ZenithAdmin` (plus disabled built-ins). No `VogueUser` on this PC.
- **Operator correction:** “Vogue” is a **different store** (two Vogue locations and one Zenith). This specimen is the Zenith store. Shop-floor account here is `ZenithUser`.
- **Operator-reported operations:** SPOT is **not** left running overnight on any Zenith workstation. The hosted session also **auto-disconnects after idle**. Morning activity (especially WS1/WS2) starts when staff launch SPOT again, not from a leftover overnight session. Idle timeout length is not yet measured.

### Live check 2026-08-20 ~20:12 CDT (observer file log failed)

The 06:00 CDT systemd job **did start** watchers on WS1/WS2, but they did not write snapshot files (tooling bug). A live process check later the same day still showed:

- **WS1** `Zenith User` logged on. Two `mstsc.exe` since **06:07 CDT** (11:07 UTC). No Citrix processes. Epson `PCSVC` + spooler from last boot (2026-08-13). Matches RDS launch at open on the cash-drawer station.
- **WS2** `ZenithUser` logged on. No `mstsc` at 20:12 CDT (SPOT likely closed / idle-disconnected). Citrix Receiver stack running since boot 2026-08-13.
- **WS3** `ZenithUser` logged on. `mstsc` since **09:59 CDT**. Citrix stack since last night’s reboot.
- Winlogon still `AutoAdminLogon=0` and no `DefaultPassword` registry value. `DisableCAD=1` (no Ctrl+Alt+Del). Auto-logon happened anyway.
- **Hypothesis:** automatic sign-in is stored somewhere other than the classic `AutoAdminLogon=1` + visible DefaultPassword (for example LSA secrets / netplwiz). Not proven.
- Remote access as `ZenithAdmin` came back after the reboot without re-running the setup script. (WinRM took about a minute to accept connections.)

### Launch path

- Desktop shortcut: `C:\Users\ZenithUser\Desktop\SPOT (VGCTX03COUNTER3).lnk` with arguments `"/launch:SPOT"`.
- **SPOTLauncher 1.1.169.3** lives at `C:\Users\ZenithUser\AppData\Local\SBS\SPOTLauncher\` (exe, `settings.json`, `apps.json`). The `.lnk` target string still points at a **ZenithAdmin** AppData path that **does not exist** on disk. Hypothesis: stale shortcut target; the working files are under ZenithUser.
- `settings.json` (no password fields):
  - `ClientName`: `VGCTX03COUNTER3`
  - `RDGatewayAddress`: `https://rds.mydrycleaner.com`
  - `APIURL`: `https://api.mydrycleaner.com`
  - `ConnectionMode`: `1`
- `apps.json` publishes RemoteApp **SPOT** via RDS, not an `.ica` file:
  - Brokers: `MDCRDCB01/02/03.MYDRYCLEANER.COM` (`full address` `RDCB.MYDRYCLEANER.COM`)
  - Gateway: `rds.mydrycleaner.com`
  - RDP username: `VGCTX03COUNTER3`, domain `mydrycleaner.com`
  - RemoteApp program `||spot`, command line `/autologin /useaduser /rdsvirtualchannel`
  - `redirectprinters:i:0` (RDP printer redirection off), COM port redirection on
- **Citrix Receiver 4.9 LTSR** `14.9.9002.6` is also installed and running (`Receiver.exe`, `wfcrun32.exe`, `redirector.exe`, `SelfServicePlugin.exe` since 2026-08-07). No ConnectLink/SPOTWeb package observed.
- **Hypothesis:** this station uses SPOTLauncher → RDS RemoteApp as the employee launch path. Citrix Receiver is present (legacy or still used for something else). A short launch trace is required to see which process actually starts after the double-click.
- No `.ica` files found in the searched trees.

### Printers and USB

| Windows name | Driver | Port |
| --- | --- | --- |
| `Tag` | Generic / Text Only | `USB001` |
| `EPSON` | EPSON TM-T88V Receipt5 | `ESDPRT001` |
| Brother HL-L2380DW series Printer | Microsoft IPP Class Driver | WSD-… |
| Microsoft Print to PDF | Microsoft Print To PDF | `PORTPROMPT:` |

- No Windows printer named `Cash Drawer` (matches operator: this PC is not customer-facing).
- `Tag` is **not** shared. No `net use` LPT mapping and no `Tag Fix.bat` found. That **disagrees** with SPOT vendor USB-tag instructions. Hypothesis: this station prints tags via USB001 Generic/Text, or the hosted app/Citrix path does not need LPT1 here.
- USB device **Star SP742 (ESP-001)** (`USB\VID_0519&PID_0001`) is present. Hypothesis: this is the tag printer hardware (vendor docs mention Star SP700 more often; SP742 is a related Star impact printer).
- USB device **EPSON USB Controller for TM/BA/EU Printers** (`USB\VID_04B8&PID_0202`) is present. Maps to the `EPSON` logical printer via Epson APD5 virtual port `ESDPRT001` (hypothesis until a print trace).
- Epson APD5 5.11.1.0 and TM-T88V utility installed.
- Star Micronics Printer Software 3.8.1 installed.
- **Leftover SPOT vendor installers in Downloads (2026-08-27):** not previously inventoried as a kit. WS2: `APD_511R1_T88V_EWM.zip`, `WASP_Fonts.zip` (49 barcode/MICR `.ttf`), `SPOTLauncherSetup_1.1.167.1.exe`. WS3: `starprnt_v3.8.1.zip`. **Copied to controller** `spot-discovery/evidence/vendor-installers/` (hashes in `vendor-installers.pointer.md`). Installed Add/Remove products were already in Level A. WASP fonts are **per-user** for the shop-floor account (`AppData\Local\Microsoft\Windows\Fonts`, ~30 of 49 files) on WS1/WS2/WS3; not in `C:\Windows\Fonts`. Rebuilds must **install these packages**, not only create printer objects. Other Downloads leftovers (LogMeIn Rescue, TeamViewer Host setup, RustDesk MSI, a payment-receipt PDF) are not rebuild kits and were not copied.

### Vendor kit analysis (2026-08-27): what is needed vs “just install the zip”

**Class: Discovery** unless labeled Hypothesis. Sources: leftover zips + READMEs, live ARP/printers/fonts, SPOT public setup articles (`APD_511R1`, basic hardware, cash drawers, barcode types).

**Running the leftover installers is not enough** for SPOT to print on a new PC. The zips are driver/font *payloads*. SPOT’s own setup still creates named Windows printer objects, binds the USB the new box sees, sets paper/drawer options, then points the **hosted** workstation object (`VGCTX03COUNTERn`) at those Windows names. A replacement that keeps the same `ClientName` can reuse the hosted printer paths **if** the local names match. A next-next wizard click is not a silent `msiexec`.

| Package | Needed portion | Why | Likely extra in the zip / ARP |
| --- | --- | --- | --- |
| Epson `APD_511R1_T88V.exe` | APD5 Windows driver **EPSON TM-T88V Receipt5**, Port Communication Service (`PCSVC`), virtual port `ESDPRT001`, printer objects **`EPSON`** and (Front Counter) **`CashDrawer`** | SPOT invoices go to Windows name `EPSON`. Drawer kick is a second APD queue on the **same** port (SPOT: name `CashDrawer`, share with EPSON, no feed/cut, drawer #1 open). Paper **80×3276**. Live WS1 matches this. | TM Bluetooth Connector, TM Coupon Package, TM-T88V Utility, StatusAPI manuals. Present in ARP; no evidence SPOT uses Bluetooth or coupons on these PCs. **Hypothesis:** wizard side effects. |
| `starprnt_v3.8.1` (~252 MB) | **Hypothesis:** Star **USB vendor class** (`SMJUSBCOM`) so a USB Star SP742 shows a `USB00n` port that Generic/Text can bind. Full MSI is what they left installed (`Star Micronics Printer Software Ver3.8.1`). | Live **Tag** printer is **Generic / Text Only**, not a Star Windows driver (matches SPOT tag article). Hardware is Star SP742. Front Counter has **no Tag** — this kit is not required on that row. | OPOS, Star Cloud, Bluetooth utility, firmware docs, Windows drivers for FVP10/TSP/TUP, .NET 4.5.1 redistributable inside the zip. Silent MSI: `msiexec /i PrinterSoftware-3.8.1-…-x64.msi /qn` (vendor README). |
| `WASP_Fonts.zip` | Subset already on all three POS shop-floor profiles: Code **39 / 93 / 128**, Codabar, MICR, OCR-A/B, UPC (~30 of 49 files). | SPOT’s barcode article names types **`128(128L)`** and **`39(39M)`**, which match WASP filenames `w128l.ttf` / `w39m.ttf`. Fonts are per-user, not `C:\Windows\Fonts`. **Hypothesis:** invoice/report barcodes render as TrueType through the Windows print path (Citrix/APD), so the shop-floor session must see those fonts. | I2of5, LOGMARS, MSI, POSTNET files are in the zip but **not** installed locally. SPOT documents I2of5; this store may not use it. Tags observed as raw escape sequences, not GDI fonts. |
| `SPOTLauncherSetup_1.1.167.1.exe` | Do **not** prefer this build. Live is **1.1.169.3**. | Launcher + `ClientName` / `ConnectionMode` 0 + Citrix Workspace is how SPOT opens. Unrelated to creating printers. | Older leftover. |

SPOT tag article also wants the `Tag` queue **shared** plus `net use LPT1 \\%computername%\Tag /P:Y` (`Tag Fix.bat`). **Specimen disagrees:** WS2/WS3 Tag is USB Generic/Text, **not shared**, no `net use`. Prefer the specimen. Citrix/ScrewDrivers mapping of those local names is still **Hypothesis** until the first Citrix replacement is tested.

Windows test page after APD/`Tag`/Brother ≠ SPOT print. Hosted session must see the same names; if invoices fail while test pages work, SPOT **Logoff** then relaunch (already observed on WS1).
- HID USB devices include `VID_0536` (typical handheld barcode vendor) and keyboard/mouse-class devices. Hypothesis: at least one USB barcode scanner is attached.

### Operator workflow trace (2026-08-20, run `20260820T001911Z-9af4f7de`)

**Class: Discovery.** Window 00:19:11Z–00:28:22Z. Operator ran launch / print / scan / relaunch. Tag print failed; operator did not reboot or change settings.

- At 00:21:29Z Windows SmartScreen started; at 00:21:33Z **`mstsc.exe`** (Remote Desktop client) started. This matches SPOTLauncher RDS RemoteApp, not a new Citrix ICA process.
- `SPOTLauncher.exe` was not still running at stop. Hypothesis: launcher starts `mstsc` and exits.
- Citrix `Receiver.exe` / `wfcrun32.exe` were already running since 2026-08-07; they did not start during this workflow.
- Windows PrintService Operational log had **no** events in the window. Tag printer ended `Normal`, 0 jobs. No leftover stuck job.
- Application log Universal Print: spooler job **56** completed 00:26:58Z under `ZenithUser`, with `opc-life-over-warning` (photoconductor-style warning → likely the **Brother** laser, not the Epson thermal).
- Process-create watcher log was not produced (tooling gap). Procmon backing file remains on the PC (`procmon.pml`, 128 MB allocated) for later analysis; not copied into git.

**Hypothesis:** tag printing often never reaches a completed Windows spooler job. Failure is consistent with a hosted-app or USB/raw path, not a queue sitting on the PC afterward.

**Operator-reported after the recording stopped (not captured in the trace):**

- Power-cycled the tag printer (not the PC). Tags then printed. Operator says this is common.
- Operator hypothesis: a brief site internet drop a few minutes earlier caused it.

**Class: Discovery (read-only check after that power cycle):** Tag still `Normal` / 0 jobs; PrintService Operational still had no new events. USB view: Star SP742 OK on `USB001`; another Star SP742 instance `Unknown` on `USB002`.

**Hypothesis:** jobs were held in the hosted SPOT/RDS session and/or the printer’s own buffer, not in the Windows queue we can see. An internet blip can stall RDS RemoteApp (`mstsc`); power-cycling the printer is a local workaround. Not proven that the disconnect was the cause; it is a plausible explanation and matches “happens on occasion.”

### Successful tag print (2026-08-20, run `20260820T004656Z-0053f8c4`)

**Class: Discovery.** Operator printed one order; **5 tags** came out (order required 5). Network was stable. Recording stopped immediately after.

- Windows PrintService Operational again had **no** events in the window.
- Tag printer afterward: `Normal`, 0 jobs.

**Hypothesis:** even a successful tag run does not show up as a normal Windows print-queue job. Tags likely go through SPOT/RDS and then the USB Star as raw/Generic-Text, not through PrintService Operational.

### What remains unknown

- Exact Citrix store/gateway URL and how `VGCTX03COUNTER3` is assigned.
- Hosted SPOT Program Configuration (printer names inside the app).
- Whether tag printing actually uses `USB001` without LPT1.
- Auto-logon after a real reboot.
- Launch process tree (needs a short trace around double-clicking the SPOT shortcut).
