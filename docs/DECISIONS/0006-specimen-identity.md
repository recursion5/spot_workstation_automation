# ADR 0006 — Placeholder store/register until operator supplies codes

- Status: accepted
- Date: 2026-08-19

## Context

Manifests need a stable identity. Real SPOT Account Key / store / workstation names are not known and may be sensitive.

## Decision

Until the operator provides codes, use:

- `store`: `unassigned`
- `register`: `specimen-01`
- `role`: `back-office` (operator: this PC is not customer-facing)

**Update 2026-08-20:** Operator directed use of SPOT internal license names. This specimen is **`VGCTX03COUNTER3`** (confirmed on disk in the shortcut and `settings.json` `ClientName`; operator confirmed the `C` is real). Other stations at the store should use the same SPOT license name pattern.

Hostname stays in the run manifest as observed. GitHub issues should prefer the placeholder, not the public hostname, when possible.

## Alternatives considered

- Use Windows hostname as the only id — collides with hardware replacement.

## Consequences

Update this ADR when store/register codes are known.
