# ARCHITECTURE — SteamDeckMSX_Stream_Server

> Variant 2 server-side. Zie [Meta_SteamDeckMSX/ARCHITECTURE.md](https://github.com/cpaglebbeek/Meta_SteamDeckMSX/blob/main/ARCHITECTURE.md) voor ecosysteem-overzicht.

## Componentdiagram (HC55)

```
HorseCloud55 (Ubuntu 24.04, 16GB RAM, CPU-only)
│
├─ /opt/steamdeckmsx/
│   ├─ bin/openmsx-headless      ← gebuild uit externals/openmsx (v0.0.3+)
│   ├─ bios/                     ← C-BIOS + (admin-supplied) user BIOS
│   ├─ roms/                     ← .rom/.dsk catalog
│   ├─ states/                   ← save-states
│   ├─ sunshine/
│   │   ├─ sunshine.conf
│   │   ├─ apps.json             ← één app: "MSX-stream"
│   │   └─ credentials/          ← paired Moonlight clients (mode 600)
│   └─ logs/
│
├─ systemd:
│   ├─ steamdeckmsx-sunshine.service  ← Sunshine daemon
│   └─ (geen losse openMSX-service — Sunshine start hem on-demand)
│
└─ Netwerk:
    ├─ TCP 47984  (HTTPS pairing)
    ├─ TCP 47989  (HTTP web, optioneel)
    ├─ TCP 47990  (HTTPS web UI)
    ├─ TCP 47999  (control)
    ├─ TCP 48010  (RTSP)
    ├─ UDP 47998-48000 (video)
    └─ UDP 48001  (audio)
```

## Stream-flow

```
Client (Deck Moonlight)               HC55 (Sunshine + openMSX)
─────────────────────                ─────────────────────────
1. Pair (PIN code)        ─────►     accept → store pubkey
2. Launch "MSX-stream"    ─────►     systemd: start openMSX-headless
3. RTSP describe          ─────►     reply: video/audio formats
4. UDP stream             ◄─────     x264-encoded 720p60 + opus audio
   gamepad input          ─────►     → openMSX joystick API
5. Disconnect             ─────►     systemd: stop openMSX-headless
```

**Latency-budget LAN:** ~50-60 ms totaal (RTT 15-25 + encode 10 + decode 10 + display 5-10).

**Latency-budget WAN:** ~80-150 ms — speelbaar voor MSX-RPG/puzzle, krap voor twitch-arcade.

## Encoding-keuze

Geen GPU op HC55 → **software-x264**:
- Preset: `superfast` (latency-prioriteit boven bitrate-efficiency)
- Tuning: `zerolatency`
- Bitrate: 15 Mbps target @ 720p60 (overkill voor MSX 256×192 native res, maar Sunshine upscaled naar Deck-native)
- CPU-belasting: ~1.5 cores piek

**Alternatief (later):** software-x265 voor lagere bandbreedte (~5 Mbps) maar +30% CPU. Niet de moeite tenzij WAN-streaming hoofd-use-case wordt.

## Resource-impact op HC55

Andere services op HC55 (zie `SHARED_INFRASTRUCTURE.md`):
- Dashboard, ClaudeWeb, CarriereCV, HorseAccounting, MacTerminal, PrioMail, ArchiSaas, AModeler, SMSRelay, ClaudeBug, HorseSafe, iCtHorseAssist, iCtHorseAdmin, …

**Risico:** Tijdens stream-sessie consumeert Sunshine+x264 ~2 cores. Als HC55 piek-CPU heeft op andere services, kan stream-latency spikes hebben.

**Mitigatie:**
- `systemd CPUQuota=200%` op `steamdeckmsx-sunshine.service`
- `nice -n -10` (hogere prio dan defaults; lager dan critical services)
- Stream-sessie alleen actief tijdens user-launch — niet 24/7

## Beveiliging

- Sunshine pairing via PIN — eenmalig per client
- Sunshine web UI (47990) achter eigen Sunshine-login (admin-credentials in `sunshine.conf`)
- Geen publieke web-UI in v0.0.1 — admin SSH-only
- Firewall (Hetzner cloud-firewall + ufw): open alleen Sunshine-poorten + bestaande
- **Open issue v0.0.2:** moet Sunshine-poorten beperken tot whitelist-IPs? Of accepteren we publieke pairing-flow met PIN-protection?

## Directory-layout (deze repo)

```
SteamDeckMSX_Stream_Server/
├─ README.md
├─ LICENSE                   ← AGPL-3.0
├─ CLAUDE.md
├─ VERSION                   ← 0.0.1-Knightmare
├─ ARCHITECTURE.md           ← dit bestand
├─ BUGLIST.md
├─ CHANGELOG.md
├─ .gitignore
│
├─ deploy/                   ← install-scripts, systemd-units, sunshine.conf-template
│   ├─ README.md             ← stap-voor-stap deploy-procedure
│   ├─ systemd/              ← (v0.0.3+)
│   ├─ sunshine/             ← apps.json template
│   └─ nginx/                ← (v0.2.0+ web-admin)
│
├─ externals/                ← v0.0.3+ git submodule openmsx
│
├─ docs/
│   └─ deployment.md         ← v0.0.2
│
├─ prompts/                  ← sessie-MD's
│
└─ SHARED_INFRA_PATCH.md     ← snippet om in Meta_Master/SHARED_INFRASTRUCTURE.md te mergen
```

## Relatie met andere repos

| Repo | Type relatie |
|------|--------------|
| Meta_SteamDeckMSX | Pull docs/principes |
| SteamDeckMSX_Native | Save-state-formaat-compat (P-SDM-04) |
| SteamDeckMSX_Stream_Client | Pairing-protocol-paar; codenaam-paar |
| CloudInfra | Updates aan SHARED_INFRASTRUCTURE.md |

## Open architectuurvragen (v0.0.2-onderwerpen)

1. **openMSX-headless bestaat?** openMSX heeft een control-mode (commando-channel) maar geen pure headless-build out-of-box. Mogelijk patch nodig om SDL-display-loop te vervangen door framebuffer-naar-Sunshine-pipe.
2. **Sunshine app-config** — `apps.json` ondersteunt subprocess-launching. Werkt voor openMSX, maar virtual-display-config moet kloppen (X-virtual-FB of Wayland-headless).
3. **Audio-routing** — openMSX → PulseAudio/PipeWire → Sunshine. Op headless HC55 mogelijk extra config nodig (`pipewire --headless`).
4. **TLS voor pairing** — Sunshine genereert self-signed cert. Acceptabel voor MVP; later mogelijk Let's Encrypt.
