# Architecture Decision Records

Each ADR is `NNNN-short-title.md` in this directory.

Template:

- Title
- Status (`proposed` / `accepted` / `superseded` / `rejected`)
- Date
- Context
- Decision
- Alternatives considered
- Consequences

## Index

| ID | Title | Status |
| --- | --- | --- |
| [0001](0001-adr-process.md) | Record material decisions as ADRs | accepted |
| [0002](0002-management-transport-winrm.md) | WinRM/NTLM first, PSRP when proven | accepted |
| [0003](0003-evidence-storage.md) | Evidence outside git; manifests inside | accepted |
| [0004](0004-controller-tooling.md) | Linux controller, PowerShell on Windows, Ansible + Python | accepted |
| [0005](0005-secrets-handling.md) | Secrets never in git; existence-only in git-safe JSON | accepted |
| [0006](0006-specimen-identity.md) | Placeholder store/register until operator supplies codes | accepted |
| [0007](0007-sysmon-deferred.md) | Do not install Sysmon until approved | accepted |
| [0008](0008-internal-notice.md) | Internal NOTICE, no public license | accepted |
| [0009](0009-rds-not-citrix.md) | Replacement launch is SPOTLauncher RDS, not Citrix | accepted |
