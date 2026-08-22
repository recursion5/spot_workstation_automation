# 008 — Two non-SPOT Windows PCs on the USB rebuild list

**Class:** Requirement  
**Status:** open (in scope; catalog rows not named)

Operator 2026-08-22: add two more Windows workstations to the automated rebuild USB. Neither runs SPOT.

Until named, do not invent menu labels or hostnames. Same stick and store picker as POS rows; `runs_spot: false`; no `VGCTX` `ClientName`; no SPOTLauncher.

Shared policy still intended (ADR-0011): UPS, RustDesk `dsm.vogueclean.int`, black wallpaper (store + computer name only), admin + standard auto-logon user, secrets on NAS, skip retail OOBE.

Need from operator (Q-080 / Q-081):

- Store (Vogue Krum / Vogue Denton / Zenith)
- USB workstation menu text
- What the PC is for
- Current Windows name / IP if we should inventory it in Phase 1

Refs: ADR-0010, Q-080, Q-081.
