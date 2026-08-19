# Open questions

Track unresolved items here and as GitHub issues. Do not answer them in place with guesses.

## Connectivity

| ID | Question | Why it matters | Blocking? |
| --- | --- | --- | --- |
| Q-001 | What is the specimen hostname and IPv4? | WinRM target | Yes |
| Q-002 | Which VLAN/subnet are POS PCs on, and does OPNsense allow 5985 from `10.0.253.225`? | Path from controller | Yes |
| Q-003 | Local admin account name for remoting (workgroup vs domain)? | Auth | Yes |
| Q-004 | Is the auto-logon standard user already logged on during business hours? | User-hive collection | No |

## Application architecture

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-010 | Is this specimen on Citrix + SPOTLauncher, SPOTWeb + ConnectLink, or both? | Launch-path collectors |
| Q-011 | Exact Citrix product/version, StoreFront/gateway URL, ICA vs HDX? | Reproduce launch |
| Q-012 | Where is workstation identity stored locally (shortcut args, ICA file, registry, ConnectLink key, launcher config)? | Station replacement |
| Q-013 | Account Key / store / workstation names as used in SPOT (pseudonymize in git-safe output) | Identity model |

## Peripherals

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-020 | Exact Windows printer names on the specimen? Vendor docs often use `EPSON`, `Tag`, `Cash Drawer`. | Application contract |
| Q-021 | Tag printer USB vs parallel, and whether `net use LPT1` / `Tag Fix.bat` exists | Hardware-bound vs reproducible |
| Q-022 | Invoice printer model (Epson TM-T88x vs Star mcPrint3 vs other) | Driver package |
| Q-023 | Are barcode scanners HID keyboard-wedge, USB COM, or vendor middleware? | Replacement mapping |
| Q-024 | This specimen has no cash drawer (operator). Confirm no `Cash Drawer` printer object. | Role differences |

## Security / collection policy

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-030 | May we install Sysmon with a conservative config? | Level B observation |
| Q-031 | May we run short ProcMon traces around POS launch and a tag/invoice print? | Level C |
| Q-032 | Approved evidence store path (controller disk vs Synology `zenith-dsm` vs other)? | Packaging |

## Identity

| ID | Question | Why it matters |
| --- | --- | --- |
| Q-040 | Operator-facing store id and register id for this specimen? | Manifest pseudonym |
