# BUGLIST — SteamDeckMSX_Stream_Server

> Per `Meta_Master/templates/BUGLIST_TEMPLATE.md`. Kleurcodes: Groen / Geel / Rood / Loop.

## Open

_(nog geen — v0.0.1 is alleen skeleton)_

## Opgelost

_(leeg)_

## Terugkerende patronen

_(in te vullen vanaf v0.0.3 zodra service draait)_

## Cross-repo bug-referenties

Belangrijk voor deze repo: alle **SHARED_INFRA-patronen** in `Meta_Master/BUGS_GLOBAL.md`. Streaming-server raakt HC55 = potentiële impact op alle andere HC55-projecten.

Specifieke patronen om op te letten:
- **DEPLOY/nginx** — `/etc/nginx/sites-enabled/horsecloud` nooit overschrijven (R1 in SHARED_INFRASTRUCTURE.md)
- **CACHE/Sunshine pairing-state** — kan na restart corrupt zijn → /etc/sunshine/credentials/ verifiëren
- **FEATURE/x264 CPU-spike** — bij langdurige sessies CPU-quota afdwingen
