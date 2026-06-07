# CHANGELOG — SteamDeckMSX_Stream_Server

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
