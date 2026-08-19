# Discoveries

Directly observed facts, or facts taken from named vendor documentation. Interpretations go under Hypothesis.

## Controller / site network (observed 2026-08-19)

**Class: Discovery (controller host).**

- Controller hostname `utility-agent`, IPv4 `10.0.253.225/24`.
- Gateway `10.0.253.1` reverse-DNS `OPNsense.vogueclean.int`.
- `10.0.253.110` reverse-DNS `zenith-dsm.vogueclean.int`; HTTP banner `nginx`; ports 22, 139, 445, 80, 443, 5357 open. Consistent with a Synology DSM NAS, not a POS PC.
- DNS search/suffix `vogueclean.int`.
- No WinRM listener (TCP 5985/5986) found on ARP neighbors in `10.0.253.0/24`.
- Other neighbors on that subnet answered SSH only (likely other Linux systems).

**Hypothesis (not proven):** POS workstations live on a different VLAN behind OPNsense. A firewall rule will be required for controller → WinRM.

## POS product (vendor documentation)

**Class: Discovery (vendor docs, not yet confirmed on specimen).** Sources: [xplorspot.com/system-requirements](https://xplorspot.com/system-requirements/), [help.spotpos.com](https://help.spotpos.com/llms.txt).

- Product name: Xplor Spot (dry cleaning / laundry POS). Support identity also appears as `spotpos.com`.
- Hosted workstation requirement: Windows 11 Pro or Enterprise.
- Two documented access methods:
  1. **Citrix + SPOTLauncher** — desktop shortcut “SPOT”; SPOTLauncher can install/update the Citrix client; documented launcher version as of the update article: `1.1.169.3`.
  2. **SPOTWeb + ConnectLink** — browser session plus a tray app that bridges printers, scanners, and cash drawers. ConnectLink is bound to a workstation-specific URL and key. SPOTWeb removes the need for Citrix, Receiver/Workspace, and SPOTLauncher.
- Operator expects the specimen to use a Citrix-receiver-style setup. Treat SPOTWeb as possible coexistence, not as the current fact.
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

## Not yet observed on any POS PC

No local inventory, printer list, shortcut target, Citrix product, or auto-logon mechanism has been collected from the specimen.
