# deploy/state.md — live deploy-state HC55

## v0.1.0-Gradius — deployed 2026-07-22

| Item | Waarde |
|---|---|
| Sunshine | 2026.516 (LizardByte .deb, `/usr/bin/sunshine`) |
| openMSX | 19.1 via **apt** (afwijking: geen source-build; symlinks in `/opt/steamdeckmsx/`) |
| Service | `steamdeckmsx-sunshine.service` — active, enabled |
| Display | Xvfb :0 1280x800x24 via ExecStartPre (PrivateTmp-namespace van de unit) |
| Audio | PulseAudio (msx-user, `PULSE_RUNTIME_PATH=/run/sunshine/pulse`), sink `auto_null` |
| Poorten | TCP 47984/47989/47990/48010 + UDP 47998-48002 — ufw open (Anywhere) |
| ROMs | `/var/lib/steamdeckmsx/roms/{nemesis.rom,nemesis2.rom}` (eigen dumps, msx:msx) |
| Creds web-UI | `ClaudeSecrets/secrets/steamdeckmsx/sunshine-webui` |
| Backup | `/root/backups/2026-07-22_sunshine_predeploy/` (ufw, ss, services, nginx) |
| Baseline | horseaccounting + llmshapes waren al inactief vóór deploy |
| Smoke-bewijs | Konami-logo screenshot uit C-BIOS_MSX2 + nemesis2.rom onder Xvfb :5 |

## Pairing-procedure (Client v0.0.3)

Web-UI is origin-restricted (extern → 403, bewust). PIN invoeren via tunnel:

```bash
# Op de Mac:
ssh -i ~/.ssh/hetzner -L 47990:localhost:47990 root@icthorsecloud.nl
# Browser: https://localhost:47990  (creds: zie ClaudeSecrets)
# Op de Deck: Moonlight → host icthorsecloud.nl → PIN verschijnt → invullen in web-UI
```

## Rollback

```bash
systemctl disable --now steamdeckmsx-sunshine.service
ufw delete allow 47984/tcp; ufw delete allow 47989/tcp; ufw delete allow 47990/tcp
ufw delete allow 48010/tcp; ufw delete allow 47998:48002/udp
```
