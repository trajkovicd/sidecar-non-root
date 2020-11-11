FROM debian:stable-slim

ENV TINI_VERSION v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

COPY dist /dist
COPY entrypoint.sh /

RUN chown root:root /tini && chmod +x /tini \
&&  chown -R root:root /dist \
&&  chown root:root /entrypoint.sh && chmod +x /entrypoint.sh \
&&  apt-get update && apt-get install --no-install-recommends -y sudo \
&&  apt-get clean &&  rm -rf /var/lib/apt/lists/* \
&&  useradd -g 0 default \
&&  echo "default	 ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-default-user

USER default

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=5m \
    --interval=5m \ 
    CMD ping -c 1 localhost || exit 1

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
