# ADR 0007 — Do not install Sysmon until approved

- Status: accepted
- Date: 2026-08-19

## Context

Sysmon is valuable for Level B observation but installs a kernel driver. That is a production change. The constitution says observe before changing.

## Decision

Do not install Sysmon, ProcMon as a resident tool, or WPR sessions as part of bootstrap. Revisit after:

- WinRM works;
- Level A baseline exists;
- operator approves a conservative Sysmon config and a short ProcMon scenario.

## Alternatives considered

- Install Sysmon immediately with a tight config — faster telemetry, higher on-site risk.

## Consequences

First discovery run is inventory-only plus whatever event logs already exist.
