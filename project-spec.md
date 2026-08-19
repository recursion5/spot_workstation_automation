# Windows POS Endpoint Reproducibility Project
## Project Constitution, Bootstrap Specification, and Phase 1 Discovery Task

**Status:** Initial project specification  
**Primary platform:** Windows 11 Pro point-of-sale workstations  
**Initial use case:** Commercial remotely hosted POS application delivered through Citrix/RDS-related client components, with locally attached peripherals  
**Current phase:** Project bootstrap and discovery/data collection only  
**Future phases:** Evidence analysis → reproducible provisioning/deployment → replacement validation and lifecycle operations

---

## 1. Purpose

This project exists to make a Windows point-of-sale workstation reproducible rather than manually rebuilt.

The long-term target is that a replacement Windows 11 Pro workstation can be identified using a small amount of business identity information—conceptually something like:

- store identifier;
- register/workstation identifier;
- optional hardware/peripheral role.

From that identity, automation should eventually be able to determine and apply the workstation's required state: local accounts, auto-logon behavior, Citrix/remote-application configuration, printer names and drivers, peripheral mappings, launch shortcuts, workstation-specific application identity or license parameters, and validation tests.

The current assignment is **not** to build that provisioning system yet.

The current assignment is to build the project infrastructure and collect enough high-quality evidence from one existing, functioning POS workstation to make a later provisioning design evidence-based.

The existing workstation is the initial specimen and source of truth. The discovery process must learn how it actually works rather than assume how it ought to work.

---

## 2. Project philosophy

### 2.1 Prefer reproducible state over cloned images

The desired end state is a reproducible recipe or desired-state description that survives reasonable hardware changes.

A raw disk image may be useful as backup evidence, but it is not the primary architectural target because:

- replacement hardware may differ;
- USB topology and device instance paths may change;
- Windows drivers may change;
- OEM Windows installations may differ;
- a cloned machine may carry stale identifiers or hardware-specific state.

The project should separate:

1. **business identity** — store/register/role;
2. **logical endpoint state** — printer names, Citrix settings, local accounts, shortcuts, application parameters;
3. **hardware bindings** — actual USB device instance, physical port, driver, COM/virtual USB mapping, network address, etc.;
4. **credentials/secrets** — which must not be carelessly exported into Git or logs.

### 2.2 Observe before changing

During Phase 1, default to read-only observation.

Do not rename printers, disable devices, reinstall drivers, alter Citrix configuration, change auto-logon settings, or otherwise perturb a production POS workstation merely to see what happens.

Active experiments may be proposed later, but each experiment must be:

- justified by a specific unanswered question;
- reversible;
- narrowly scoped;
- short in duration;
- approved by the operator before execution if it can affect business operation.

### 2.3 Distinguish facts from interpretation

Every project artifact must distinguish among:

- **Requirement** — something the operator says the future system must do.
- **Discovery** — something directly observed on a workstation or in documentation.
- **Assumption** — a working belief not yet proven.
- **Hypothesis** — an explanation to test.
- **Decision** — an intentional project choice.
- **Open question** — information still required.

Do not silently convert assumptions into facts.

### 2.4 Automate the project itself

Agents working in this repository are expected to improve the project infrastructure as part of their work.

If a required directory, manifest, script, test, issue template, documentation section, or other project mechanism is missing, create it rather than repeatedly handling the deficiency manually.

The repository should become increasingly self-describing and self-operating.

### 2.5 Keep the framework general

The POS workstation is the first implementation target, but discovery code should be designed as a reusable Windows endpoint discovery framework where practical.

Do not over-generalize at the expense of finishing the POS work, but keep collectors modular so they can later be reused for other Windows business applications.

---

## 3. Known environment

Treat the following as current requirements/context unless later evidence contradicts them.

### 3.1 Workstation

- Windows 11 Pro.
- Small-form-factor or fanless commercial PC hardware.
- Replacement PCs commonly arrive with an OEM Windows 11 Pro license and OEM-installed Windows.
- No requirement has been established for an Active Directory domain.
- A local administrative account exists.
- A local standard user account is used for normal POS operation.
- The standard user is configured for automatic Windows logon.
- Employees normally do not perform Windows authentication.
- After reboot, the standard desktop returns automatically.
- The employee launches the POS by double-clicking a shortcut.

