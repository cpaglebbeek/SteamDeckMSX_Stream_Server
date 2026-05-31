# CLAUDE.md — SteamDeckMSX_Stream_Server

> Variant 2 server-side. Draait op HC55. Erft regels van `Meta_Master/CLAUDE.md` + leest **ALTIJD** `Meta_Master/SHARED_INFRASTRUCTURE.md` vóór elke deploy-actie.

## Rol

openMSX-headless + Sunshine streaming-host op HorseCloud55. Single-user in v0.1.x.

## Codenaam-thema

MSX-game-helden. v0.0.1 = **Knightmare**. **Vrije pool + rotatie-regels:** zie `Meta_SteamDeckMSX/CLAUDE.md` § Codenaam-thema (single source of truth).

## SHARED INFRASTRUCTURE — VERPLICHT raadplegen

Voordat je ook maar één HC55-actie uitvoert (poort, nginx, systemd):
1. `git -C Meta_Master pull`
2. Lees `Meta_Master/SHARED_INFRASTRUCTURE.md`
3. Verifieer dat de Sunshine-poorten (47984-48010) niemand anders raken
4. **Nooit** nginx `/etc/nginx/sites-enabled/horsecloud` overschrijven — alleen append/modify met behoud van alle bestaande location blocks

## Feature & Bugfix Protocol (Color-Coded)

**Nieuwe Feature:**
- **Groen** — Sunshine-config-tweak, geen systemd-impact → +0.0.1
- **Oranje** — Nieuwe systemd-service, nginx-locatie, of upstream-component → +0.1.0
- **Rood** — Architectuur-wissel (bv. WebRTC ipv Sunshine, multi-user) → +1.0.0

**Bugfix:**
- **Groen** — Config-fout (verkeerd path in service-unit)
- **Geel** — Encoding/streaming-bug (latency-spike, audio-desync)
- **Rood** — HC55-collision (poort, service-naam, nginx-block kwijt)
- **Loop** — nieuwe stack-component proberen (Sunshine→WebRTC)

**RCA verplicht bij elke bugfix:** Functioneel / Technisch / Architectonisch. **Plus:** check tegen `Meta_Master/BUGS_GLOBAL.md` SHARED-INFRA-patronen vóór nieuwe fix.

## Deploy Protocol

Elke deploy raakt HC55 → potentieel kritiek voor andere projecten. Daarom:

1. WhatIf met expliciete impact-vraag: "welke andere services raakt dit?"
2. Akkoord
3. SSH naar HC55: `ssh -i ~/.ssh/hetzner root@horsecloud55.ddns.net`
4. Backup eventueel te wijzigen config-files vóór wijziging
5. Deploy
6. Health-check: `systemctl status steamdeckmsx-stream.service` (vanaf v0.0.3)
7. Self-healing check: alle nginx location blocks nog aanwezig? Alle andere services nog up?
8. Commit deploy-state in repo (`deploy/state.md`)

## Versioning Mandate

Bump VERSION (semver + codenaam) vóór elke deploy. CHANGELOG-entry verplicht.

## WhatIf Protocol

Verplicht. Bij deploy: extra zwaarwegend wegens shared infra.

## Niet-scope (huidige fase)

- Multi-user / authenticatie — v0.3.0+
- HW-encoding (NVENC/QSV) — HC55 heeft geen GPU
- ROM-cloud-backup tussen native en stream — v0.2.0+
- Stream naar non-Steam-Deck clients — werkt wsl. via Moonlight Android/iOS/Win maar niet getest/supported

## Sessie-MD's

`prompts/YYYY-MM-DD_<slug>.md` met frontmatter. Verplicht per Meta_Master protocol.
