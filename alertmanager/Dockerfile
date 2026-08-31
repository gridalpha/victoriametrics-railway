FROM prom/alertmanager:v0.28.1

# The stock image runs as nobody, which cannot write to a Railway volume mounted
# root-owned at /alertmanager.
USER root

COPY alertmanager/alertmanager.yml /etc/alertmanager/alertmanager.base.yml
COPY alertmanager/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh && sh -n /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
