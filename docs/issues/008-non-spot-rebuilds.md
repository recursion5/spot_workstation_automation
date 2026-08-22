# 008 — Two non-SPOT Windows PCs on the USB rebuild list

**Class:** Requirement  
**Status:** video wall WinRM up (`Z-SSTATION`); management desk still pending

Operator 2026-08-22:

| USB menu | Store | Current OS | Replacement OS | Notes |
| --- | --- | --- | --- | --- |
| Management desk | Zenith | Windows 10 Pro | Windows 11 Pro | Office/management PC |
| Video wall | Zenith | Windows 10 Pro 19044 (`Z-SSTATION` / 10.0.253.164) | Windows 11 Pro | Surveillance Station Client 2.2.1 running; `Zenith User` not admin; AutoAdminLogon=1 |

Same USB as POS; `runs_spot: false`. Shared policy: UPS, RustDesk, wallpaper (no SPOT id), admin + standard user, skip OOBE, bloat removal as decided.

WinRM: same `Bootstrap-WinRM.ps1` as POS. Hostnames/IPs after connection cards.

Refs: ADR-0010, Q-080–Q-082.