### 3.2 POS architecture

- The POS is commercial software operated through a remote-hosted application/session.
- The local workstation uses Citrix technology of some form, possibly Citrix Workspace/Receiver components, together with Microsoft Remote Desktop Services or related provider-side infrastructure.
- Do **not** assume the exact Citrix product, version, connection method, StoreFront configuration, ICA behavior, or RDS architecture. Discover it.
- Application authentication visible to the employee occurs inside the POS application, typically by PIN.
- The local workstation appears to retain configuration sufficient to connect automatically to the correct provider environment/workstation identity before that in-application authentication occurs.
- Each workstation has an assigned identity/license/configuration in the POS provider's system.
- A replacement must ultimately reproduce that workstation-specific identity without requiring the business owner to reconstruct it manually.

### 3.3 Peripherals

Potential peripherals include:

- thermal receipt printers;
- other Windows printers;
- Citizen, Star, or similar POS printer hardware;
- USB printers;
- printer vendor virtual USB ports or other vendor-created logical ports;
- standard Windows USB printer ports;
- cash drawer functionality, potentially connected through a receipt printer or other interface;
- workstation roles that differ, such as a primary payment/cash-drawer register versus secondary registers.

The remote application expects certain Windows printers by **logical printer name**. Printer names may therefore be part of the application's interface contract.

A major discovery objective is to determine how stable logical names map to variable physical hardware and Windows device/port identifiers.

---

## 4. Long-term target state

The future provisioning workflow should be designed toward an operator experience approximately like:

1. Unbox a replacement Windows 11 Pro workstation.
2. Connect required peripherals and network.
3. Perform a minimal bootstrap mechanism.
4. Identify the intended endpoint, for example `store=<X>, register=<Y>`.
5. Automation determines the complete desired state for that identity.
6. Automation configures the workstation.
7. Validation confirms printers, remote application launch, peripheral behavior, and station identity.
8. The operator performs only a short acceptance test.

The future bootstrap may involve unattended Windows setup, removable media, network-assisted bootstrap, remote management, or another method. That design belongs to a later phase.

Do not let Phase 1 become distracted by solving Windows OOBE or replacement deployment before the specimen has been understood.

---

## 5. Agent operating rules

An agent entering this repository must begin by reading, in order:

1. this specification;
2. `README.md`;
3. `docs/STATUS.md`;
4. `docs/OPEN-QUESTIONS.md`;
5. `docs/DECISIONS/` or the ADR index;
6. current issues/tasks if accessible;
7. the most recent discovery run manifest, if any.

Then the agent must:

- inspect repository status;
- identify missing scaffold required by this specification;
- create or repair that scaffold;
- record material project decisions;
- avoid destroying prior evidence;
- work idempotently where practical;
- commit small, meaningful units of work;
- never commit credentials, authentication tokens, private keys, decrypted passwords, or unredacted sensitive captures.

If GitHub access is available, use GitHub issues for nontrivial open work, unresolved discoveries, bugs, and follow-up investigations. Local Markdown issue files may be used as a fallback if GitHub is unavailable.

---

## 6. Repository bootstrap

On the first run, create a maintainable repository structure similar to the following. Adjust it if implementation experience shows a better structure, but record material changes in an ADR.

```text
.
├── README.md
├── AGENTS.md
├── project-spec.md
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── examples/
│   ├── playbooks/
│   ├── roles/
│   └── requirements.yml
├── config/
│   ├── collectors/
│   ├── redaction/
│   └── examples/
├── docs/
│   ├── STATUS.md
│   ├── OPEN-QUESTIONS.md
│   ├── REQUIREMENTS.md
│   ├── DISCOVERIES.md
│   ├── RUNBOOK.md
│   ├── DATA-DICTIONARY.md
│   ├── DECISIONS/
│   │   └── README.md
│   └── diagrams/
├── scripts/
│   ├── controller/
│   ├── windows/
│   ├── validation/
│   └── packaging/
├── schemas/
├── tests/
├── samples/
│   └── sanitized/
├── evidence/
│   └── README.md
├── .gitignore
├── .gitattributes
└── LICENSE-or-NOTICE-as-appropriate
```

