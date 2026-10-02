#!/usr/bin/env bash
# SERVER-VM only. Run as your course administrator via sudo bash.
set -euo pipefail
[[ $EUID -eq 0 && -f /etc/azure-linux-course ]] || { echo 'Nur als root auf Kurs-VM ausführen' >&2; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if ! id courseweb >/dev/null 2>&1; then useradd --system --home /opt/course-web --shell /usr/sbin/nologin courseweb; fi
install -d -o courseweb -g courseweb /opt/course-web
install -m 644 "$ROOT/examples/web.py" /opt/course-web/web.py
install -m 644 "$ROOT/examples/course-web.service" /etc/systemd/system/course-web.service
systemctl daemon-reload
systemctl enable --now course-web
systemctl status course-web --no-pager
