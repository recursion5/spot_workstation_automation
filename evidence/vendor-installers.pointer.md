# Evidence pointer — leftover SPOT driver/font installers

- date: 2026-08-27
- class: Discovery
- copied to controller (not git): `/home/grok-agent/spot-discovery/evidence/vendor-installers/`
- checksums file: `SHA256SUMS` in that directory

| File | Size | sha256 | Found on |
| --- | --- | --- | --- |
| `APD_511R1_T88V_EWM.zip` | 73717699 | `8fb8a856d27aed7eab19f2712a77372ba8c90d6c2863005881bcccbb8edf516b` | WS2 `C:\Users\ZenithUser\Downloads\` |
| `starprnt_v3.8.1.zip` | 263956643 | `caca3dc388823bb24b7d59f448d20e83947490cfe20098323452f2498c34954c` | WS3 `C:\Users\ZenithUser\Downloads\` |
| `WASP_Fonts.zip` | 414283 | `ca75b4ab48fa29d2101469f0f7e1597c82fc208403d435982ee238c80f022cc5` | WS2 Downloads (49 `.ttf`) |
| `SPOTLauncherSetup_1.1.167.1.exe` | 2167034 | `17a1b53446cb1eabe0d0366ebd1ee64d6b0af30747bc45be70bba4c10bb096f7` | WS2 Downloads (older than live **1.1.169.3**) |

## What is inside (catalog only)

- **APD:** `APD_511R1_T88V.exe`, `APD5_MAN_T88V_EN_F.exe`, `APD5_Install_en_revG.pdf`, `APD5_README_EN.TXT`. Matches installed **EPSON Advanced Printer Driver for TM-T88V Ver.5 5.11.1.0**.
- **Star PRNT 3.8.1:** `setup/Setup.exe`, x86/x64 `PrinterSoftware-3.8.1-*.msi`, USB vendor class `SMJUSBCOM.inf`, Star-SP700 and other Windows drivers. Live tag printer object is still **Generic/Text**, not the Star Windows driver.
- **WASP fonts:** 49 TrueType files (`w39*`, `w93*`, `w128*`, `wcb*`, `wi2o5*`, `wlog*`, `wmicr`, `wmsi*`, `wocr*`, `wpost`, `wupc*`).

## How they are installed today (Discovery)

- Epson APD5, TM-T88V utility, Port Communication Service, Star Micronics Printer Software 3.8.1: **Add/Remove Programs** (already in Level A `uninstall.json`).
- WASP fonts: **per-user** under `...\AppData\Local\Microsoft\Windows\Fonts\` for the shop-floor account (`ZenithUser` / `Zenith User`) on WS1, WS2, and WS3. Not in `C:\Windows\Fonts`. Subset installed (~30 of 49; I2of5 / LOGMARS / MSI / POSTNET files from the zip are not present).
- WS1 Downloads no longer had the vendor zips (only our bootstrap script).

Do not git the binaries. Copy onto the NAS (Q-074) for the USB build. Silent/unattend switches are not extracted yet.

Leftovers **not** treated as rebuild packages: LogMeIn Rescue, TeamViewer Host setup, RustDesk MSI copies, SPOT payment-receipt PDFs (not copied).
