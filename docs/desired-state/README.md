# Desired-state recipes (Phase 2)

One markdown file per USB catalog row. These are **recipes**, not installers, and **not** a production-cutover guarantee.

Do not copy USB instance paths or clone the old disk. Secrets stay on the NAS: [secret-pack.md](secret-pack.md).

| Catalog id | File | Status |
| --- | --- | --- |
| `zenith` / `front-counter` | [zenith-front-counter.md](zenith-front-counter.md) | draft 2026-08-27 |
| `zenith` / `mark-in-1` | [zenith-mark-in-1.md](zenith-mark-in-1.md) | draft 2026-08-27 |
| `zenith` / `mark-in-2` | [zenith-mark-in-2.md](zenith-mark-in-2.md) | draft 2026-08-27 |
| `zenith` / `management-desk` | [zenith-management-desk.md](zenith-management-desk.md) | draft 2026-08-27 |
| `zenith` / `video-wall` | [zenith-video-wall.md](zenith-video-wall.md) | draft 2026-08-27 |
| Vogue rows | — | not inventoried; printers by analogy only |

Build order: Front Counter first (live PC is Win10 replacement candidate). First replacement is a **staffed test**, old PC kept available.

SPOT rows share: Citrix Workspace / `ConnectionMode` 0 (ADR-0012), `ZenithAdmin` + standard `ZenithUser`, Edge + `https://help.spotpos.com`, Epson APD + WASP fonts, RustDesk `rustdesk.vogueclean.int`.

**All rows** (including desk and video wall): WinRM HTTP 5985 NTLM to `10.0.253.225/32` as `ZenithAdmin` after the USB finishes (ADR-0011 §8). That is how this controller and later agents manage the box. Ansible is not installed on the PC.
