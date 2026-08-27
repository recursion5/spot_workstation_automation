# NAS secret pack (existence only)

**Status:** draft layout. **No values in git.**  
**Class:** Requirement (ADR-0005, ADR-0011, ADR-0013). Open: what to do if the share is down (Q-062 remainder). Live UNC `\\zenith-dsm.vogueclean.int\spot-rebuild`, user **`spot-rebuild`**. Password in controller `.env` / pack, not git.

The USB process must **apply** these so SPOT support does not remote in to finish a replacement. Pack root: `\\zenith-dsm.vogueclean.int\spot-rebuild` (operator, 2026-08-27). Git may list **file names and purpose** only.

Windows 11 Pro: **no product key in this pack** (COA / OEM on each box, ADR-0013).

This is not an installer. The share must exist and be readable by the stick before a real build.

---

## Suggested tree (names, not contents)

Machine-readable twin: [config/examples/secret-pack.manifest.example.yml](../../config/examples/secret-pack.manifest.example.yml).

```
\\zenith-dsm.vogueclean.int\spot-rebuild\
  common/
    rustdesk-id_ed25519.pub            # rendezvous public key
    rustdesk-server.txt                # rustdesk.vogueclean.int (non-secret; may live in git)
    packages/
      CitrixWorkspace-26.3.10.69-payload.zip  # staged from WS2 install dir (not CitrixWorkspaceApp.exe)
      SPOTLauncher-1.1.169.3-installed.zip    # installed tree; vendor Setup 1.1.167.1 leftover also kept
      APD_511R1_T88V_EWM.zip
      starprnt_v3.8.1.zip
      WASP_Fonts.zip
      CallerIdOverlay.exe              # video-wall row
      SS Client installer              # live 2.2.1 has no leftover setup; Downloads only 2.0.x
  rows/
    zenith-front-counter/              # VGCTX03COUNTER1 / ZENITH-WS1
      zenithadmin.password
      zenithuser.autologon
      spotlauncher/                    # ClientName, ConnectionMode 0, Citrix material
    zenith-mark-in-1/                  # VGCTX03COUNTER2 / ZENITH-WS2
      zenithadmin.password
      zenithuser.autologon
      spotlauncher/
    zenith-mark-in-2/                  # VGCTX03COUNTER3 / ZENITH-WS3
      zenithadmin.password
      zenithuser.autologon
      spotlauncher/
    zenith-management-desk/            # ZENITH-WORKDESK
      zenithadmin.password
      gayla.password                   # interactive; no autologon
    zenith-video-wall/                 # Z-SSTATION
      zenithadmin.password
      zenithuser.autologon
      calleridoverlay.token
      ss-client.login                  # Q-082
```

Admin password may be one value reused across rows; still store it in the pack, not git. Vogue rows get the same shape when those PCs are inventoried.

---

## Not secrets (may stay in git)

- Catalog `config/catalog/workstations.yml`
- Desired-state recipes in this directory
- RustDesk **hostname** `rustdesk.vogueclean.int`
- Windows printer **names**, `ClientName` strings, computer names
- Checksums of vendor zips (`evidence/vendor-installers.pointer.md`)

## Still missing as files (block a real stick)

| Item | Where it is today |
| --- | --- |
| NAS share created + USB auth | **Done.** `\\zenith-dsm.vogueclean.int\spot-rebuild` as `spot-rebuild`. Per-row passwords still for the operator to drop. |
| Official `CitrixWorkspaceApp.exe` | Not on disk. Staged: zip of the WS2 `Citrix Workspace 26.3.10.69` payload folder |
| Official `SPOTLauncherSetup_1.1.169.3.exe` | Installer gone (temp source). Staged: installed AppData tree zip + leftover 1.1.167.1 setup |
| SS Client **2.2.1.2565** installer | Installed; leftover Downloads are **2.0.1 / 2.0.2** only |
| CallerIdOverlay token | In `config.json` on the wall PC; never git. Binary staged to controller |
| Per-row launcher/Citrix secrets | Operator places on the NAS |
