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
- HID USB devices include `VID_0536` (typical handheld barcode vendor) and keyboard/mouse-class devices. Hypothesis: at least one USB barcode scanner is attached.

### What remains unknown

- Exact Citrix store/gateway URL and how `VGCTX03COUNTER3` is assigned.
- Hosted SPOT Program Configuration (printer names inside the app).
- Whether tag printing actually uses `USB001` without LPT1.
- Auto-logon after a real reboot.
- Launch process tree (needs a short trace around double-clicking the SPOT shortcut).
