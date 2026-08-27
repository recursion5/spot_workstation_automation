# Evidence pointer — leftover SPOT driver/font installers and rebuild payloads

- date: 2026-08-27
- class: Discovery
- copied to controller (not git): `/home/grok-agent/spot-discovery/evidence/vendor-installers/`
- checksums file: `SHA256SUMS` in that directory
- overlay token JSON: controller `evidence/secrets/` only (never git)

| File | Size | sha256 | Source |
| --- | --- | --- | --- |
| `APD_511R1_T88V_EWM.zip` | 73717699 | `8fb8a856d27aed7eab19f2712a77372ba8c90d6c2863005881bcccbb8edf516b` | WS2 Downloads |
| `starprnt_v3.8.1.zip` | 263956643 | `caca3dc388823bb24b7d59f448d20e83947490cfe20098323452f2498c34954c` | WS3 Downloads |
| `WASP_Fonts.zip` | 414283 | `ca75b4ab48fa29d2101469f0f7e1597c82fc208403d435982ee238c80f022cc5` | WS2 Downloads |
| `SPOTLauncherSetup_1.1.167.1.exe` | 2167034 | `17a1b53446cb1eabe0d0366ebd1ee64d6b0af30747bc45be70bba4c10bb096f7` | WS2 Downloads (older leftover) |
| `SPOTLauncherSetup_1.1.169.3.exe` | 2168063 | `7fece0a254a8cfe64ce7604590aac41e2c2b646aec951da576c3a35317d15fce` | Operator dropped on share root 2026-08-27; moved to `common/packages/` |
| `SPOTLauncher-1.1.169.3-installed.zip` | 741405 | `8b1a8ea8ce30532a542c83c078097e33e1c2e29d6a939d8bbc87c50b949c2fa9` | WS2 installed AppData tree (backup; prefer the Setup exe) |
| `CitrixWorkspace-26.3.10.69-payload.zip` | 477901421 | `d4c681ce9fd2b17819dd1c140ae28e7f2458446dcddc94513dce668c4d9beeac` | WS2 `Citrix Workspace 26.3.10.69` install-dir payload (not `CitrixWorkspaceApp.exe`) |
| `CallerIdOverlay.exe` | 172971674 | `2cbaae505c506e277f2bf064ea8cd200f2f7e0bf0ef94514c65fe26229a3cdcd` | Z-SSTATION `ProgramData\CallerIdOverlay` |
| `CallerIdOverlay-update.ps1` | 3344 | `08884aa84ad65b8775f3bb7ced4d11cc8a9b346fdceec25af3ae5e12142d9b35` | same folder |

## Gaps (not captured as vendor Setup)

- Official **CitrixWorkspaceApp.exe** bootstrapper: not in Downloads; payload zip is the leftover MSI/CAB set from the installed product.
- Official **SPOTLauncherSetup 1.1.169.3**: **captured** (operator dropped on share root; moved to `common/packages/`). Older 1.1.167.1 leftover kept. Installed-tree zip kept as backup.
- **SS Client 2.2.1.2565** installer: not on disk. Leftover Downloads on Z-SSTATION are **2.0.1-2304** and **2.0.2-2406** only (not copied this pass; still on that PC).

Pack destination: `\\zenith-dsm.vogueclean.int\spot-rebuild` (ADR-0013). Kits copied to `common/packages/` 2026-08-27; SHA-256 matched the controller copies.
