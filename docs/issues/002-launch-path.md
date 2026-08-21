# 002 — Citrix+SPOTLauncher vs SPOTWeb+ConnectLink

**Class:** Open question, then decision  
**Status:** answered (2026-08-21) — see [ADR-0009](../DECISIONS/0009-rds-not-citrix.md)

All three Zenith PCs have SPOTLauncher 1.1.169.3. No ConnectLink/SPOTWeb.

Live mix after coordinated reboot:

- WS1 / WS3: desktop shortcut → `ConnectionMode` 1 → **RDS `mstsc`**
- WS2: shortcut → `ConnectionMode` 0 → **Citrix ICA** `wfica32` / `SPOT - Auto Login`
- WS3 still autostarts Citrix Receiver 4.9; that stack did not carry the SPOT window

**Operator:** moving away from Citrix; not every PC is converted. **Replacements use RDS, not Citrix.**

Refs: Q-010–Q-014, ADR-0009, `docs/vendor/SPOT-PUBLIC-NOTES.md`.
