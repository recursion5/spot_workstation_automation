# 006 — USB replacement catalog (store then workstation)

**Class:** Requirement  
**Status:** open (UX accepted in ADR-0010; catalog and installer not built)

Operator wants: boot USB → pick store → pick workstation.

Blocked on a small catalog of friendly names plus technical identity. Do not implement WinPE/OOBE in Phase 1.

Draft Zenith rows (hypothesis until operator confirms labels):

| Store menu | Workstation menu | `ClientName` | Role |
| --- | --- | --- | --- |
| Zenith | Counter 1 | VGCTX03COUNTER1 | cash drawer, customer-facing |
| Zenith | Counter 2 | VGCTX03COUNTER2 | tag + invoice |
| Zenith | Counter 3 | VGCTX03COUNTER3 | back-office, tag + invoice |

Vogue stores: out of specimen scope until asked.

Refs: ADR-0010, Q-060, Q-061, Q-062, issue 005.
