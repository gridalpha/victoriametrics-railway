# VictoriaMetrics cluster on Railway

Deployment sources for a full [VictoriaMetrics](https://victoriametrics.com)
cluster on [Railway](https://railway.com): storage, ingestion and query tiers as
separate services, an authenticating gateway in front, self-monitoring, and
alerting.

Three services run the published images unchanged with a start command
(`vmstorage`, `vminsert`, `vmselect`). The four built from this repository each
need a configuration file that an environment variable cannot carry:

| Directory | Image | Why it is built here |
|---|---|---|
| `vmauth/` | `victoriametrics/vmauth:v1.151.0` | `auth.config` routing map; credentials and backends come from the environment via `%{ENV_VAR}` |
| `vmagent/` | `victoriametrics/vmagent:v1.151.0` | Prometheus scrape config covering every component of the cluster |
| `vmalert/` | `victoriametrics/vmalert:v1.151.0` | upstream's alerting rules for this stack, pinned to the same tag as the binary |
| `alertmanager/` | `prom/alertmanager:v0.28.1` | routes to a webhook when `ALERT_WEBHOOK_URL` is set, otherwise groups alerts and delivers nothing |

Each Railway service selects its build with `RAILWAY_DOCKERFILE_PATH`
(e.g. `vmauth/Dockerfile`); the build context is the repository root, so every
`COPY` is written relative to it.

Cross-service hostnames arrive as `${{service.RAILWAY_PRIVATE_DOMAIN}}`
references, which render empty until that service owns a deployment. Every
entrypoint therefore repairs its hosts on their shape before using them.

No secrets are stored in this repository.
