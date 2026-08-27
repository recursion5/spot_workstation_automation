# ADR 0002 — WinRM/NTLM first, PSRP when proven

- Status: accepted
- Date: 2026-08-19

## Context

The constitution prefers WinRM/PowerShell Remoting, then Ansible `psrp` or `winrm`. The specimen is likely a workgroup Windows 11 Pro PC. The controller is Linux on `10.0.253.225`. SSH/OpenSSH on Windows is an extra surface.

## Decision

1. Bootstrap native WinRM on HTTP 5985, NTLM, firewall-restricted to the controller CIDR.
2. Set `LocalAccountTokenFilterPolicy=1` so a local administrator account can remote in (workgroup UAC remote restriction).
3. Use `pywinrm` for the first connectivity self-test.
4. Prefer Ansible `ansible_connection=psrp` once that path is proven; fall back to `winrm`.
5. Do not enable WinRM Basic auth or unencrypted message-mode unless a test shows NTLM is blocked.
6. Do not add OpenSSH unless WinRM is blocked by environment.

HTTPS/5986 with a local certificate is a follow-up ADR if the HTTP path must leave the management LAN.

## Alternatives considered

- OpenSSH immediately — extra install, not needed if WinRM works.
- WinRM HTTPS first — better crypto, more bootstrap friction while the operator is on site.
- Always-on cloud tunnel — out of scope for Phase 1 unless LAN routing fails.

## Consequences

Live PCs: operator ran `Bootstrap-WinRM.ps1` once. Replacements: the USB build applies the same WinRM bootstrap (ADR-0011 §8). OPNsense may need a 5985 allow from `10.0.253.225` to the POS VLAN.
