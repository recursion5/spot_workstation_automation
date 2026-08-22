# 008 — Two non-SPOT Windows PCs on the USB rebuild list

**Class:** Requirement  
**Status:** both WinRM up

Operator 2026-08-22:

| USB menu | Store | Current OS | Replacement OS | Notes |
| --- | --- | --- | --- | --- |
| Management desk | Zenith | Windows 10 Pro 19045 (`ZENITH-WORKDESK` / 10.0.253.162) | Windows 11 Pro | MSI Cubi2; Gayla + Zenith Admin; **no Yevhen** on rebuild; no auto-logon; 3CX |
| Video wall | Zenith | Windows 10 Pro 19044 (`Z-SSTATION` / 10.0.253.164) | Windows 11 Pro | Surveillance Station Client 2.2.1 running; `Zenith User` not admin; AutoAdminLogon=1 |

Same USB as POS; `runs_spot: false`. Shared policy: UPS, RustDesk, wallpaper (no SPOT id), admin + standard user, skip OOBE, bloat removal as decided.

WinRM: both connected as `Zenith Admin`.

Refs: ADR-0010, Q-080–Q-082.
