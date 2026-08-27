# 007 — Replacement notes: what is locked vs what still needs a decision

**Class:** Requirement + open refinements  
**Status:** registered 2026-08-21 (ADR-0011). Not building this in Phase 1.

Locked enough to design toward:

| Item | Locked | Needs more data or a mockup |
| --- | --- | --- |
| UPS on every PC | Yes | Brand/model for new buys; WS3 currently has **no** UPS HID in Windows (repair?). Critical shutdown **percent** (today 5%). Confirm “shutdown” not hibernate. Sleep-on-battery timeout. |
| Stay on battery until graceful shutdown is required | Yes | Exact Windows power-plan numbers. Vendor UPS software vs built-in HID. |
| RustDesk → `rustdesk.vogueclean.int` | Yes | Live PCs updated 2026-08-27. Public key, install flags, version pin still for the USB build. |
| Black wallpaper with store, computer name, SPOT ID | Yes (content) | Layout, font, size, color of text, logo or not, whether SPOT ID is `VGCTX03COUNTER3` or the USB menu name. Non-SPOT PCs omit the SPOT line. |
| Non-SPOT USB rows | Named and on WinRM | Video wall: SS Client + CallerIdOverlay recorded; camera layout still Q-082. Workdesk: Gayla, no Yevhen, no auto-logon. |
| Admin + SPOT on a standard user | Yes | Names **`ZenithAdmin`** / **`ZenithUser`**. Password policy. Do not rename live PCs. |
| Secrets on NAS; SPOT secrets in the build | Yes | Path **`\\zenith-dsm.vogueclean.int\spot-rebuild`**, user **`spot-rebuild`**. Kits in `common/packages/`. Password not in git. |
| Skip retail Windows 11 Pro OOBE | Yes | **Key: COA/OEM on each box**, none in the pack (ADR-0013). Language/region/privacy screens. Local account creation during unattend. |
| Reachable by this controller / later agents | Yes — **WinRM** (ADR-0002 + 0011 §8) | USB applies bootstrap; firewall CIDR; Ansible optional on the controller only. No second agent. |
| USB store → workstation menus | Yes (ADR-0010) | Vogue printers still by analogy until a Vogue PC is read. |
| SPOT license / `ClientName` | Yes — `VGCTXssCOUNTERn` | Wallpaper whether to show this string or the menu name (Q-072). |
| SPOT standard-user browser | **Edge**; home/new tab `https://help.spotpos.com` | Rest of lockdown still to discuss. Not auto-applied to desk/video wall. |
| SPOT vendor driver/font kits | Epson APD 5.11, WASP fonts, Star PRNT 3.8.1 (tag rows) | Silent/unattend switches; NAS copy (Q-074). Kits on controller `vendor-installers/`. |

Refs: ADR-0011, Q-070–Q-075, Q-032, Q-062.
