FROM debian:stable-slim

LABEL name="Solution-Soft/Time Machine" vendor="SolutionSoft Systems Inc" version="1.1" release="1" summary="Time Machine Sidecar Container" description="Time Machine creates virtual clocks for time shift testing of Applications" url="https://solution-soft.com" maintainer="Ken Zhao - SolutionSoft Systems Inc."

COPY help.1 /
RUN mkdir -p "/licenses"
COPY licenses /licenses

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