### 6.1 Evidence storage rule

Large or sensitive evidence must **not** be committed to normal Git history.

`evidence/` should contain documentation, manifests, pointers, checksums, schemas, and optionally tiny sanitized samples—not raw multi-gigabyte trace files or secret-bearing exports.

Actual evidence bundles may live:

- on the controller host outside the repository;
- on encrypted local storage;
- on an approved file share/object store;
- or in another explicitly documented evidence location.

Each evidence bundle must have a manifest committed or otherwise preserved with at least:

- run ID;
- target hostname;
- pseudonymous workstation/store/register identity where possible;
- start/end timestamps and timezone;
- collector versions;
- commands/configurations used;
- files produced;
- SHA-256 hashes;
- success/failure status;
- notes on any operator actions performed during capture;
- known gaps;
- redaction status.

---

## 7. Architecture Decision Records

Create an ADR mechanism under `docs/DECISIONS/`.

Record decisions that materially affect future reproducibility, such as:

- WinRM versus SSH versus another management transport;
- Ansible connection plugin choice;
- evidence storage format;
- use of scheduled tasks versus a temporary Windows service;
- adoption of Sysmon;
- trace retention period;
- schema choices;
- how secrets are represented;
- how workstation identity is modeled;
- whether a collector requires installation;
- why a tool was accepted or rejected.

Each ADR should include:

- context;
- decision;
- alternatives considered;
- consequences;
- status;
- date.

---

## 8. Controller and remote-management model

The preferred model is:

- orchestration/analysis runs on a separate controller;
- the Windows POS workstation is a managed target;
- no permanently interactive administrator desktop session is required;
- normal employee operation continues in the auto-logged-on standard-user session;
- privileged collectors run as services, scheduled tasks, or remote administrative commands as appropriate.

### 8.1 Remote management

Evaluate WinRM/PowerShell Remoting first because it is native to Windows and directly usable by Ansible.

Ansible currently supports Windows management over WinRM through the `psrp` and `winrm` connection plugins. Prefer PSRP when technically appropriate, but test against the actual environment rather than assuming.

SSH/OpenSSH may be evaluated later as an alternative management transport. Do not add another remote-management surface without a reason.

### 8.2 Initial bootstrap

The operator is willing to perform a small one-time bootstrap if necessary, such as enabling/configuring WinRM.

The agent must produce a precise bootstrap runbook that minimizes manual work. Once remote administrative access is established, the agent should install and configure discovery tooling remotely.

Do not require an administrator to remain logged in locally during business operation merely to keep collectors alive.

---

## 9. Security and credential handling

Security hardening is not the primary business goal of this project, but discovery must not create avoidable credential leakage.

### 9.1 Never commit

Never commit or upload to ordinary project storage:

- Windows account passwords;
- auto-logon passwords;
- Git private keys;
- WinRM credentials;
- Citrix credentials/tokens;
- provider credentials;
- application license secrets;
- authentication cookies;
- DPAPI-protected blobs accompanied by sufficient material to decrypt them;
- private certificates/keys;
- full memory dumps unless specifically approved.

### 9.2 Sensitive configuration

If a registry value, file, XML/JSON/INI configuration, shortcut argument, or connection file appears to contain credentials or authentication tokens:

1. capture its existence, path, owner, ACL, size, timestamp, hash, and structural metadata;
2. classify it as sensitive;
3. copy raw content only into protected evidence storage if necessary;
4. store a redacted representation in normal project artifacts;
5. document how later automation may need to obtain the secret legitimately.

The discovery phase must learn **where state lives** without casually distributing that state.

---

# Phase 1 — Discovery and Evidence Collection

## 10. Objective

Build and execute an automated discovery package against one known-good Windows 11 Pro POS workstation.

At the end of Phase 1, a later analysis agent must be able to answer, from evidence rather than guesswork:

