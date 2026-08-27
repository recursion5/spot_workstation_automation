# Agent instructions

This file is binding for any agent working in this repository.

## Read first, in order

1. [project-spec.md](project-spec.md)
2. [README.md](README.md)
3. [docs/DISCOVERY-REPORT.md](docs/DISCOVERY-REPORT.md)
4. [docs/STATUS.md](docs/STATUS.md)
5. [docs/OPEN-QUESTIONS.md](docs/OPEN-QUESTIONS.md)
6. [docs/DECISIONS/README.md](docs/DECISIONS/README.md) and any ADRs it lists as accepted
7. Current GitHub issues, or `docs/issues/` if GitHub Issues is not writable
8. The most recent discovery run manifest, if any (`evidence/` pointers or `SPOT_EVIDENCE_ROOT`)

Then inspect git status, repair missing scaffold required by the spec, and continue the current phase only.

## Current phase

Phase 1 evidence is in [docs/DISCOVERY-REPORT.md](docs/DISCOVERY-REPORT.md). **Phase 2** has started: desired-state recipes under [docs/desired-state/](docs/desired-state/). First row: [zenith-front-counter.md](docs/desired-state/zenith-front-counter.md). Do **not** implement USB/OOBE until the operator asks and NAS/account/browser opens that block a real stick are decided.

Do **not** implement replacement provisioning, OOBE automation, kiosk lockdown, or a final desired-state playbook until that analysis exists. Record candidate directions in docs and ADRs only. Do not collect more from SPOT PCs unless asked.

## Classification

Label every material statement as one of:

- Requirement
- Discovery
- Assumption
- Hypothesis
- Decision
- Open question

Do not silently convert assumptions into facts. If vendor documentation disagrees with the specimen, prefer the specimen and record the conflict.

## Safety and change control

- Default to non-destructive collection.
- Installing WinRM, scheduled tasks, Sysmon, ProcMon, or reboot-surviving collectors is a **change**. Treat it as an operator-approved, reversible bootstrap, not as “read-only.”
- Do not rename printers, disable devices, reinstall drivers, or alter Citrix/auto-logon to experiment.
- Never commit credentials, tokens, private keys, DPAPI material with decryptors, or unredacted sensitive captures.
- Large evidence lives outside git. Commit manifests, checksums, schemas, and tiny sanitized samples only.

## How to work

- Prefer native Windows/PowerShell collectors emitting JSON.
- Orchestrate from the Linux controller with Ansible (PSRP preferred when it works; WinRM/NTLM is the bootstrap transport).
- Collect both machine context and the auto-logon standard user’s context. Do not assume a SYSTEM collector sees that user’s HKCU.
- Printer/driver/port/PnP correlation is high priority. Unproven mappings are hypotheses.
- If a required directory, schema, test, issue template, or runbook section is missing, create it.
- Commit small, meaningful units. Record material decisions as ADRs.
- Use GitHub issues for nontrivial open work.

## First remaining milestone

A later agent can clone this repo, read `docs/DISCOVERY-REPORT.md`, reach the Zenith PCs with documented WinRM, and begin Phase 2 analysis (Front Counter desired state first) without this chat. Watchers on WS1/WS2/WS3 may have new files under `C:\ProgramData\spot-discovery\observe\`; pull only if needed. The 12-hour Grok loop is off.
