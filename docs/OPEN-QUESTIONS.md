# Open questions

Track unresolved items here and as GitHub issues. Do not answer them in place with guesses.

## Connectivity

| ID | Question | Why it matters | Blocking? |
| --- | --- | --- | --- |
| Q-001 | What is the specimen hostname and IPv4? | **Answered:** `ZENITH-WS3` / `10.0.253.204`. | No |
| Q-002 | Which VLAN/subnet are POS PCs on, and does OPNsense allow 5985 from `10.0.253.225`? | **Answered for this PC:** same subnet `10.0.253.0/24`; no extra firewall rule needed. | No |
| Q-003 | Local admin account name for remoting (workgroup vs domain)? | **Answered:** workgroup; remoting user `ZenithAdmin`. `ZenithUser` is also an administrator. | No |
| Q-004 | Is the auto-logon standard user already logged on during business hours? | **Answered:** `ZenithUser` was logged on during collection. | No |
| Q-005 | Winlogon `AutoAdminLogon` is `0` and no DefaultPassword is present. How does the desktop return after reboot? | **Closed as a research item.** Operator: reproduce **behavior** only (shop-floor desktop after reboot, no password). Implementation on new builds is our choice. | No |

## Application architecture

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-010 | Is this specimen on Citrix + SPOTLauncher, SPOTWeb + ConnectLink, or both? | **Answered, then refined 2026-08-21.** All three have SPOTLauncher 1.1.169.3. No ConnectLink. **Live mix:** WS1/WS3 launch SPOT via RDS `mstsc`; WS2 via Citrix ICA. Leftover Citrix autostart on WS2/WS3. **Replacement target (ADR-0009):** RDS, not Citrix. |
| Q-011 | Exact Citrix product/version, StoreFront/gateway URL, ICA vs HDX? | **Answered for current PCs.** WS3: Receiver 4.9 LTSR installed, but SPOT is **RDS `mstsc`**. WS2: Workspace **26.3.10.69**, live SPOT is ICA **`wfica32`** / `SPOT - Auto Login`. WS1: `mstsc` only after reboot. Gateway `rds.mydrycleaner.com`. Citrix is leftover on some PCs, not the replacement method. |
| Q-014 | Must existing WS2 be converted from Citrix to RDS before it is replaced, or only new PCs? | Not blocking replacement of WS1. Do not change WS2 in production to experiment. |
| Q-012 | Where is workstation identity stored locally? | Shortcut name `SPOT (VGCTX03COUNTER3)`; launcher under `ZenithAdmin` AppData; args `"/launch:SPOT"`. Still need config files inside SPOTLauncher. |
| Q-013 | Account Key / store / workstation names as used in SPOT | Local hint `VGCTX03COUNTER3`. Hosted Account Key unknown. |

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
| Q-032 | Approved evidence store path (controller disk vs Synology `zenith-dsm` vs other)? | Packaging |

## Identity

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-040 | Operator-facing store id and register id for this specimen? | **Answered for this PC:** SPOT license name `VGCTX03COUNTER3`. Store still `unassigned` until a store code is chosen. |

## Store hours

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-050 | Weekday and Saturday opening times? | **Answered 2026-08-21.** Weekdays **06:00**, Saturday **08:00** America/Chicago. Morning observe timer follows this. |
| Q-051 | Sunday hours (open time, or closed)? | Timer currently does **not** fire Sunday. |
