# ADR 0010 — Replacement USB boots to store, then workstation

- Status: accepted
- Date: 2026-08-21

## Context

The constitution already aims at: unbox a Windows 11 Pro PC, identify `store` + `register`, apply desired state. The operator made the bootstrap concrete:

1. Boot the replacement PC from USB.
2. Choose a **store**.
3. Choose a **workstation** at that store.
4. Automation builds that identity (not a cloned disk from the old PC).

Phase 1 does not implement this installer. This ADR locks the intended operator experience so Phase 2/3 do not drift into image-clone or “type a hostname” designs.

Known identities on the Zenith floor today (Discovery):

| Menu-friendly (not yet official) | SPOT `ClientName` | Role notes |
| --- | --- | --- |
| Zenith / Counter 1 | `VGCTX03COUNTER1` | Customer-facing; cash drawer; Win10 replacement candidate |
| Zenith / Counter 2 | `VGCTX03COUNTER2` | Tag + invoice; still Citrix leftover; replacements use RDS (ADR-0009) |
| Zenith / Counter 3 | `VGCTX03COUNTER3` | Back-office; tag + invoice; RDS |

Operator: two Vogue stores exist separately. They are not in the specimen inventory yet.

## Decision

**Class: Requirement (operator) + Decision.**

The replacement process is **USB boot → store menu → workstation menu → apply that catalog entry**.

- One catalog drives both menus. Choosing a workstation selects the whole desired state: local accounts, auto-logon **behavior**, SPOTLauncher RDS (`ConnectionMode` 1, ADR-0009), `ClientName`, printer/peripheral **role**, shortcuts.
- Do not clone the old disk. Do not make the operator type `VGCTX03COUNTER3` if a menu can offer “Counter 3”.
- The same USB should be able to serve every store in the catalog once those rows exist. A separate USB per store is an implementation fallback, not the goal.
- Secrets (admin / auto-logon / hosted-app) do not live in plaintext on the USB if that stick can leave the building. Prompt, protected store, or first-boot retrieval — design in Phase 3.
- Hardware-specific USB instance paths are **not** copied from the old PC (constitution §3). Printer *names* and roles come from the catalog; PnP binds on the new box.

## Alternatives considered

- Network PXE only — needs DHCP/PXE on every store LAN; USB works when the new PC is on the bench or the store network is down.
- Type store/register as text — error-prone on the floor; operator asked for choices.
- One golden image per PC — what this project exists to stop.
- Store-specific USBs only — acceptable fallback if one stick cannot hold all catalogs.

## Consequences

- Phase 2 must produce a **store × workstation catalog** (friendly labels + technical identity), starting with Zenith, before the USB UI is worth building.
- Vogue rows wait until those stores are in scope; the menu can still be built with one store.
- Open questions: official store labels (Q-040), Sunday/other sites, whether install is fully offline or pulls from `zenith-dsm` after the choice, UEFI USB boot on the actual replacement hardware (Assumption: yes on MINIX/NUC-class boxes; confirm on first replacement unit).
