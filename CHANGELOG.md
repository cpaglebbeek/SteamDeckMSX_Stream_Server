# CHANGELOG — SteamDeckMSX_Stream_Server

## v0.2.0-Twinbee (2026-07-22) — WebClient /steam/konami LIVE (oranje)

> Tussenstap tussen "niets op de Deck" en Moonlight-pairing: Nemesis 1 + 2
> browser-speelbaar op https://horsecloud55.ddns.net/steam/konami/ — client-side
> emulatie (WebMSX 6.0.8 C-BIOS-build), gamepad-support, geen pairing nodig.

- `deploy/webclient/` — landing + nemesis1/2.html + nginx-snippet + README
- nginx: include-snippet `steamdeckmsx-web.conf` in sites-enabled/horsecloud
  (:443), `auth_basic off` per user-besluit publiek open; noindex + geen listing;
  location-count voor=na=61, nginx -t OK, alle services up
- Verificatie: Playwright-screenshots — beide Konami-logo's booten in Chromium
- **BUG-005 (geel):** WMSX-page-config vóór script-include wordt overschreven —
  wmsx.js definieert `WMSX` onvoorwaardelijk; config hoort NÁ de include (RCA in BUGLIST.md)

## v0.1.0-Gradius (2026-07-22) — EERSTE ECHTE HC55-DEPLOY: Sunshine + openMSX LIVE (oranje)

> Codenaam **Gradius** = de Japanse naam van **Nemesis** — passend: deze release
> zet Nemesis daadwerkelijk draaiend op HC55. Smoke-test-bewijs: Konami-logo
> screenshot uit openMSX + C-BIOS_MSX2 + nemesis2.rom onder Xvfb.

### Deployed op HC55 (2026-07-22)
- Sunshine 2026.516 (.deb LizardByte) — service `steamdeckmsx-sunshine.service`
  **active**, encoder libx264 [software] gevonden, main loop draait
- openMSX **19.1 via apt** + Xvfb + PulseAudio — AFWIJKING van plan (source-build
  `--enable-headless`): apt-pakket + symlinks `/opt/steamdeckmsx/bin/openmsx` →
  `/usr/bin/openmsx` en `/opt/steamdeckmsx/share/openmsx` → `/usr/share/openmsx`.
  C-BIOS-machines zitten in het apt-pakket (P-SDM-05 intact, geen MS-BIOS).
- msx-user + dirs + configs conform plan; ufw 47984/47989/47990/48010 TCP +
  47998:48002 UDP open; alle 5 regels met comment
- Web-UI-credentials gezet via `sunshine --creds` — wachtwoord in
  `ClaudeSecrets/secrets/steamdeckmsx/sunshine-webui` (NIET in transcript/repo)
- ROMs (eigen dumps): `nemesis.rom` + `nemesis2.rom` in `/var/lib/steamdeckmsx/roms/`
- Health-check: alle HC55-services identiek aan pre-deploy baseline
  (horseaccounting + llmshapes waren al inactief vóór deploy); nginx -t OK,
  sites-enabled identiek aan backup `/root/backups/2026-07-22_sunshine_predeploy/`

### Bugfixes (RCA in BUGLIST.md)
- **BUG-001 (geel)** — Sunshine fatal "Unable to find display or encoder": Xvfb
  werd pas per-app gestart (prep-cmd), Sunshine test capture bij startup →
  Xvfb + pulseaudio nu via ExecStartPre in unit; DISPLAY=:0 + XDG_RUNTIME_DIR=/run/sunshine
- **BUG-002 (geel)** — sunshine.conf-parser kent GEEN inline comments en GEEN
  quotes: `sw_preset = ultrafast ## TWEAK…` en `output_name = ":0"` werden
  corrupte waarden (displaynummer 1478615952). Alle TWEAK-comments naar eigen
  regel, quotes weg, `output_name = 0` (integer index), `audio_sink = auto_null.monitor`
- **BUG-003 (groen)** — `/run/sunshine` bestond niet voor xvfb-pidfiles →
  `RuntimeDirectory=sunshine` + `RuntimeDirectoryPreserve=yes`
- **BUG-004 (groen)** — ongeldige flag `-display ::0` in apps.json C-BIOS-entry
  verwijderd; `SDL_AUDIODRIVER=pulseaudio` toegevoegd (geen /dev/snd op VPS)

### Nieuw
- apps.json: 5e entry **"MSX1 — Nemesis (Gradius)"** (`nemesis.rom`)
- `deploy/state.md` — live deploy-state HC55

### Open naar v0.1.1 / Client v0.0.3
- Pairing + live stream-test vanaf Steam Deck (PIN via ssh-tunnel :47990)
- Boxart-PNG's ontbreken (`image-path` verwijst naar niet-bestaande files — cosmetisch)
- Sunshine web-UI origin-restricted (403 extern) — bewust; tunnel-procedure in state.md

