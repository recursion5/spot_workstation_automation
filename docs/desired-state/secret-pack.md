# NAS secret pack (existence only)

**Status:** draft layout. **No values in git.**  
**Class:** Requirement (ADR-0005, ADR-0011) + Open question (Q-074 share path, Q-062 USB-if-NAS-down).

The USB process must **apply** these so SPOT support does not remote in to finish a replacement. Values live on `dsm.vogueclean.int` (also `zenith-dsm` / `10.0.253.110`). Git may list **file names and purpose** only.

This is not an installer. Until Q-074 is answered, nothing can be pulled at build time.

---

## Suggested tree (names, not contents)

Machine-readable twin: [config/examples/secret-pack.manifest.example.yml](../../config/examples/secret-pack.manifest.example.yml).

```
spot-rebuild/                          # share path TBD
  common/
    rustdesk-id_ed25519.pub            # rendezvous public key
    rustdesk-server.txt                # rustdesk.vogueclean.int (non-secret; may live in git)
    win11-product-key.txt              # Q-071; or omit if OEM digital entitlement
    packages/
      CitrixWorkspace-26.3.10.69.*     # NOT captured yet (live installed on WS2)
      SPOTLauncherSetup_1.1.169.3.exe  # NOT captured yet (only 1.1.167.1 leftover)
      APD_511R1_T88V_EWM.zip           # on controller vendor-installers/
      starprnt_v3.8.1.zip              # on controller vendor-installers/
      WASP_Fonts.zip                   # on controller vendor-installers/
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
| NAS share + USB auth | Q-074 unanswered |
| Citrix Workspace 26.3.10.69 installer | Installed on WS2; installer not copied |
| SPOTLauncher 1.1.169.3 installer | Installed under shop-floor AppData; only older 1.1.167.1 copied |
| SS Client installer | Installed on Z-SSTATION; not copied |
| CallerIdOverlay.exe + token | On Z-SSTATION; token not in git; binary not copied |
| Per-row launcher/Citrix secrets | On live PCs / SPOT farm; must be operator-placed on NAS |
