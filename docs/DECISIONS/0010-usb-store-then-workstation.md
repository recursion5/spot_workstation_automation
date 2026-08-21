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

Official menus (**Requirement**, operator 2026-08-21), in `config/catalog/workstations.yml`:

| Store menu | Workstation menu | `spot_client_name` |
| --- | --- | --- |
| Vogue Krum | Front Counter (cash drawer) | unknown |
| Vogue Krum | Mark-In | unknown |
| Vogue Denton | Front Counter (cash drawer) | unknown |
| Vogue Denton | Mark-In | unknown |
| Zenith | Front Counter (cash drawer) | `VGCTX03COUNTER1` |
| Zenith | Mark-In 1 (front mark-in) | `VGCTX03COUNTER2` |
| Zenith | Mark-In 2 (back mark-in) | `VGCTX03COUNTER3` |

## Decision

**Class: Requirement (operator) + Decision.**

The replacement process is **USB boot → store menu → workstation menu → apply that catalog entry**.

- One catalog drives both menus. Choosing a workstation selects the whole desired state: local accounts, auto-logon **behavior**, SPOTLauncher RDS (`ConnectionMode` 1, ADR-0009), `ClientName`, printer/peripheral **role**, shortcuts.
- Do not clone the old disk. Do not make the operator type `VGCTX03COUNTER3` if a menu can offer “Mark-In 2 (back mark-in)”.
- One USB serves all three stores. A separate USB per store is an implementation fallback, not the goal.
- Secrets live on the **NAS** and are applied during the build (ADR-0011). They do not live in git or as plaintext on a stick that can leave the building.
- Hardware-specific USB instance paths are **not** copied from the old PC (constitution §3). Printer *names* and roles come from the catalog; PnP binds on the new box.

## Alternatives considered

- Network PXE only — needs DHCP/PXE on every store LAN; USB works when the new PC is on the bench or the store network is down.
- Type store/register as text — error-prone on the floor; operator asked for choices.
- One golden image per PC — what this project exists to stop.
- Store-specific USBs only — acceptable fallback if one stick cannot hold all catalogs.

## Consequences

- Catalog labels are locked. Phase 3 still must not start until desired-state per row is evidence-based (Zenith yes; Vogue ClientNames/peripherals still open).
- First replacement candidate is Zenith **Front Counter (cash drawer)** (current ZENITH-WS1, Win10).
- Open questions: Vogue SPOT `ClientName` values (Q-063), Q-062 (offline USB vs NAS pull), UEFI USB boot on replacement hardware (Assumption: yes on MINIX/NUC-class boxes).
