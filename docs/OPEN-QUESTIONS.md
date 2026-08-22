# Open questions

Track unresolved items here and as GitHub issues. Do not answer them in place with guesses.

## Connectivity

| ID | Question | Why it matters | Blocking? |
| --- | --- | --- | --- |
| Q-001 | What is the specimen hostname and IPv4? | **Answered:** `ZENITH-WS3` / `10.0.253.204`. | No |
| Q-002 | Which VLAN/subnet are POS PCs on, and does OPNsense allow 5985 from `10.0.253.225`? | **Answered for this PC:** same subnet `10.0.253.0/24`; no extra firewall rule needed. | No |
| Q-003 | Local admin account name for remoting (workgroup vs domain)? | **Answered for live PCs:** workgroup; remoting user `ZenithAdmin` / `Zenith Admin`. Shop-floor `ZenithUser` is **also an administrator** today. Replacements: admin + standard SPOT user (ADR-0011). Names for new builds still open (Q-073). | No |
| Q-004 | Is the auto-logon standard user already logged on during business hours? | **Answered:** `ZenithUser` was logged on during collection. | No |
| Q-005 | Winlogon `AutoAdminLogon` is `0` and no DefaultPassword is present. How does the desktop return after reboot? | **Closed as a research item.** Operator: reproduce **behavior** only (shop-floor desktop after reboot, no password). Implementation on new builds is our choice. | No |

## Application architecture

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-010 | Is this specimen on Citrix + SPOTLauncher, SPOTWeb + ConnectLink, or both? | **Answered, then refined 2026-08-21.** All three have SPOTLauncher 1.1.169.3. No ConnectLink. **Live mix:** WS1/WS3 launch SPOT via RDS `mstsc`; WS2 via Citrix ICA. Leftover Citrix autostart on WS2/WS3. **Replacement target (ADR-0009):** RDS, not Citrix. |
| Q-011 | Exact Citrix product/version, StoreFront/gateway URL, ICA vs HDX? | **Answered for current PCs.** WS3: Receiver 4.9 LTSR installed, but SPOT is **RDS `mstsc`**. WS2: Workspace **26.3.10.69**, live SPOT is ICA **`wfica32`** / `SPOT - Auto Login`. WS1: `mstsc` only after reboot. Gateway `rds.mydrycleaner.com`. Citrix is leftover on some PCs, not the replacement method. |
| Q-014 | Must existing WS2 be converted from Citrix to RDS before it is replaced, or only new PCs? | Not blocking replacement of WS1. Do not change WS2 in production to experiment. |
| Q-012 | Where is workstation identity stored locally? | Shortcut name `SPOT (VGCTX03COUNTER3)`; launcher under `ZenithAdmin` AppData; args `"/launch:SPOT"`. Still need config files inside SPOTLauncher. |
| Q-013 | Account Key / store / workstation names as used in SPOT | Workstation/`ClientName`: `VGCTXssCOUNTERn`. Hosted Account Key unknown. |

## Peripherals

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-020 | Exact Windows printer names on the specimen? | **Answered:** `Tag`, `EPSON`, Brother HL-L2380DW, Microsoft Print to PDF. No `Cash Drawer`. |
| Q-021 | Tag printer USB vs parallel, and whether `net use LPT1` / `Tag Fix.bat` exists | USB (`USB001` Generic/Text). **No** share, **no** `net use`, **no** `Tag Fix.bat`. Tag print failed during trace; after operator power-cycled the printer, tags came out. Windows queue still showed 0 jobs. |
| Q-025 | After an internet blip, where are unprinted tags held (RDS session, printer buffer, USB stack)? | Operator hypothesis. Needs a future controlled experiment, not a production fix now. |
| Q-022 | Invoice printer model | **Answered:** Epson TM-T88V, Windows name `EPSON`, port `ESDPRT001`. |
| Q-023 | Are barcode scanners HID keyboard-wedge, USB COM, or vendor middleware? | USB HID present (`VID_0536` and others). Confirm with a scan during a trace. |
| Q-024 | This specimen has no cash drawer (operator). Confirm no `Cash Drawer` printer object. | **Answered:** none. |

