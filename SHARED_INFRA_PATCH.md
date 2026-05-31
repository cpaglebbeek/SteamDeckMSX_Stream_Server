# SHARED_INFRA_PATCH — voor merge in `Meta_Master/SHARED_INFRASTRUCTURE.md`

> Snippet die toegevoegd moet worden aan de hoofd-shared-infra-tabel bij eerste deploy van Stream_Server (v0.0.2+). NU al gedocumenteerd om poort-reservering vast te leggen.

## Toe te voegen rij in de Projecten-tabel

```markdown
| **SteamDeckMSX Stream Server** | **47984/47989/47990/47999/48010 TCP + 47998-48000/48001 UDP** | (geen nginx, directe Sunshine) | `steamdeckmsx-sunshine.service` (v0.0.3+) | `/opt/steamdeckmsx/` | cpaglebbeek/SteamDeckMSX_Stream_Server |
```

## Toe te voegen aan R2 "Gereserveerde poorten"

Aan de bestaande regel toevoegen:
```
… 47984, 47989, 47990, 47998 (UDP), 47999 (TCP+UDP), 48000 (UDP), 48001 (UDP), 48010 (TCP)
```

## Toe te voegen aan oorzaak/gevolg-matrix

```markdown
| SteamDeckMSX-stream actief tijdens HC55 piek-CPU | Stream-latency spikes; andere services kunnen vertragen | `systemd CPUQuota=200%` op stream-service; stream alleen actief tijdens user-claim |
```

## Reservering vastgelegd op

2026-05-31 (v0.0.1-Knightmare skeleton, vóór eerste deploy)

## Status

- **Geclaimd:** ja (in deze patch-file)
- **Actief deployed:** nog niet (v0.0.3+)
- **Bevestiging in Meta_Master:** TODO bij eerste deploy
