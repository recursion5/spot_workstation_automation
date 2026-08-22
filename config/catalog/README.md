# Workstation catalog

Source of truth for the future USB menus (ADR-0010). Not an installer.

- `menu` strings are operator-facing and must stay exact.
- `id` values are stable keys for automation (`zenith` / `front-counter`).
- `spot_client_name` is `VGCTXssCOUNTERn` (store number after `VGCTX`, then `COUNTERn`). Operator-confirmed. Null when the PC does not run SPOT.
- `runs_spot` is false for office/other Windows rebuilds that share the USB but not SPOTLauncher.
