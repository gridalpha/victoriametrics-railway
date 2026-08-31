FROM victoriametrics/vmalert:v1.151.0

# Upstream's own alerting rules for this stack, taken at the same tag as the
# binary so a rule can never reference a metric this build does not emit.
ARG VM_VERSION=v1.151.0
ARG RULES=https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/${VM_VERSION}/deployment/docker/rules
ADD ${RULES}/alerts-health.yml   /etc/alerts/alerts-health.yml
ADD ${RULES}/alerts-cluster.yml  /etc/alerts/alerts-cluster.yml
ADD ${RULES}/alerts-vmagent.yml  /etc/alerts/alerts-vmagent.yml
ADD ${RULES}/alerts-vmalert.yml  /etc/alerts/alerts-vmalert.yml
ADD ${RULES}/alerts-vmauth.yml   /etc/alerts/alerts-vmauth.yml
RUN chmod 0644 /etc/alerts/*.yml

COPY vmalert/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh && sh -n /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
