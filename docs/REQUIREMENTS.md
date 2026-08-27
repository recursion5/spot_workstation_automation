# Requirements

Statements the operator or constitution say the future system must honor. Not discoveries.

## From the project constitution

- Replacement Windows 11 Pro workstations must become reproducible from business identity (store, register, optional role), not from cloned disk images.
- Phase 1 collects evidence only; it does not ship provisioning.
- Observation defaults to read-only. Active experiments need a question, reversibility, short duration, and operator approval.
- Secrets never enter git or ordinary logs.
- Discovery code should stay modular enough to reuse on other Windows business endpoints without delaying the SPOT work.

## Operator-stated environment (not yet observed on the specimen)

**Class: Requirement / operator-reported context.**

- Target OS: Windows 11 Pro workstations (SPOT POS and other store Windows PCs on the same USB rebuild list).
- Application: Xplor Spot hosted POS (`https://xplorspot.com`).
- **App delivery for replacements (2026-08-27):** SPOTLauncher `ConnectionMode` **0** → Citrix **Workspace** / ICA `SPOT - Auto Login` ([ADR-0012](DECISIONS/0012-citrix-launch-path.md)). Live WS1/WS3 still RDS until replaced. Not SPOTWeb.
- **Replacement operator flow (2026-08-21):** boot from USB → choose store → choose workstation → automation applies that identity. Not a cloned image. See [ADR-0010](DECISIONS/0010-usb-store-then-workstation.md). Implementation is Phase 3.
- **USB menus (2026-08-21):** Store 1 Vogue Krum; Store 2 Vogue Denton; Store 3 Zenith. Zenith workstations: Front Counter (cash drawer), Mark-In 1 (front mark-in), Mark-In 2 (back mark-in). Each Vogue store: Front Counter (cash drawer), Mark-In. Catalog: `config/catalog/workstations.yml`.
- **Non-SPOT rebuilds (2026-08-22):** Zenith **Management desk** and **Video wall**. Currently Windows 10 Pro; replacements **Windows 11 Pro**. No SPOTLauncher / no `VGCTX` id. Video wall: Synology Surveillance Station Client for camera feeds. Same USB conventions (RustDesk, accounts, wallpaper, UPS, skip OOBE) as they are decided.
- Employees do not perform Windows logon; a local standard user auto-logs on; POS is launched from a desktop shortcut.
- Store open (Zenith): weekdays **06:00**, Saturday **08:00** America/Chicago. Sunday unknown. SPOT is not left running overnight.
- A local administrative account exists.
- No Active Directory domain requirement has been established (still verify).
- Most workstations have a USB tag printer, an invoice printer, and barcode scanners.
- Customer-facing workstations additionally have a cash drawer attached through the thermal invoice printer, plus network integration with an external payment terminal.
- **This first specimen is not customer-facing and does not handle payments.**
- Workstations that do take payments do not handle raw card data; the payment terminal encrypts/tokenizes off-box.
- **UPS (2026-08-21):** every workstation on a UPS; run on battery until a graceful shutdown is required. Exception: UPS awaiting repair/replacement. [ADR-0011](DECISIONS/0011-replacement-policy-notes.md).
- **RustDesk (2026-08-27):** rendezvous/relay **`rustdesk.vogueclean.int`**. Live Zenith PCs updated the same day (was `10.0.253.110`).
- **Wallpaper (2026-08-21):** all users; black; text = store, Windows computer name, SPOT workstation ID. Appearance still to refine.
- **Accounts (2026-08-27):** replacements use **`ZenithAdmin`** and **`ZenithUser`** (no space). `ZenithUser` is not an administrator. Auto-logon that standard user on SPOT and video wall.
- **Secrets (2026-08-27):** pack root `\\dsm.vogueclean.int\spot-rebuild`, SMB user **`spot-rebuild`** (ADR-0013). Password not in git. `dsm.vogueclean.int` DNS still needed (`zenith-dsm.vogueclean.int` already points at the NAS).
- **OOBE (2026-08-21):** retail Windows 11 Pro boxes must not stop on the “new PC experience.” USB unattend skips it. **Product key (2026-08-27):** each box uses its COA / OEM license; no key in the pack.
- **SPOT standard-user browser (2026-08-27):** **Microsoft Edge** only; controlled search/new-tab/home. Home and new tab = **`https://help.spotpos.com`**. Further lockdown still open. SPOT PCs only unless extended.
- **Computer names (2026-08-27):** keep the live names (`ZENITH-WS1`, `ZENITH-WS2`, `ZENITH-WS3`, `ZENITH-WORKDESK`, `Z-SSTATION`).
- **Vendor driver/font kits (2026-08-27):** rebuilds install Epson APD 5.11 (`APD_511R1`), WASP barcode fonts (shop-floor user), and Star PRNT 3.8.1 on tag rows. Not only printer objects. Kits captured on the controller; not git.

## Phase 1 acceptance

See [project-spec.md](../project-spec.md) §25. Status of each item is in [STATUS.md](STATUS.md).
