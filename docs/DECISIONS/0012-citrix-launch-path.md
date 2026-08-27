# ADR 0012 — Replacement SPOT stations use the Citrix launch path

- Status: accepted
- Date: 2026-08-27
- Supersedes: [0009](0009-rds-not-citrix.md)

## Context

ADR-0009 chose SPOTLauncher `ConnectionMode` 1 / RDS `mstsc` because WS1 and WS3 launched that way and the operator had said they were moving off Citrix. WS2 remained ICA (`ConnectionMode` 0, Citrix Workspace, `wfica32`, published app `SPOT - Auto Login`).

**Operator (2026-08-27):** all replacements should use **the Citrix version of the config**.

## Decision

**Class: Decision (operator).**

SPOT USB rows (`runs_spot: true`) get:

1. SPOTLauncher (floor version `1.1.169.3` or current same product).
2. `ConnectionMode` **0**.
3. Citrix **Workspace** (live template: WS2 `Citrix Workspace 26.3.10.69`), not Receiver 4.9 LTSR.
4. Launch that results in ICA **`wfica32`** / published app **`SPOT - Auto Login`**, `ClientName` = that station’s `VGCTXssCOUNTERn`.
5. Local Windows printer **names** still `EPSON` / `Tag` / `CashDrawer` / Brother as the row requires.

They do **not** get RDS RemoteApp / `mstsc` as the SPOT window.

Do **not** convert live WS1/WS3 from RDS to Citrix to experiment. New boxes follow this ADR.

SPOTWeb + ConnectLink remains out unless a later decision.

## Alternatives considered

- Keep ADR-0009 (RDS for all) — operator reversed.
- Mix RDS and Citrix per old PC — operator wants one method.

## Consequences

- WS2 is the **launch-path template**, not WS1/WS3.
- Front Counter desired-state (and later Mark-In rows) must install Workspace + ConnectionMode 0.
- Receiver 4.9 autostart on WS3 is still leftover, not the package to copy.
- ScrewDrivers / Citrix printer mapping on a new Citrix box is **Hypothesis** until the first Citrix replacement is validated (local printer names still required).
