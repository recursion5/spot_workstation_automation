# Workstation catalog

Source of truth for the future USB menus (ADR-0010). Not an installer.

- `menu` strings are operator-facing and must stay exact.
- `id` values are stable keys for automation (`zenith` / `front-counter`).
- `spot_client_name` is the hosted SPOT `ClientName` when known. Null means not yet discovered — do not guess.