- What software is required locally?
- What starts the remote POS session?
- What workstation-specific identity/configuration exists locally?
- Which files, registry keys, services, scheduled tasks, shortcuts, certificates, URLs, arguments, protocol handlers, and environment settings participate?
- What changes during POS startup and normal operation?
- Which Windows printers exist, under what exact names?
- Which printer drivers, ports, print processors, vendor utilities, and device instances support them?
- How do physical USB/PnP devices map to logical Windows printers?
- Which mappings appear hardware-specific and which appear stable?
- What local state would have to be reproduced on replacement hardware?
- What remains unknown and requires an active experiment or vendor information?

Do not write the final deployment playbook during this phase.

---

## 11. Discovery run strategy

Use three levels of collection.

### Level A — Baseline inventory

Low risk. Run once before detailed tracing.

Capture stable system state and configuration.

### Level B — Long-duration low-overhead observation

Run during one or more normal business days if operationally safe.

Use event-based/log-based collectors that are suitable for background use.

### Level C — Short high-detail traces

Run only around known workflows for short periods.

Examples:

- boot to ready state;
- standard-user logon;
- POS shortcut launch;
- Citrix/remote-session connection;
- printing a receipt;
- printing to each other relevant printer;
- cash-drawer action;
- reconnecting after a POS application exit;
- a controlled reboot if normally part of operations;
- a naturally occurring printer-recovery/restart event if one happens during the study.

Do not leave extremely verbose ProcMon or ETW traces running all day without first proving that the volume and overhead are acceptable.

---

## 12. Required tool evaluation

The agent must evaluate the tools below and implement only those that materially improve discovery.

### 12.1 Native Windows / PowerShell

Use native commands and APIs where possible for structured inventory, including:

- PowerShell;
- CIM/WMI;
- Windows event logs;
- `Get-Printer`;
- `Get-PrinterDriver`;
- printer port enumeration;
- `Get-PnpDevice` / relevant CIM classes;
- `pnputil` device and driver enumeration;
- services;
- scheduled tasks;
- Windows features/capabilities;
- local users/groups;
- registry;
- installed applications;
- environment variables;
- network configuration;
- firewall rules relevant to the application;
- certificates;
- startup entries;
- shortcuts;
- file hashes and signatures;
- process/module inventory.

Prefer JSON, CSV, XML, or other structured output over screenshots and prose.

### 12.2 Sysinternals Process Monitor

Use Process Monitor for short, targeted traces.

Primary purpose:

- file-system access;
- Registry access;
- process/thread activity;
- process tree and launch sequence;
- discovery of configuration files/keys accessed during POS startup;
- identifying missing-file or missing-key probes that reveal dependencies.

Build filters so traces focus on relevant process trees where possible.

Preserve the original capture format when useful for later analysis and export filtered structured views as supplemental evidence.

### 12.3 Sysmon

Evaluate Sysmon for medium-duration background telemetry.

It can provide persistent event-based visibility into system activity while avoiding an interactive monitoring session.

The agent must create a project-specific, conservative configuration rather than enabling maximal logging indiscriminately.

Potentially useful event classes include:

- process creation;
- process termination where useful;
- driver/image loading if justified;
- network connections relevant to POS/Citrix processes;
- file creation or configuration changes in narrowly selected paths;
- selected Registry events if sufficiently targeted.

Tune aggressively to avoid drowning the useful signal.

### 12.4 Windows Performance Recorder / ETW

Use WPR/ETW only where it answers questions that ProcMon/Sysmon/native inventory do not answer adequately.

Potential uses:

- device/USB timing;
- driver behavior;
- process startup dependencies;
- system-level activity around a reproducible peripheral problem.

Prefer short captures.

### 12.5 Process Explorer / Autoruns and related Sysinternals utilities

Use when useful to identify:

- process ancestry;
- loaded modules/DLLs;
- handles;
- services/drivers;
- startup mechanisms;
- shell extensions or auto-start locations.

Do not collect data merely because a tool exists.

### 12.6 Optional comparison tools

A before/after registry or file-system diff tool may be used for a controlled change, but it is secondary to ProcMon and scripted state capture.

If a third-party open-source utility is introduced:

- record source/project;
- pin or record the version;
- hash the binary/package;
- document why it is needed;
- verify licensing is compatible with the project;
- avoid opaque binaries when native tooling can do the job.

