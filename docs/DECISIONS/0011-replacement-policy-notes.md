# ADR 0011 — Replacement policy notes (UPS, RustDesk, wallpaper, accounts, secrets, OOBE)

- Status: accepted
- Date: 2026-08-21

## Context

Operator registered desired-state notes for automated replacements. Implementation is later phases. Live PCs are not changed to match. Refinements live in [issue 007](../issues/007-replacement-refinements.md).

## Decision

**Class: Requirement (operator).** Discovery of current PCs is in DISCOVERIES.

1. **UPS.** Every workstation sits on a UPS. Windows stays up on battery and performs a **graceful shutdown only when the UPS cannot continue**. Exception: a UPS that is awaiting repair or replacement. Do not hard-power-off.
2. **RustDesk.** Installed on replacements, ID/rendezvous/relay server **`rustdesk.vogueclean.int`** (DNS name, not a raw IP). **2026-08-27:** operator added DNS (`10.0.253.110`). Live Zenith PCs (WS1/WS2/WS3, workdesk, Z-SSTATION) were updated from the IP to that hostname and the RustDesk service was restarted.
3. **Wallpaper.** For **all local users**: black background plus text for store, Windows computer name, and (if the PC runs SPOT) SPOT workstation ID. Non-SPOT rebuilds omit the SPOT line. Visual design is still open.
4. **Accounts.** An **admin** account exists. The auto-logon user should be **standard** (non-admin). On SPOT PCs that user runs SPOT. Today’s shop-floor users are administrators; that is leftover, not the target.
5. **Secrets.** Source of truth is the **NAS**, not git and not a plaintext USB. The **build applies SPOT-related secrets** so a replacement does not need a SPOT support remote session to install the launcher, set station identity, or attach printers/peripherals. Complements ADR-0005 and ADR-0010.
6. **OOBE.** Replacement hardware ships with **retail Windows 11 Pro**. The USB process must not leave the operator on the “new PC experience.” Unattended setup skips OOBE.

## Alternatives considered

- Clone the old disk, including leftover admin shop-floor users and Spotlight wallpaper — rejected by the project purpose.
- Keep RustDesk on IP `10.0.253.110` — hostname survives NAS address changes.
- Prompt SPOT to configure each new PC — what this build is meant to avoid.

## Consequences

- Catalog + NAS secret pack + unattend must exist before the first USB is useful.
- Power policy on new PCs: low-battery **do nothing**; critical action **shut down** (not sleep; hibernate is unavailable on at least the current Win10 front counter). Exact percent still open.
- Do not strip admin from live `ZenithUser` / `Zenith User` unless asked.
