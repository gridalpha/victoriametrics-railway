#!/bin/sh
# vmalert: evaluates the bundled alerting rules against vmselect and sends
# firing alerts to Alertmanager.
set -eu

: "${PORT:=8880}"
: "${VMALERT_EVALUATION_INTERVAL:=30s}"

# A ${{service.RAILWAY_PRIVATE_DOMAIN}} reference renders empty until that service
# owns a deployment, so repair each host on its shape rather than trusting it.
case "${VMSELECT_HOST:-}" in "" | :*) VMSELECT_HOST=vmselect.railway.internal ;; esac
case "${VMINSERT_HOST:-}" in "" | :*) VMINSERT_HOST=vminsert.railway.internal ;; esac
case "${ALERTMANAGER_HOST:-}" in "" | :*) ALERTMANAGER_HOST=alertmanager.railway.internal ;; esac

set -- \
  -rule="/etc/alerts/*.yml" \
  -datasource.url="http://$VMSELECT_HOST:8481/select/0/prometheus" \
  -remoteRead.url="http://$VMSELECT_HOST:8481/select/0/prometheus" \
  -remoteWrite.url="http://$VMINSERT_HOST:8480/insert/0/prometheus" \
  -notifier.url="http://$ALERTMANAGER_HOST:9093" \
  -evaluationInterval="$VMALERT_EVALUATION_INTERVAL" \
  -httpListenAddr=":$PORT" \
  "$@"

# The public URL of the deployment, used in alert annotations. Empty on a
# project whose gateway has no domain yet.
if [ -n "${EXTERNAL_URL:-}" ]; then
  set -- "$@" -external.url="$EXTERNAL_URL"
fi

exec /vmalert-prod "$@"
