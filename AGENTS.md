# Agent instructions

This file is binding for any agent working in this repository.

## Read first, in order

1. [project-spec.md](project-spec.md)
2. [README.md](README.md)
3. [docs/STATUS.md](docs/STATUS.md)
4. [docs/OPEN-QUESTIONS.md](docs/OPEN-QUESTIONS.md)
5. [docs/DECISIONS/README.md](docs/DECISIONS/README.md) and any ADRs it lists as accepted
6. Current GitHub issues
7. The most recent discovery run manifest, if any (`evidence/` pointers or `SPOT_EVIDENCE_ROOT`)

Then inspect git status, repair missing scaffold required by the spec, and continue the current phase only.

## Current phase

Phase 1 — project infrastructure and evidence collection from one specimen workstation.

Do **not** implement replacement provisioning, OOBE automation, kiosk lockdown, or a final desired-state playbook. Record candidate directions in docs and ADRs only.

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

A later agent can clone this repo, reach the designated Windows 11 Pro POS PC with documented admin access, run approved discovery, package a checksummed evidence bundle while ordinary SPOT use continues, and write `docs/DISCOVERY-REPORT.md` without this chat.
