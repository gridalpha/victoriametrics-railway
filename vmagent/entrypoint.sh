#!/bin/sh
# vmagent: scrapes the cluster's own metrics and remote-writes them to vminsert.
set -eu

: "${PORT:=8429}"

# A ${{service.RAILWAY_PRIVATE_DOMAIN}} reference renders empty until that service
# owns a deployment, so repair each host on its shape rather than trusting it.
case "${VMSTORAGE_HOST:-}" in "" | :*) VMSTORAGE_HOST=vmstorage.railway.internal ;; esac
case "${VMINSERT_HOST:-}" in "" | :*) VMINSERT_HOST=vminsert.railway.internal ;; esac
case "${VMSELECT_HOST:-}" in "" | :*) VMSELECT_HOST=vmselect.railway.internal ;; esac
case "${VMALERT_HOST:-}" in "" | :*) VMALERT_HOST=vmalert.railway.internal ;; esac
case "${VMAUTH_HOST:-}" in "" | :*) VMAUTH_HOST=vmauth.railway.internal ;; esac
case "${ALERTMANAGER_HOST:-}" in "" | :*) ALERTMANAGER_HOST=alertmanager.railway.internal ;; esac
: "${VMAUTH_METRICS_KEY:=}"
export VMSTORAGE_HOST VMINSERT_HOST VMSELECT_HOST VMALERT_HOST VMAUTH_HOST \
  ALERTMANAGER_HOST VMAUTH_METRICS_KEY

exec /vmagent-prod \
  -enableTCP6 \
  -promscrape.config=/etc/vmagent/scrape.yml \
  -remoteWrite.url="http://$VMINSERT_HOST:8480/insert/0/prometheus/api/v1/write" \
  -remoteWrite.tmpDataPath=/vmagentdata \
  -httpListenAddr=":$PORT" \
  "$@"
