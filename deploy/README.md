# Deploy-procedure — SteamDeckMSX_Stream_Server

> v0.0.1: nog geen deploy. Dit document beschrijft de **voorgestelde** procedure voor v0.0.2+.

## Pre-condities

- HC55 SSH-toegang via `ssh -i ~/.ssh/hetzner root@horsecloud55.ddns.net`
- `Meta_Master/SHARED_INFRASTRUCTURE.md` gelezen (poort 47984-48010 conflict-vrij)
- `Meta_Master/SHARED_INFRA_PATCH.md` (zie repo-root) gemerged in shared-infra-tabel

## Stap 1 — Sunshine installeren (v0.0.2)

```bash
# Op HC55:
wget https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-24.04-amd64.deb
apt install ./sunshine-ubuntu-24.04-amd64.deb
```

## Stap 2 — openMSX-headless bouwen (v0.0.3)

```bash
git clone --recursive https://github.com/cpaglebbeek/SteamDeckMSX_Stream_Server /opt/steamdeckmsx/repo
cd /opt/steamdeckmsx/repo/externals/openmsx
./configure --enable-headless --prefix=/opt/steamdeckmsx
make -j$(nproc) install
```

## Stap 3 — systemd service (v0.0.3)

```bash
cp deploy/systemd/steamdeckmsx-sunshine.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now steamdeckmsx-sunshine.service
systemctl status steamdeckmsx-sunshine.service
```

## Stap 4 — Sunshine config (v0.0.2)

```bash
cp deploy/sunshine/apps.json /etc/sunshine/apps.json
cp deploy/sunshine/sunshine.conf.template /etc/sunshine/sunshine.conf
# Stel admin-credentials in via Sunshine web UI :47990
```

## Stap 5 — Pairing met Steam Deck

1. Op Deck: open Moonlight (Flatpak via Discover)
2. Verbind met `horsecloud55.ddns.net`
3. Sunshine genereert PIN-code → vul in op `https://horsecloud55.ddns.net:47990`
4. Refresh Moonlight → "MSX-stream" zichtbaar als launchable app

## Stap 6 — Health-check

```bash
systemctl status steamdeckmsx-sunshine.service
ss -tlnp | grep -E '47984|47989|47990|47999|48010'
ss -ulnp | grep -E '47998|47999|48000|48001'
# Verifieer dat ALLE bestaande HC55-services nog up zijn:
systemctl status dashboard.service claudeweb.service cvportal.service \
                 horseaccounting.service macterminal.service priomail-trainer.service \
                 archisaas.service sms-relay.service claudebug.service horsesafe.service
```

## Roll-back

```bash
systemctl stop steamdeckmsx-sunshine.service
systemctl disable steamdeckmsx-sunshine.service
# Sunshine .deb laten staan, alleen service uit
```