---

## 13. Baseline inventory requirements

At minimum, capture the following.

### 13.1 System identity and Windows state

- computer name;
- manufacturer/model;
- BIOS/UEFI version and serial identifiers as appropriate;
- CPU architecture;
- storage devices;
- Windows edition/build;
- activation/license channel metadata that can be safely collected;
- Windows update state;
- installed Windows capabilities/features;
- locale/timezone;
- power configuration;
- relevant group policy/local policy results if applicable.

### 13.2 Accounts and logon behavior

Capture:

- local users;
- local groups and membership;
- which account auto-logs on;
- mechanisms that implement auto-logon;
- startup items for the standard user and machine;
- shell behavior;
- desktop/start-menu/taskbar items relevant to POS operation.

Do **not** expose plaintext passwords in normal output.

### 13.3 Software

Enumerate installed software using multiple reliable sources where needed.

Specifically identify:

- Citrix Receiver/Workspace components;
- Citrix browser/ICA/protocol handlers;
- Microsoft RDP/RDS-related client components if relevant;
- POS-launch helper applications;
- printer vendor packages/utilities;
- payment/peripheral middleware;
- Visual C++/.NET/Java or other runtimes directly relevant to observed processes;
- device-management utilities;
- locally installed POS components even if the primary application is remote.

For each relevant package capture:

- display name;
- version;
- publisher;
- install path;
- uninstall information;
- MSI/product code if applicable;
- executable hashes/signatures where useful.

### 13.4 Services, drivers, tasks, startup

Capture all and flag likely POS-related items:

- Windows services;
- kernel/device drivers;
- scheduled tasks;
- startup registry entries;
- startup-folder items;
- Run/RunOnce locations;
- vendor background agents.

### 13.5 Files and configuration

Identify configuration in common and observed locations, including:

- Program Files;
- Program Files (x86);
- ProgramData;
- standard user's AppData trees;
- administrative user's relevant AppData only if actually involved;
- Public Desktop;
- standard user's Desktop;
- Start Menu;
- Citrix-related directories;
- vendor-specific directories;
- INI/XML/JSON/config/database files used by the launch path.

For relevant files capture:

- full path;
- owner/ACL;
- timestamps;
- size;
- SHA-256;
- signer where executable;
- sanitized content or structural metadata as appropriate.

### 13.6 Registry

Inventory relevant keys from:

- HKLM;
- HKCU for the auto-logon standard user;
- WOW6432Node where relevant;
- Citrix-related keys;
- printer/port keys;
- vendor driver/software keys;
- application URL/protocol handler registrations;
- auto-start and auto-logon related areas.

Capture raw key exports only when justified and store sensitive exports appropriately.

---

## 14. Printer and peripheral discovery — high priority

This is a central part of the study.

### 14.1 Logical printer inventory

For every installed printer capture at least:

- exact Windows printer name;
- share name if any;
- driver name;
- port name;
- print processor;
- datatype;
- default-printer status;
- status;
- location/comment;
- relevant advanced properties;
- per-user versus machine visibility where relevant.

Treat exact spelling of printer names as potentially application-critical.

### 14.2 Printer drivers

Capture:

- installed print driver records;
- driver package/provider/version/date;
- INF names and driver-store package metadata;
- architecture;
- dependent files;
- vendor utilities/services;
- driver signatures;
- package hashes where practical.

Use `pnputil` and PrintManagement data together when useful.

### 14.3 Printer ports

Inventory all relevant Windows print ports and determine their type:

- USB;
- vendor virtual USB;
- Standard TCP/IP;
- WSD;
- local port;
- COM/LPT;
- vendor-specific port monitor.

Capture port monitor/provider information.

### 14.4 PnP/USB topology

For relevant devices capture:

- friendly name;
- device instance ID;
- hardware IDs;
- compatible IDs;
- class/class GUID;
- service;
- manufacturer;
- parent/child relationships;
- container ID where available;
- location paths;
- bus type;
- interface information;
- current driver binding;
- connected/disconnected state if useful.

The analysis phase will later try to determine which fields are stable enough to identify a printer model or unit across replacement hardware and which are tied to a particular USB controller/physical port.

