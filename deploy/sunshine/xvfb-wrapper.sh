#!/usr/bin/env bash
# xvfb-wrapper.sh — start/stop Xvfb display voor openMSX-headless onder Sunshine.
# Doel-locatie HC55: /opt/steamdeckmsx/bin/xvfb-wrapper.sh (chmod 755)
# Aangeroepen vanuit apps.json prep-cmd.
#
# Gebruik:
#   xvfb-wrapper.sh start :0 1280x800x24
#   xvfb-wrapper.sh stop  :0
#
# Idempotent: start herinitialiseert niet als display al draait.

set -euo pipefail

action="${1:?usage: $0 start|stop <display> [WxHxD]}"
display="${2:?display nummer ontbreekt, bv. :0}"
geom="${3:-1280x800x24}"

pidfile="/run/sunshine/xvfb${display}.pid"
mkdir -p "$(dirname "${pidfile}")"

case "${action}" in
  start)
    if [[ -f "${pidfile}" ]] && kill -0 "$(cat "${pidfile}")" 2>/dev/null; then
      echo "Xvfb ${display} draait al (pid $(cat "${pidfile}"))"
      exit 0
    fi
    # Xvfb-args:
    # -screen 0 WxHxD : virtual display geometrie
    # -nolisten tcp  : geen TCP-luisteraar (alleen UNIX-socket)
    # -dpi 96        : standaard ppi
    Xvfb "${display}" -screen 0 "${geom}" -nolisten tcp -dpi 96 &
    echo $! > "${pidfile}"
    # Wacht max 5 s op socket-beschikbaarheid.
    for _ in {1..50}; do
      if [[ -S "/tmp/.X11-unix/X${display#:}" ]]; then
        exit 0
      fi
      sleep 0.1
    done
    echo "Xvfb ${display} start timeout" >&2
    exit 1
    ;;
  stop)
    if [[ ! -f "${pidfile}" ]]; then
      echo "Geen pidfile voor Xvfb ${display}"
      exit 0
    fi
    pid="$(cat "${pidfile}")"
    if kill -0 "${pid}" 2>/dev/null; then
      kill -TERM "${pid}"
      # Wacht max 3 s op shutdown.
      for _ in {1..30}; do
        if ! kill -0 "${pid}" 2>/dev/null; then
          break
        fi
        sleep 0.1
      done
      kill -KILL "${pid}" 2>/dev/null || true
    fi
    rm -f "${pidfile}"
    ;;
  *)
    echo "usage: $0 start|stop <display> [WxHxD]" >&2
    exit 2
    ;;
esac
