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

- Target OS: Windows 11 Pro POS workstations.
- Application: Xplor Spot hosted POS (`https://xplorspot.com`).
- **App delivery for replacements (2026-08-21):** SPOTLauncher → RDS RemoteApp (`mstsc`, `ConnectionMode` 1). Do **not** install Citrix Receiver/Workspace on new PCs. Some existing stations still use Citrix; that is leftover, not the target ([ADR-0009](DECISIONS/0009-rds-not-citrix.md)).
- **Replacement operator flow (2026-08-21):** boot from USB → choose store → choose workstation → automation applies that identity. Not a cloned image. See [ADR-0010](DECISIONS/0010-usb-store-then-workstation.md). Implementation is Phase 3.
- Employees do not perform Windows logon; a local standard user auto-logs on; POS is launched from a desktop shortcut.
- Store open (Zenith): weekdays **06:00**, Saturday **08:00** America/Chicago. Sunday unknown. SPOT is not left running overnight.
- A local administrative account exists.
- No Active Directory domain requirement has been established (still verify).
- Most workstations have a USB tag printer, an invoice printer, and barcode scanners.
- Customer-facing workstations additionally have a cash drawer attached through the thermal invoice printer, plus network integration with an external payment terminal.
- **This first specimen is not customer-facing and does not handle payments.**
- Workstations that do take payments do not handle raw card data; the payment terminal encrypts/tokenizes off-box.

## Phase 1 acceptance

See [project-spec.md](../project-spec.md) §25. Status of each item is in [STATUS.md](STATUS.md).
