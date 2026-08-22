# 007 — Replacement notes: what is locked vs what still needs a decision

**Class:** Requirement + open refinements  
**Status:** registered 2026-08-21 (ADR-0011). Not building this in Phase 1.

Locked enough to design toward:

| Item | Locked | Needs more data or a mockup |
| --- | --- | --- |
| UPS on every PC | Yes | Brand/model for new buys; WS3 currently has **no** UPS HID in Windows (repair?). Critical shutdown **percent** (today 5%). Confirm “shutdown” not hibernate. Sleep-on-battery timeout. |
| Stay on battery until graceful shutdown is required | Yes | Exact Windows power-plan numbers. Vendor UPS software vs built-in HID. |
| RustDesk → `dsm.vogueclean.int` | Yes | Confirm that name is the same host as `zenith-dsm.vogueclean.int` / `10.0.253.110`. Self-hosted **public key** and install flags (service, tray, unattended). Version pin. |
| Black wallpaper with store, computer name, SPOT ID | Yes (content) | Layout, font, size, color of text, logo or not, whether SPOT ID is `VGCTX03COUNTER3` or the USB menu name. Non-SPOT PCs omit the SPOT line. |
| Non-SPOT USB rows | Zenith Management desk + Video wall | Hostnames/IPs; video-wall camera layout (Q-082); management-desk apps; whether video wall auto-logs on. |
| Admin + SPOT on a standard user | Yes (intent) | Account **names** for new builds (`ZenithAdmin`/`ZenithUser` vs generic). Password policy. Do not change live PCs. |
| Secrets on NAS; SPOT secrets in the build | Yes | Share path, who can read, how the USB authenticates to the NAS, which files (launcher settings, RDS, printer). Q-062/Q-074. |
| Skip retail Windows 11 Pro OOBE | Yes | Product key source (COA / digital license / unattend). Language/region/privacy screens. Local account creation during unattend. |
| USB store → workstation menus | Yes (ADR-0010) | Vogue printers still by analogy until a Vogue PC is read. |
| SPOT license / `ClientName` | Yes — `VGCTXssCOUNTERn` | Wallpaper whether to show this string or the menu name (Q-072). |

Refs: ADR-0011, Q-070–Q-075, Q-032, Q-062.
