# ADR 0001 — Record material decisions as ADRs

- Status: accepted
- Date: 2026-08-19

## Context

The constitution requires an ADR mechanism under `docs/DECISIONS/` so later agents do not infer design from chat history.

## Decision

Every decision that affects reproducibility, transport, evidence format, secrets, identity, or collector installation gets an ADR using the template in `README.md`.

## Alternatives considered

- Wiki or GitHub Discussions only — too easy to skip while coding.
- Comments in scripts only — not reviewable as a set.

## Consequences

Agents must add an ADR when changing any of the above. Superseding an ADR does not delete it.
