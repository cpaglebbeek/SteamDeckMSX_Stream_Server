# BUGLIST — SteamDeckMSX_Stream_Server

> Per `Meta_Master/templates/BUGLIST_TEMPLATE.md`. Kleurcodes: Groen / Geel / Rood / Loop.

## Open

_(nog geen — v0.0.1 is alleen skeleton)_

## Opgelost

### BUG-005 (geel) — WMSX-config vóór wmsx.js-include genegeerd — v0.2.0-Twinbee 2026-07-22
- **Functioneel:** webclient bootte C-BIOS met "No cartridge found" — ROM-autoload deed niets.
- **Technisch:** `wmsx.js` (6.0.8) definieert `WMSX = {…}` onvoorwaardelijk en overschrijft het page-object; hij start pas op window.onload. Fix: `WMSX.CARTRIDGE1_URL = …` in een script-tag NÁ de include.
- **Architectonisch:** upstream-component-contract niet geverifieerd vóór integratie; nu vastgelegd in deploy/webclient/README.md. Verificatie via Playwright-screenshot (Konami-logo) i.p.v. alleen HTTP 200.

### BUG-001 (geel) — Sunshine "Unable to find display or encoder" bij startup — v0.1.0-Gradius 2026-07-22
- **Functioneel:** service active maar main loop exit direct; geen enkele encoder gevonden → streamen onmogelijk.
- **Technisch:** Xvfb werd pas per-app gestart via apps.json prep-cmd, maar Sunshine test capture+encoder al bij service-start; zonder DISPLAY falen software/nvenc/vulkan/vaapi allemaal.
- **Architectonisch:** display-lifecycle lag bij de app-laag (apps.json) terwijl Sunshine hem op service-niveau vereist → verplaatst naar systemd ExecStartPre (xvfb-wrapper + pulseaudio), Environment DISPLAY=:0.

### BUG-002 (geel) — sunshine.conf inline-comments + quotes corrumperen waarden — v0.1.0-Gradius 2026-07-22
- **Functioneel:** software-encoder faalde en display-index was garbage (1478615952 / -1174871152).
- **Technisch:** Sunshine's conf-parser neemt de hele rest van de regel als waarde: `sw_preset = ultrafast ## TWEAK…`, `output_name = ":0"` en `audio_sink = "…"` waren allemaal corrupt. Fix: comments op eigen regel, quotes weg, `output_name = 0`, `audio_sink = auto_null.monitor`.
- **Architectonisch:** template was geschreven op leesbaarheid (inline TWEAK-markers) zonder parser-contract te verifiëren — regel toegevoegd in template-header: TWEAK altijd op eigen regel.

### BUG-003 (groen) — /run/sunshine ontbrak voor Xvfb-pidfiles — v0.1.0-Gradius 2026-07-22
- **Functioneel:** xvfb-wrapper.sh zou als msx-user falen op `mkdir /run/sunshine`.
- **Technisch:** unit had ReadWritePaths=/run/sunshine maar niets maakte de dir aan. Fix: `RuntimeDirectory=sunshine` + `RuntimeDirectoryPreserve=yes`.
- **Architectonisch:** systemd-idioom (RuntimeDirectory) i.p.v. impliciete mkdir in script.

### BUG-004 (groen) — ongeldige openMSX-flag `-display ::0` in apps.json — v0.1.0-Gradius 2026-07-22
- **Functioneel:** C-BIOS-shell-app zou niet launchen.
- **Technisch:** openMSX kent geen `-display`; display komt uit DISPLAY-env. Flag verwijderd; SDL_AUDIODRIVER=pulseaudio + PULSE_RUNTIME_PATH toegevoegd (geen /dev/snd op VPS, ALSA faalt).
- **Architectonisch:** app-cmd's minimaal houden; omgeving centraal in unit + apps.json env-blok.


## Terugkerende patronen

_(in te vullen vanaf v0.0.3 zodra service draait)_

## Cross-repo bug-referenties

Belangrijk voor deze repo: alle **SHARED_INFRA-patronen** in `Meta_Master/BUGS_GLOBAL.md`. Streaming-server raakt HC55 = potentiële impact op alle andere HC55-projecten.

Specifieke patronen om op te letten:
- **DEPLOY/nginx** — `/etc/nginx/sites-enabled/horsecloud` nooit overschrijven (R1 in SHARED_INFRASTRUCTURE.md)
- **CACHE/Sunshine pairing-state** — kan na restart corrupt zijn → /etc/sunshine/credentials/ verifiëren
- **FEATURE/x264 CPU-spike** — bij langdurige sessies CPU-quota afdwingen
