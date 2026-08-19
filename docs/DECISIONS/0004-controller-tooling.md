# ADR 0004 — Linux controller, PowerShell on Windows, Ansible + Python

- Status: accepted
- Date: 2026-08-19

## Context

Orchestration should not require an interactive admin desktop on the POS PC. The agent environment is Ubuntu with Python 3.14.

## Decision

- Collectors: PowerShell 5.1 scripts executed on the target.
- Controller CLI: Python 3 (`scripts/controller/spotctl.py`) using stdlib + `pywinrm` + `jsonschema`.
- Repeatable multi-step runs: Ansible with `ansible.windows`.
- Do not introduce a second Windows agent framework (Salt, SCCM, Intune) in Phase 1.

## Alternatives considered

- Pure Ansible without a project CLI — weaker for a first WinRM bring-up.
- PowerShell 7-only collectors — unnecessary if 5.1 can emit JSON.

## Consequences

Ansible is optional for the first connectivity test. Collectors must be runnable locally via `Invoke-Discovery.ps1`.
