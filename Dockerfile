FROM centos:7

ENV TINI_VERSION v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chown root:root /tini && chmod +x /tini

ADD https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-i686 /busybox
RUN chown root:root /busybox && chmod +x /busybox

COPY dist /dist
COPY entrypoint.sh /
RUN chown -R root:root /dist \
&&  chown root:root /entrypoint.sh && chmod +x /entrypoint.sh

USER root

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=5m \
    --interval=5m \ 
    CMD ping -c 1 localhost || exit 1

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
