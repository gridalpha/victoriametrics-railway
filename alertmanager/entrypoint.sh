#!/bin/sh
# Alertmanager: renders its config from the environment, then runs.
set -eu

: "${PORT:=9093}"
CFG=/etc/alertmanager/alertmanager.yml

if [ -n "${ALERT_WEBHOOK_URL:-}" ]; then
  cat > "$CFG" <<EOF
route:
  receiver: webhook
  group_by: ["alertname", "job"]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h

receivers:
  - name: webhook
    webhook_configs:
      - url: "$ALERT_WEBHOOK_URL"
        send_resolved: true
EOF
  echo "alertmanager: delivering notifications to the configured webhook"
else
  cp /etc/alertmanager/alertmanager.base.yml "$CFG"
  echo "alertmanager: ALERT_WEBHOOK_URL is unset - alerts are grouped but not delivered"
fi

exec /bin/alertmanager \
  --config.file="$CFG" \
  --storage.path=/alertmanager \
  --web.listen-address=":$PORT" \
  "$@"
