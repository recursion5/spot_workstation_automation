# Xplor Spot — public documentation notes

**Class: Discovery from vendor documentation, 2026-08-19. Not specimen inventory.**

Primary sources:

- https://xplorspot.com/system-requirements/
- https://help.spotpos.com/llms.txt
- https://help.spotpos.com/docs/spotweb-overview.md
- https://help.spotpos.com/docs/updating-to-latest-version.md
- https://help.spotpos.com/docs/spot-basic-hardware.md
- https://help.spotpos.com/docs/get-started-with-invoice-printers.md
- https://help.spotpos.com/docs/install-print-manager.md
- https://help.spotpos.com/docs/pci-compliance-information.md

Collectors should look for these names, then record what is actually present.

## Launch components

- `SPOTLauncher` / desktop shortcut `SPOT`
- Citrix Workspace / Receiver / ICA client (updated via launcher)
- SPOTWeb browser URL (Chrome/Edge)
- ConnectLink tray app (`ConnectLinkSetup.msi`), workstation URL + key
- Neodynamic JSPrintManager (Connect / browser printing)

## Printer names and drivers

- Invoice Windows name often `EPSON`; Epson APD from `install.spotpos.com/Drivers/Printers/Epson/` (`APD_456E` older article; **`APD_511R1`** is the article that matches these PCs)
- After APD: paper **80×3276**; do not set as default printer
- Tag Windows name often `Tag`; frequently Generic/Text Only; USB docs require share + `net use LPT1` — **Zenith specimens do not do that**
- Cash drawer Windows name `CashDrawer` (APD_511R1) or `Cash Drawer` (older APD456); port shared with EPSON; no feed/cut; drawer #1 open
- SPOT tag printing documented as LPT1/LPT2 only; Device Name example `Star SP700 (EPOS)`
- Barcode types in SPOT docs: **`128(128L)`**, **`39(39M)`**, I2of5, Code 93 — names match WASP font files
- Driver cache URL pattern: `http://install.spotpos.com/Drivers/...`

## Hardware lists (supported, not necessarily installed)

Invoice: Epson TM-T88V/VI/VII, Star mcPrint3  
Tag: Star SP700, Bixolon SRP-275III, Epson TM-U220b, Zebra GX420t, Zebra ZD621  
Scanners: POS-X ION 2D, Code CR921/CR950, Zebra DS4208, Symbol LI4278/LS4278/LS4208, Honeywell VG1202/VG1452, Socket Mobile DuraScan 700 / CHS 7xi  
Cash drawer: Epson kick-out

## In-app configuration (hosted)

Printer assignment is inside SPOT Program Configuration for the **workstation** object. Local Windows names must match what that hosted config expects. Hosted config will not be fully visible from the PC without the running session; Phase 1 still captures the local side.