### 14.5 Correlation

The discovery agent must attempt to build a machine-readable correlation table:

```text
logical_printer
  -> windows_port
  -> port_monitor
  -> PnP/interface/device
  -> driver
  -> physical/vendor identity
```

If correlation cannot be proven, label it a hypothesis rather than inventing a mapping.

### 14.6 Peripherals beyond printers

Apply the same approach to:

- cash drawer;
- payment-related device;
- barcode scanner if present;
- serial/virtual COM devices;
- USB HID devices relevant to POS;
- vendor middleware.

---

## 15. POS launch-path discovery

The agent must determine exactly what happens after the employee double-clicks the POS shortcut.

Capture:

1. shortcut path and owner;
2. shortcut target;
3. command-line arguments;
4. working directory;
5. icon/source as a clue only;
6. protocol or URL invoked, if any;
7. initial process;
8. descendant process tree;
9. configuration files opened;
10. Registry keys accessed;
11. DNS/network destinations if observable without decrypting traffic;
12. Citrix/ICA files or temporary artifacts;
13. remote-session client process;
14. printer-redirection components;
15. any locally stored station/license/client identifier involved in launch.

A later agent should be able to reconstruct the launch sequence as a state machine or dependency graph.

---

## 16. Network discovery

Capture enough network information to understand dependencies without turning the project into packet surveillance.

Collect:

- interface configuration;
- DNS servers/search suffix;
- routes;
- proxy configuration;
- relevant firewall state;
- active connections associated with POS/Citrix processes during a short trace;
- remote hostnames and ports;
- certificate metadata presented by relevant TLS endpoints where practical.

Do not attempt to bypass TLS or capture user secrets.

A packet capture is optional and should be used only if a specific unanswered dependency warrants it.

---

## 17. Event logs

Inventory available Windows logs, then export a targeted subset around:

- boot;
- user logon;
- device arrival/removal;
- print subsystem;
- driver installation/initialization;
- application errors;
- Citrix/client errors;
- network/authentication errors relevant to the remote application;
- printer spooler events.

Preserve native `.evtx` when useful and also produce machine-readable summaries.

Record exactly which logs were enabled or had their retention settings changed.

Do not clear logs.

---

## 18. Normal-use observation period

Design the system so the workstation can remain in normal production use while low-overhead collectors run in the background.

Target observation period:

- at least one representative business day where practical;
- optionally several days if useful for naturally occurring printer/reconnect/reboot events.

The operator should not need to leave an administrator session logged on.

Collectors should survive:

- user logoff/logon;
- standard-user auto-logon;
- workstation reboot, when intentionally configured to do so.

The agent must measure resource impact before leaving a collector active for a full business day.

If a collector causes meaningful CPU, disk, memory, UI, print, or network impact, disable it and document why.

---

## 19. High-detail workflow traces

Create a repeatable command or orchestration action to capture short trace windows.

Each trace run must have:

- a run ID;
- scenario name;
- start marker;
- stop marker;
- operator notes;
- clock synchronization check;
- exact collector configuration;
- generated artifact list.

Suggested scenarios:

### Scenario A — POS cold launch

From normal standard-user desktop:

1. begin trace;
2. launch POS exactly as employee normally does;
3. wait until application is usable;
4. perform no additional activity for a short stabilization period;
5. stop trace.

### Scenario B — Receipt print

1. begin trace;
2. perform one representative transaction or safe test that prints to the thermal printer;
3. include cash-drawer action if normal and safe;
4. stop trace.

### Scenario C — Other printer

Repeat for each materially different printer.

### Scenario D — Reconnect/relaunch

Capture normal POS exit and relaunch.

### Scenario E — Reboot-to-ready

Only when business conditions permit:

1. mark start;
2. reboot;
3. let normal auto-logon occur;
4. wait for desktop readiness;
5. launch POS;
6. stop once usable.

If the tracing technology cannot span reboot directly, correlate separate pre-reboot and post-boot evidence using timestamps and run IDs.

---

## 20. User-context versus system-context collection

Some configuration is machine-wide and some is specific to the standard user's profile.

The agent must deliberately collect both contexts.

