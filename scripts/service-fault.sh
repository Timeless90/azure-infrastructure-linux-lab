#!/usr/bin/env bash
# SERVER-VM only. Preserve SSH and never change its configuration.
set -euo pipefail
[[ $EUID -eq 0 && -f /etc/azure-linux-course ]] || { echo 'Nur root auf Kurs-VM' >&2; exit 1; }
FAULT=${1:-}; ACTION=${2:-}
if ! { [[ "$FAULT" == stopped || "$FAULT" == loopback || "$FAULT" == unit ]] && [[ "$ACTION" == break || "$ACTION" == restore ]]; }; then
 echo 'Aufruf: sudo bash scripts/service-fault.sh stopped|loopback|unit break|restore' >&2; exit 1;
fi
DIR=/etc/systemd/system/course-web.service.d
install -d "$DIR"
if [[ "$ACTION" == restore ]]; then
  rm -f "$DIR/course-fault.conf"
  systemctl daemon-reload; systemctl reset-failed course-web; systemctl start course-web
  systemctl restart course-web
elif [[ "$FAULT" == stopped ]]; then
  systemctl stop course-web
elif [[ "$FAULT" == loopback ]]; then
  printf '[Service]\nExecStart=\nExecStart=/usr/bin/python3 /opt/course-web/web.py --host 127.0.0.1 --port 8080\n' > "$DIR/course-fault.conf"
  systemctl daemon-reload; systemctl restart course-web
else
  printf '[Service]\nExecStart=\nExecStart=/opt/course-web/missing-python /opt/course-web/web.py\n' > "$DIR/course-fault.conf"
  systemctl daemon-reload
  systemctl restart course-web || echo 'Startfehler ist hier das erwartete Lab-Symptom'
fi
