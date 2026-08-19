# ADR 0005 — Secrets never in git; existence-only in git-safe JSON

- Status: accepted
- Date: 2026-08-19

## Context

Auto-logon, ICA files, ConnectLink keys, and WinRM credentials will appear during discovery. Payment PAN is not expected on these PCs (external tokenizing terminal) but PINs and Windows passwords still are.

## Decision

Git-safe collector output may include path, value **name**, type, length, hash of non-secret files, and a boolean `secret_present`. It may not include password values, tokens, cookies, or DefaultPassword.

Redaction patterns live in `config/redaction/patterns.yml`. When in doubt, omit the value.

Controller secrets: gitignored `.env` mode 600.

## Alternatives considered

- Encrypt secrets in git — still a leak surface and not needed for Phase 1.

## Consequences

Later provisioning must obtain secrets through an operator-controlled channel, not by replaying discovery JSON.
