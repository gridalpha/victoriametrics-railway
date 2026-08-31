FROM victoriametrics/vmagent:v1.151.0

COPY vmagent/scrape.yml /etc/vmagent/scrape.yml
COPY vmagent/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh && sh -n /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
