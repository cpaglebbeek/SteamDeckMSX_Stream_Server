# WebClient — /steam/konami op HC55

Browser-speelbare Konami-pagina (tussenstap: geen Deck-pairing of Moonlight nodig; werkt in elke browser incl. Steam Deck Gaming Mode-browser, mét Gamepad API).

| Onderdeel | Locatie HC55 |
|---|---|
| WebMSX 6.0.8 **C-BIOS-build** | `/srv/steamweb/wmsx/wmsx.js` (P-SDM-05: geen MS-BIOS) |
| Pagina's + ROMs (eigen dumps) | `/srv/steamweb/konami/` |
| nginx-snippet | `/etc/nginx/snippets/steamdeckmsx-web.conf` (include in sites-enabled/horsecloud :443) |

- URL: `https://horsecloud55.ddns.net/steam/konami/` (`/steam/` → 302 daarheen)
- **Publiek open** per user-besluit 2026-07-22 (`auth_basic off` — server-block heeft site-brede basic-auth). Harm-reduction: `X-Robots-Tag: noindex`, meta-noindex, robots.txt, autoindex off.
- WMSX-config MOET ná de `wmsx.js`-include (BUG-005): wmsx.js definieert `WMSX` onvoorwaardelijk; start gebeurt pas op window.onload.
- Emulatie draait client-side → HC55-belasting = alleen statische files; werkt door zolang nginx up is, ook als de Sunshine-service down is.
