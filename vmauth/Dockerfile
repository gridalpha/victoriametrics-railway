FROM victoriametrics/vmauth:v1.151.0

COPY vmauth/auth.yml /etc/vmauth/auth.yml
COPY vmauth/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh && sh -n /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