## Security / collection policy

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-030 | May we install Sysmon with a conservative config? | Level B observation |
| Q-031 | May we run short ProcMon traces around POS launch and a tag/invoice print? | Level C |
| Q-032 | Approved evidence store path (controller disk vs Synology `zenith-dsm` vs other)? | **Partly answered.** Secrets and (likely) build packs live on NAS **`dsm.vogueclean.int`**. Discovery evidence still on the controller. Share path open (Q-074). |

## Identity

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-040 | Operator-facing store id and register id for this specimen? | **Answered 2026-08-21.** Store 3 **Zenith**, workstation **Mark-In 2 (back mark-in)**. Machine ids `store=zenith`, `register=mark-in-2`. SPOT `VGCTX03COUNTER3`. |
| Q-060 | What labels should the USB **store** menu show? | **Answered.** Store 1 Vogue Krum; Store 2 Vogue Denton; Store 3 Zenith. |
| Q-061 | Per-store **workstation** menu labels and `ClientName` map? | **Answered.** Pattern `VGCTXssCOUNTERn`. Operator confirmed the store number after `VGCTX`. Catalog: `config/catalog/workstations.yml`. |
| Q-062 | After the USB choice, is Windows setup fully offline on the stick, or does it pull the rest from the NAS once on the LAN? | **Leaning pull-from-NAS** (secrets must come from there). Still open: what stays on the USB if the NAS is down. |
| Q-063 | SPOT `ClientName` / license names for Vogue Krum and Vogue Denton workstations? | **Answered 2026-08-21.** Operator confirmed store number in the name: Krum `VGCTX01COUNTER1/2`, Denton `VGCTX02COUNTER1/2`. Zenith on disk: `VGCTX03COUNTER1/2/3`. |
| Q-070 | Windows **computer name** pattern on replacements (keep `ZENITH-WS1` style, or derive from store + role)? | Wallpaper and inventory both need a rule. |
| Q-071 | Retail Windows 11 Pro **product key** on new boxes (COA sticker, OEM digital entitlement, or unattend key)? | Skip-OOBE still has to activate. |
| Q-072 | Wallpaper **exact strings** and layout: store menu name vs id; SPOT ID = `VGCTX03COUNTER3` or “Mark-In 2 (back mark-in)”; font/size/position? | Operator: design still to refine. |
| Q-073 | Replacement **account names** (reuse `ZenithAdmin`/`ZenithUser`, store-prefixed, or generic)? | Live mix: POS WS2/WS3 `ZenithAdmin`/`ZenithUser`; WS1 and video wall `Zenith Admin`/`Zenith User` (space). Video wall shop-floor user is **not** admin. Management desk: `Zenith Admin` plus named standard user **Gayla**. Operator: **no Yevhen** on rebuilds. |
| Q-074 | NAS **share path** and how the USB authenticates to read secrets? | `dsm.vogueclean.int` is the host; folder and ACL unknown. Same box as `10.0.253.110` / `zenith-dsm.vogueclean.int`? |
| Q-075 | UPS **critical percent** and action (shut down vs hibernate); vendor software vs Windows HID; sleep-on-battery allowed? | Today: low 10% do nothing, critical 5% **hibernate** on all three; WS1 cannot hibernate. |
| Q-080 | The two extra **non-SPOT** Windows rebuilds: which store, USB menu label, role/purpose, current hostname/IP? | **Answered.** Video wall `Z-SSTATION` / `10.0.253.164`. Management desk `ZENITH-WORKDESK` / `10.0.253.162`. |
| Q-081 | Desired state for non-SPOT PCs besides shared ADR-0011 (apps, printers, auto-logon)? | Video wall: SS Client + auto-logon `Zenith User` (not admin). Management desk: **no** auto-logon; named user **Gayla** (operator: **do not** recreate **Yevhen**). 3CX; Chrome/Acrobat. SS Client installed but unused. |
| Q-082 | Video wall: auto-start Surveillance Station Client, which NAS/cameras, display layout? | Needed for a replacement to come up showing cameras without hand-building. |

## Store hours

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-050 | Weekday and Saturday opening times? | **Answered 2026-08-21.** Weekdays **06:00**, Saturday **08:00** America/Chicago. Morning observe timer follows this. |
| Q-051 | Sunday hours (open time, or closed)? | Timer currently does **not** fire Sunday. |
