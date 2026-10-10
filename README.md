# SteamDeckMSX_Stream_Server

**Variant 2 — server-side** van het [SteamDeckMSX](https://github.com/cpaglebbeek/Meta_SteamDeckMSX) ecosysteem. Draait op **HorseCloud55** (Hetzner): openMSX-headless + Sunshine streaming-host. Een Steam Deck (of andere Moonlight-client) verbindt en speelt MSX-games via low-latency video-stream.

Companion-client: [SteamDeckMSX_Stream_Client](https://github.com/cpaglebbeek/SteamDeckMSX_Stream_Client).

## Status

- **Versie:** v0.0.1-Knightmare (skeleton)
- **Doel-host:** `icthorsecloud.nl` (Ubuntu 24.04, 16GB RAM, CPU-only)
- **Geen GPU** → software-encoding via libx264, ~1-2 cores piek

## Architectuur (kort)

```
Internet ─► HC55:47984-48010 ─► Sunshine ─► openMSX-headless ─► framebuffer + audio
                                    │            │
                                    │            └─► /opt/steamdeckmsx/bios (C-BIOS)
                                    │            └─► /opt/steamdeckmsx/roms
                                    └─► x264 encode → UDP stream → Deck
```

Volledige architectuur: zie [Meta_SteamDeckMSX/ARCHITECTURE.md](https://github.com/cpaglebbeek/Meta_SteamDeckMSX/blob/main/ARCHITECTURE.md).

## HC55-poorten (gereserveerd)

| Poort | Protocol | Doel |
|-------|----------|------|
| 47984 | TCP | Sunshine HTTPS pairing |
| 47989 | TCP | Sunshine HTTP web (optioneel) |
| 47990 | TCP | Sunshine HTTPS web UI |
| 47999 | TCP | Control |
| 48010 | TCP | RTSP setup |
| 47998-48000 | UDP | Video |
| 48001 | UDP | Audio |

Conflict-vrij met bestaande HC55-services (zie `Meta_Master/SHARED_INFRASTRUCTURE.md`).

## Plan

1. **v0.0.1** — Skeleton (deze release)
2. **v0.0.2** — `deploy/` Ansible-stub + handmatige install-procedure (Sunshine .deb + openMSX-headless apt)
3. **v0.0.3** — systemd service-files + auto-start bij sessie-claim
4. **v0.1.0** — Eerste live-stream Bubble Bobble naar Deck via LAN
5. **v0.2.0** — Web-admin-UI (ROM-upload, Sunshine-config) achter `admin.icthorse.nl`-style subdomain
6. **v0.3.0** — Multi-user (instance-per-user) — uit huidige scope

## Niet inbegrepen

- Sunshine-binary in de repo (komt van upstream of distro)
- MSX BIOS — server-admin uploadt zelf naar `/opt/steamdeckmsx/bios/` (P-SDM-05)

## Licentie

AGPL-3.0 — zie [LICENSE](LICENSE). Belangrijk bij publieke streaming-dienst: AGPL vereist dat gebruikers van de hosted instance de bron kunnen opvragen.