Privileged background collectors may run as `SYSTEM` or an administrative account, but user-profile evidence must be attributed to the actual auto-logon standard user.

Do not assume that querying HKCU from a privileged service reveals the employee user's HKCU.

Where necessary, load/read the standard user's profile hive in a controlled read-only way or execute a narrowly scoped collector in that user's context.

Document the mechanism.

---

## 21. Implementation requirements for collectors

Collectors should be:

- scriptable;
- noninteractive once deployed;
- remotely startable/stoppable where practical;
- idempotent;
- versioned;
- logged;
- self-validating;
- able to package their output;
- able to uninstall/clean up temporary tooling.

Each collector should emit a small status record such as:

```json
{
  "collector": "printer_inventory",
  "version": "1",
  "run_id": "example",
  "started_at": "ISO-8601",
  "ended_at": "ISO-8601",
  "status": "success",
  "output_files": [],
  "warnings": []
}
```

Define schemas under `schemas/` for major structured outputs.

---

## 22. Remote orchestration tasks

The controller should eventually support commands conceptually equivalent to:

```text
bootstrap-target
verify-connectivity
install-discovery-tools
baseline-inventory
start-background-observation
stop-background-observation
start-trace --scenario <name>
stop-trace
collect-evidence
validate-evidence
package-evidence
remove-temporary-tools
report-status
```

These names are conceptual. Implement an interface appropriate to the chosen tooling.

Ansible may be used to orchestrate repeatable Windows configuration and collection tasks, while PowerShell performs Windows-native discovery.

Do not force every operation into Ansible if a PowerShell module/script is clearer.

---

## 23. Evidence packaging

At the completion of a discovery run, create a bundle with a predictable structure, for example:

```text
<run-id>/
├── manifest.json
├── operator-notes.md
├── baseline/
├── printers/
├── pnp/
├── software/
├── registry/
├── files/
├── eventlogs/
├── traces/
│   ├── pos-launch/
│   ├── receipt-print/
│   └── ...
├── network/
├── hashes/
└── reports/
```

Generate a top-level SHA-256 checksum manifest.

The package must be self-describing enough that an analysis agent does not need access to this conversation to understand it.

---

## 24. Discovery report

At the end of Phase 1, generate `docs/DISCOVERY-REPORT.md`.

It must include:

### Confirmed discoveries

Facts supported by collected evidence.

### Dependency map

A concise graph/table showing:

- desktop shortcut;
- launch process;
- Citrix/remote client;
- local configuration;
- remote endpoints;
- printer names;
- drivers;
- ports;
- PnP devices;
- relevant services.

### Workstation-specific state

Identify state believed to distinguish this register from another register or store.

Examples might include:

- station/client/license identifier;
- shortcut argument;
- URL;
- Citrix resource identifier;
- config file value;
- registry value;
- printer set;
- printer logical names;
- cash-drawer role.

Do not assume any of these actually exist until observed.

### Hardware-bound state

List configuration tied to the current physical PC or USB topology that should probably **not** be copied literally to new hardware.

### Candidate reproducible state

List items that appear suitable for future declarative deployment.

### Unknowns

List unanswered questions.

### Proposed experiments

For every proposed active experiment include:

- question answered;
- exact change;
- expected duration;
- production risk;
- rollback;
- evidence to capture;
- approval requirement.

### Vendor questions

List information that would be useful to request from the POS provider, Citrix provider, or printer vendor.

---

## 25. Phase 1 acceptance criteria

Phase 1 is complete only when all of the following are true:

- repository scaffold exists and is documented;
- agent startup/session rules exist;
- ADR mechanism exists;
- project status and open-question tracking exist;
- remote-management/bootstrap path has been tested or its blocker is documented;
- baseline inventory runs automatically;
- printer/driver/port/PnP inventory is captured in structured form;
- POS launch trace has been captured;
- at least one representative printing trace has been captured when operationally possible;
- low-overhead observation has been tested;
- evidence bundle is packaged and checksummed;
- no known secrets were committed to Git;
- discovery report exists;
- discoveries, assumptions, hypotheses, and open questions are clearly separated;
- the next analysis agent can begin without needing this chat transcript.

