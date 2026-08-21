# ADR 0009 — Replacement workstations use SPOTLauncher RDS, not Citrix

- Status: accepted
- Date: 2026-08-21

## Context

The three Zenith PCs do not launch SPOT the same way.

| PC | SPOTLauncher `ConnectionMode` | What actually started after reboot |
| --- | --- | --- |
| WS1 | 1 | `mstsc` (RDS RemoteApp). No Citrix processes. |
| WS2 | 0 | Citrix ICA `wfica32`, published app `SPOT - Auto Login`. No `mstsc`. |
| WS3 | 1 | `mstsc`. Citrix Receiver 4.9 still autostarts at logon but did not carry the SPOT window. |

Vendor docs also describe SPOTWeb + ConnectLink. That client is **not** installed on these PCs.

**Operator (2026-08-21):** stations are configured differently; they are moving away from the Citrix piece and have not made every workstation consistent. Automated replacements must use the **newest / correct** app delivery method, not a clone of whichever leftover a given PC still has.

## Decision

**Class: Decision (operator) + Discovery (reboot evidence).**

Replacement Windows 11 Pro workstations get:

1. SPOTLauncher (same product already on the floor, version observed `1.1.169.3`).
2. `ConnectionMode` **1**.
3. Desktop shortcut launch that results in **RDS RemoteApp** via `mstsc`, gateway `rds.mydrycleaner.com`, `ClientName` = that station’s `VGCTX03COUNTERn`.

They do **not** get Citrix Receiver, Citrix Workspace, or an ICA published-app launch as part of the replacement image/playbook.

Existing WS2 may keep Citrix until that PC is replaced. Do not “fix” live Citrix/RDS settings on production stations to experiment.

SPOTWeb + ConnectLink is **not** the replacement target unless a later operator decision or a specimen actually running that stack appears.

## Alternatives considered

- Copy each old PC’s current method (WS2 would stay Citrix) — operator rejected inconsistency; replacements should be uniform and current.
- Install Citrix because WS3 still has Receiver and WS2 still uses ICA — that is leftover, not the target.
- Jump to SPOTWeb + ConnectLink because vendor docs call it newer — not observed here; operator named leaving Citrix, not leaving SPOTLauncher.

## Consequences

- WS1 and WS3 launcher settings are the template for app delivery; WS2 is not.
- Phase 2 playbooks must not treat Citrix as required software.
- Discovery continues to record Citrix on live PCs so leftover autostart is not mistaken for the desired state.
