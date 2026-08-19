# ADR 0003 — Evidence outside git; manifests inside

- Status: accepted
- Date: 2026-08-19

## Context

ProcMon, EVTX, and driver inventories can be large or sensitive. Git history is a poor secret store.

## Decision

- Default evidence root on the controller: `/home/grok-agent/spot-discovery/evidence` (override with `SPOT_EVIDENCE_ROOT`).
- `evidence/` in git holds README, schemas-as-needed, checksums, and pointers — not raw bundles.
- Each run writes `manifest.json` plus `hashes/SHA256SUMS`.
- Tiny sanitized samples may live under `samples/sanitized/`.

A Synology (`zenith-dsm.vogueclean.int`) exists on the controller LAN and is a candidate later store. Not chosen yet (Q-032).

## Alternatives considered

- Git LFS — still copies secrets into a remote.
- Always USB — fine as fallback, too manual as the only path.

## Consequences

Collectors must accept an output root. Packaging must work on a copied folder with no Windows session.
