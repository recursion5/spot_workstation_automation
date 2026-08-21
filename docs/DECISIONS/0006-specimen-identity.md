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

**Update 2026-08-21:** Operator supplied official USB menu labels. Machine ids and menus:

| `store` | Menu | Workstations |
| --- | --- | --- |
| `vogue-krum` | Store 1 Vogue Krum | `front-counter`, `mark-in` |
| `vogue-denton` | Store 2 Vogue Denton | `front-counter`, `mark-in` |
| `zenith` | Store 3 Zenith | `front-counter`, `mark-in-1`, `mark-in-2` |

This specimen (ZENITH-WS3) is **store `zenith`**, register **`mark-in-2`**, role **`mark-in-back`**, SPOT `ClientName` **`VGCTX03COUNTER3`**. Catalog: `config/catalog/workstations.yml`.

**Update 2026-08-21 (license names):** Operator: SPOT license names are `VGCTXCOUNTERx`, then confirmed the **store number** after `VGCTX`. Form is **`VGCTXssCOUNTERn`** with `ss` = store 01/02/03 and `n` = workstation order (Front Counter = 1). Live Zenith files match (`VGCTX03COUNTERn`).

## Alternatives considered

- Use Windows hostname as the only id — collides with hardware replacement.

## Consequences

New collection runs should use `store=zenith` rather than `unassigned`. USB menus use the `menu` strings exactly. SPOT `ClientName` is `VGCTXssCOUNTERn`.