---

# Later phases — context only

## 26. Phase 2: Evidence analysis

A later agent will analyze Phase 1 evidence to derive a reproducible workstation-state model.

Expected outputs include:

- dependency graph;
- canonical station configuration schema;
- stable-versus-hardware-specific mapping rules;
- secret-handling design;
- printer-device matching strategy;
- Citrix/application deployment strategy;
- proposed desired-state implementation;
- test matrix for alternate hardware.

Phase 2 should determine whether Ansible + PowerShell is sufficient or whether additional packaging/configuration technology is justified.

## 27. Phase 3: Provisioning and replacement

Only after Phase 2 should the project implement replacement automation.

The eventual experience should aim toward entering only business identity such as store and register, with everything else derived from configuration.

Topics for that phase include:

- Windows OEM/OOBE bootstrap;
- unattended setup;
- account creation;
- auto-logon;
- remote management;
- application/client installation;
- station-specific configuration;
- printer and peripheral provisioning;
- validation;
- rollback/retry;
- optional Windows UI reduction or kiosk-like presentation.

Hardening and OS reduction are useful secondary goals, not prerequisites for proving reproducible replacement.

---

## 28. Initial tasks for the first agent

On first entry to the project, perform these tasks in order:

1. Read this specification completely.
2. Inspect repository and Git/GitHub availability.
3. Create missing project scaffold.
4. Create `README.md`, `AGENTS.md`, `docs/STATUS.md`, `docs/OPEN-QUESTIONS.md`, `docs/REQUIREMENTS.md`, and ADR infrastructure.
5. Add `.gitignore` rules to exclude credentials, raw evidence bundles, ProcMon traces, ETL traces, EVTX collections, dumps, and other large/sensitive artifacts by default.
6. Establish coding/script conventions for PowerShell, Python if used, YAML, and JSON.
7. Create a target-inventory example that contains no real credentials.
8. Design the Windows remote bootstrap procedure, favoring WinRM/PowerShell Remoting unless evidence favors another approach.
9. Implement a non-destructive remote connectivity/self-test.
10. Implement the baseline inventory collectors.
11. Implement the printer/driver/port/PnP collector as an early priority.
12. Implement evidence manifests and packaging before collecting large amounts of data.
13. Evaluate ProcMon, Sysmon, and WPR for the defined trace tiers.
14. Build start/stop orchestration for short trace scenarios.
15. Test collectors for overhead and failure behavior.
16. Perform the first approved discovery run.
17. Generate the discovery report and open issues for unknowns.
18. Stop. Do not begin Phase 2 deployment design except to record observations and candidate directions.

---

## 29. Definition of a successful first project milestone

The first milestone is not "we automated the POS."

The first milestone is:

> A fresh agent can clone/open the repository, remotely interrogate a designated Windows 11 Pro POS workstation using documented administrative access, install or invoke approved discovery tooling, collect a reproducible evidence bundle while ordinary POS use continues, and produce a structured report explaining the workstation's observed dependencies without requiring knowledge from the original conversation.

That is the foundation on which reliable automated replacement can be built.

---

## 30. Technical references to verify during implementation

Agents should prefer primary documentation and confirm current behavior rather than relying on old Windows-administration assumptions.

Relevant documentation families include:

- Microsoft PowerShell Remoting and WinRM documentation;
- Microsoft Sysinternals Process Monitor documentation;
- Microsoft Sysinternals Sysmon documentation;
- Microsoft Windows Performance Recorder / Windows Performance Toolkit documentation;
- Microsoft PrintManagement PowerShell cmdlets;
- Microsoft PnPUtil documentation;
- Microsoft Windows Event Log / `wevtutil` documentation;
- Ansible Windows management documentation, especially WinRM and PSRP.

Pin tool versions in evidence manifests whenever versions can affect behavior.

---

## 31. Change control

This document is authoritative for project intent but not immutable.

If implementation evidence proves a requirement or architectural assumption wrong:

1. preserve the original evidence;
2. record the discovery;
3. create an ADR for a material design change;
4. update this specification deliberately;
5. record the change in Git.

Do not silently rewrite history to make the project appear more certain than it was.
