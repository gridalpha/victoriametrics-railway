#!/bin/sh
# vmauth: public gateway for the VictoriaMetrics cluster.
set -eu

: "${PORT:=8427}"
: "${VM_USERNAME:=admin}"

if [ -z "${VM_PASSWORD:-}" ]; then
  echo "vmauth: VM_PASSWORD is empty - refusing to start an unauthenticated gateway" >&2
  exit 1
fi

# A ${{service.RAILWAY_PRIVATE_DOMAIN}} reference renders empty until that service
# owns a deployment, so repair each host on its shape rather than trusting it.
case "${VMSELECT_HOST:-}" in "" | :*) VMSELECT_HOST=vmselect.railway.internal ;; esac
case "${VMINSERT_HOST:-}" in "" | :*) VMINSERT_HOST=vminsert.railway.internal ;; esac
export VM_USERNAME VM_PASSWORD VMSELECT_HOST VMINSERT_HOST

# /metrics, /flags, /debug/pprof and /-/reload are served by vmauth's own HTTP
# server, outside the auth.config routes, so they need their own keys on a
# public listener. /health stays open for the Railway health check.
AUTHKEY="${VM_INTERNAL_AUTH_KEY:-$VM_PASSWORD}"

exec /vmauth-prod \
  -enableTCP6 \
  -auth.config=/etc/vmauth/auth.yml \
  -httpListenAddr=":$PORT" \
  -metricsAuthKey="$AUTHKEY" \
  -flagsAuthKey="$AUTHKEY" \
  -pprofAuthKey="$AUTHKEY" \
  -reloadAuthKey="$AUTHKEY" \
  "$@"
