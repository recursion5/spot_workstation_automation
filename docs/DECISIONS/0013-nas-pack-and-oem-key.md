# ADR 0013 — Rebuild pack on NAS; OEM Windows key; no key in the pack

- Status: accepted
- Date: 2026-08-27

## Context

USB replacement needs drivers, fonts, Citrix Workspace, SPOTLauncher, and secrets. Those must not live in git (ADR-0005). Q-074 (share path) and Q-071 (product key) blocked a real stick.

**Operator (2026-08-27):**

1. Pack root is a **new** share `\\dsm.vogueclean.int\spot-rebuild`.
2. Each new retail PC uses its **COA / OEM digital license**. No Windows product key in the pack or git.
3. Copy missing installers off live PCs onto the controller (read-only), then onto that share when it exists.

## Decision

**Class: Decision (operator).**

- Canonical pack UNC: `\\dsm.vogueclean.int\spot-rebuild`.
- USB, once on the LAN, **pulls** packages and secrets from that share (Q-062 still open only for “NAS down”).
- Windows 11 Pro activation: hardware COA / OEM entitlement. Unattend skips OOBE without injecting a key.
- Stick and controller authenticate to the share as NAS user **`spot-rebuild`**. Password lives in the controller `.env` / NAS pack, not git.
- DNS: operator UNC is `\\dsm.vogueclean.int\spot-rebuild`. As of 2026-08-27 `dsm.vogueclean.int` did **not** resolve; `zenith-dsm.vogueclean.int` and `rustdesk.vogueclean.int` both A `10.0.253.110`. Need an A/CNAME for `dsm.vogueclean.int` or the stick must use `zenith-dsm` / the IP.

## Alternatives considered

- Controller-only pack — rejected for production; allowed as a staging copy until the share exists.
- Packages on the USB, NAS only for passwords — not chosen.
- Inject a MAK/key from the NAS — rejected.

## Consequences

- Create the share before a real stick. Layout: [desired-state/secret-pack.md](../desired-state/secret-pack.md).
- Do not put `ProductKey` in unattend from our pack.
- Large binaries stay off git; controller `vendor-installers/` is the staging area until the share is writable.
