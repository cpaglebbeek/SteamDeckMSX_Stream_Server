# SHARED_INFRA_PATCH — voor merge in `Meta_Master/SHARED_INFRASTRUCTURE.md`

> Snippet die toegevoegd moet worden aan de hoofd-shared-infra-tabel bij eerste deploy van Stream_Server (v0.0.3+, want v0.0.2 levert nog geen werkende deploy — alleen config-artefacten in repo).
> Update v0.0.2-Parodius: poort-tabel uitgebreid + systemd unit-naam definitief + oorzaak/gevolg-rij verfijnd met meet-toelichting.

## Status

- **Geclaimd in deze patch:** ja
- **Actief deployed op HC55:** **JA** — v0.1.0-Gradius, 2026-07-22 (zie deploy/state.md)
- **Bevestiging in Meta_Master/SHARED_INFRASTRUCTURE.md:** GEMERGED 2026-07-22
- **Versie van deze patch:** v0.0.2-Parodius (2026-06-07)

## Toe te voegen rij in de Projecten-tabel

```markdown
| **SteamDeckMSX Stream Server** | TCP 47984 (HTTPS), 47989 (HTTP web-pin), 47990 (web-UI HTTPS), 48010 (RTSP control); UDP 47998, 47999, 48000, 48001, 48002 (video+audio+control+mic) | (geen nginx; Sunshine self-signed TLS direct) | `steamdeckmsx-sunshine.service` (v0.0.3+) | `/opt/steamdeckmsx/{bin,share,etc}` + `/etc/sunshine/` + `/var/lib/sunshine/` + `/var/lib/steamdeckmsx/roms/` + `/var/log/sunshine/` | `cpaglebbeek/SteamDeckMSX_Stream_Server` |
```

## Toe te voegen aan R2 "Gereserveerde poorten"

Aan de bestaande lijst toevoegen (gegroepeerd voor leesbaarheid):

```
Sunshine TCP : 47984, 47989, 47990, 48010
Sunshine UDP : 47998, 47999, 48000, 48001, 48002
```

## Conflict-check vs. bekende HC55-services (per 2026-06-07)

| Bestaande service | Poort(en) | Conflict met Sunshine-range? |
|---|---|---|
| Dashboard | 3980 | nee |
| ClaudeWeb | 3000 | nee |
| CarriereCV | 3950 | nee |
| MacTerminal | 3970 | nee |
| PrioMail-trainer | 3985 | nee |
| RandomRingtone Logger | 3800 | nee |
| ArchiSaas | 3957 | nee |
| HorseSafe | 3962 | nee |
| Facturatie | 3964 | nee |
| ClaudeBug | 3996 | nee |
| HorseAPK | 4443 | nee |
| FODMAP | 3966 | nee |
| LLMShapes | 3965 | nee |
| PortalToExact | 3964 | nee |

Conclusie: alle Sunshine-poorten 47984-48010 zijn conflict-vrij. Geen overlap.

## Toe te voegen aan oorzaak/gevolg-matrix

```markdown
| SteamDeckMSX-stream actief tijdens HC55 piek-CPU | Stream-latency spikes; andere services kunnen 5-15% trager worden door CPU-contention | `systemd CPUQuota=200%` + `Nice=5` op `steamdeckmsx-sunshine.service` (cap = 2 van 4 cores); stream alleen actief tijdens user-claim (Moonlight pair-sessie); Sunshine zelf gaat slapen bij geen client |
| Xvfb-display crash | openMSX-headless valt om → Sunshine stuurt zwart beeld | `apps.json` `prep-cmd undo` ruimt Xvfb op; systemd `Restart=on-failure` start service binnen 5s opnieuw (max 5 restarts in 60s) |
| Sunshine self-signed cert wantrouwen Moonlight | Pairing weigert | Documenteer in `Stream_Client/scripts/pair.sh`: gebruiker accepteert cert eenmalig na visuele fingerprint-check |
```

## Nginx-impact

**Geen.** Sunshine luistert direct met self-signed TLS op poort 47984/47990. Geen reverse-proxy via `/etc/nginx/sites-enabled/horsecloud`. Alle bestaande nginx-location-blocks blijven onaangeroerd.

**Toekomstige overweging (v0.1.0):** als publiek bereik gewenst is met Let's Encrypt, dán komt er een nginx-stream-block bij. Per `CLAUDE.md` § Deploy Protocol: eerst WhatIf, dán pas.

## Firewall (ufw / Hetzner Cloud Firewall)

Bij eerste deploy v0.0.3 ook openzetten:
```bash
ufw allow 47984/tcp comment 'SteamDeckMSX Sunshine HTTPS'
ufw allow 47989/tcp comment 'SteamDeckMSX Sunshine HTTP-PIN'
ufw allow 47990/tcp comment 'SteamDeckMSX Sunshine web-UI'
ufw allow 48010/tcp comment 'SteamDeckMSX Sunshine RTSP control'
ufw allow 47998:48002/udp comment 'SteamDeckMSX Sunshine RTP video/audio/control/mic'
```

Hetzner Cloud Firewall (web-UI):
- Inkomend toestaan: `0.0.0.0/0 → 47984,47989,47990,48010/tcp` + `47998-48002/udp`
- Bron-restrictie overwegen: alleen home-IP whitelisten als de stream-instance privé blijft. Beslissing bij v0.0.3 deploy.

## Reservering vastgelegd op

- v0.0.1-Knightmare skeleton: 2026-05-31 (initieel — globale range 47984-48010 claimde)
- v0.0.2-Parodius update: 2026-06-07 (poort-tabel verfijnd + conflict-check uitgevoerd + 48002/udp toegevoegd voor mic-channel)
