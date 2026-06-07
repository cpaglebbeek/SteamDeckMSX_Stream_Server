---
date: 2026-05-31
repo: SteamDeckMSX_Stream_Server
status: done
resume: ""
---

> **Opvolging 2026-06-07 (sessie-bundel SteamDeck MSX):** v0.0.2-Parodius
> heeft Sunshine config-artefacten (`sunshine.conf.template`, `apps.json`,
> `xvfb-wrapper.sh`), systemd unit, en uitgebreide `SHARED_INFRA_PATCH.md`
> in de repo gezet — maar **geen HC55-deploy** (vereist apart WhatIf-akkoord
> per Deploy Protocol). Deploy verschoven naar v0.0.3 — zie
> `2026-06-07_v0.0.2_sunshine_config_artefacten.md` (status: done) en
> `2026-06-07_v0.0.3_hc55_deploy_open.md` (status: open).

# Sessie 2026-05-31 — newp SteamDeckMSX_Stream_Server (variant 2 server)

**Agent:** Claude Opus 4.7 (1M context)
**Repo:** SteamDeckMSX_Stream_Server (`cpaglebbeek/SteamDeckMSX_Stream_Server`)
**Branche:** main
**Cross-repo werk:** Meta_SteamDeckMSX, zusterrepos Native / Stream_Client, Meta_Master (SHARED_INFRASTRUCTURE)
**Eindstand commits:** (initial commit, hash volgt)

---

## Opdracht (samengevat)

Onderdeel van newp — deze repo is variant 2 server-side (Sunshine + openMSX-headless op HorseCloud55). Skeleton zonder deploy. Poort 47984-48010 gereserveerd in SHARED_INFRA_PATCH.md (mergen bij eerste deploy v0.0.2+).

---

## Prompts en acties — chronologisch

Zie `Meta_SteamDeckMSX/prompts/2026-05-31_newp_skeleton.md` voor volledige conversatie.

### Actie — skeleton voor Stream_Server variant
README (poort-tabel + plan v0.0.1→v0.3.0), CLAUDE.md (SHARED-INFRA verplichting, deploy-protocol, kleurcodes), .gitignore (secrets, state, ROM/BIOS-uitsluiting), VERSION (`0.0.1-Knightmare`), ARCHITECTURE.md (HC55-componentdiagram, latency-budget, encoding, resource-impact, 4 open architectuurvragen), SHARED_INFRA_PATCH.md (merge-snippet voor Meta_Master), BUGLIST.md, CHANGELOG.md, `deploy/README.md` (stap-voor-stap install).

---

## Belangrijke keuzes deze sessie

| Keuze | Reden |
|---|---|
| Codenaam v0.0.1 = Knightmare | Konami MSX-klassieker, Server-rol symboliek |
| Sunshine als streaming-host | Bewezen low-latency gaming-stream stack |
| Software x264 (geen GPU) | HC55 CPU-only, ~1.5-2 cores piek acceptabel |
| Poorten 47984-48010 geclaimd | Conflict-vrij met bestaande HC55-services |
| Single-user v0.1.x, multi-user v0.3.0+ | Scope-creep voorkomen |
| Geen Sunshine-source in repo | Upstream consumeren via .deb |
| AGPL belangrijk hier | Publieke streaming-instance = SaaS, source-availability afdwingbaar |

---

## Open eindjes na deze sessie

**Wacht op v0.0.2-deploy:**
- Sunshine .deb installeren op HC55
- SHARED_INFRA_PATCH mergen in `Meta_Master/SHARED_INFRASTRUCTURE.md`
- `sunshine.conf.template` + `apps.json` schrijven
- WhatIf + akkoord vóór elke HC55-deploy

**Wacht op v0.0.3:**
- openMSX-headless: bestaat dit out-of-box? Onderzoek nodig naar SDL-display-loop-vervanging
- systemd unit-file `steamdeckmsx-sunshine.service` met CPUQuota=200%

**Open architectuurvragen v0.0.2-onderzoek:**
1. openMSX-headless beschikbaar?
2. Sunshine `apps.json` voor MSX
3. PipeWire-headless op HC55
4. TLS-cert (self-signed vs Let's Encrypt) voor Sunshine pairing

**Onafhankelijk:**
- Hetzner firewall + ufw regels (47984-48010) — pas bij eerste deploy