## v0.0.2-Parodius (2026-06-07) — Sunshine config-artefacten + systemd unit (oranje)

> **GEEN HC55-deploy.** Alle artefacten zijn voorbereid in de repo en wachten op
> expliciet WhatIf + akkoord per `CLAUDE.md` § Deploy Protocol. Deploy verschuift
> naar v0.0.3 (Sunshine .deb install + openMSX-headless build).

### Sunshine config
- `deploy/sunshine/sunshine.conf.template` — software x264 (HC55 = CPU-only),
  `ultrafast` preset, `zerolatency` tune, `hevc_mode=0`, `upnp=off`,
  log-niveau `info`, Xvfb display `:0`. TWEAK-comments per regel.
- `deploy/sunshine/apps.json` — 4 MSX-app-entries:
  1. **C-BIOS shell (default)** — boot zonder ROM
  2. **MSX1 Bubble Bobble** — Konami-mapper-test
  3. **MSX2 Metal Gear** — MSX2 + grotere ROM
  4. **MSX2 Nemesis 2** — SCC-audio-test
  Iedere entry start Xvfb via `prep-cmd do/undo` (idempotent). C-BIOS-only,
  geen MS-BIOS in repo conform P-SDM-05.

### Xvfb wrapper-script
- `deploy/sunshine/xvfb-wrapper.sh` (chmod 755) — idempotente start/stop van
  Xvfb display met pid-tracking in `/run/sunshine/`. Timeout 5s op socket-check.
  Aangeroepen vanuit `apps.json prep-cmd`.

### systemd unit
- `deploy/systemd/steamdeckmsx-sunshine.service` — `User=msx`,
  `CPUQuota=200%` (cap 2/4 cores HC55), `Nice=5`, `MemoryHigh=1.5G`/`Max=2G`,
  `Restart=on-failure` max 5/60s, security-hardening (NoNewPrivileges,
  PrivateTmp, ProtectSystem=strict, ReadWritePaths whitelist).
- `WantedBy=multi-user.target` — start na boot.

### SHARED_INFRA_PATCH.md (inhoudelijk afgerond)
- Poort-tabel verfijnd met TCP/UDP-onderscheid + per-poort doel
  (HTTPS/HTTP-PIN/web-UI/RTSP/RTP/mic).
- **Conflict-check uitgevoerd vs. 14 bekende HC55-services** (Dashboard, ClaudeWeb,
  CarriereCV, MacTerminal, PrioMail, RandomRingtone Logger, ArchiSaas, HorseSafe,
  Facturatie, ClaudeBug, HorseAPK, FODMAP, LLMShapes, PortalToExact) — alle vrij.
- Oorzaak/gevolg-matrix uitgebreid met 3 patronen:
  CPU-contention, Xvfb-crash, self-signed-cert-acceptatie.
- Nginx-impact expliciet: **GEEN** (Sunshine direct met self-signed TLS).
- ufw + Hetzner Cloud Firewall regels gedocumenteerd voor v0.0.3 deploy.
- Status-blok: deployed = **NEE**, merge in Meta_Master = TODO bij v0.0.3.

### Wat NIET in deze release
- **Geen daadwerkelijke HC55-deploy** — Sunshine .deb install + service-registratie
  + nginx/ufw mutaties verschuiven naar v0.0.3 met expliciete WhatIf.
- **Geen openMSX-headless build** — out-of-box headless-mode-onderzoek loopt;
  fallback Xvfb-wrapper is hier al voorbereid.
- **Geen SHARED_INFRA_PATCH merge** in `Meta_Master/SHARED_INFRASTRUCTURE.md` —
  doe ik pas bij v0.0.3 deploy-akkoord.
- **Geen TLS-cert** (self-signed vs Let's Encrypt) — v0.0.3 open vraag.

### Codenaam-correctie
Oorspronkelijk gepland: **Aleste**. Conflict gedetecteerd: Aleste is al Native v0.0.4.
Gewijzigd naar **Parodius** (Konami MSX2 1988 — Gradius-vervolg, past bij streaming-server-rol als grappige spiegeling op de Stream_Client = Salamander koppeling).

### Kleurcode: ORANJE (+0.1.0)
Nieuwe systemd-service (unit-file) + Sunshine-config-template + apps.json + Xvfb-wrapper-script + uitgebreide SHARED_INFRA_PATCH = nieuwe componenten met
shared-infra-impact-claim (poort-reservering + CPU-budget-claim). Conform
`CLAUDE.md` § Color-Coded: oranje.

## v0.0.1-Knightmare (2026-05-31) — Skeleton

- Initiële repo-structuur (newp)
- README, LICENSE (AGPL-3.0), CLAUDE.md, ARCHITECTURE.md, BUGLIST.md
- HC55-poort-claim 47984-48010 gedocumenteerd in `SHARED_INFRA_PATCH.md` (te mergen bij eerste deploy)
- Geen deploy, geen code, geen Sunshine-install
