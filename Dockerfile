FROM registry.access.redhat.com/ubi7/ubi:latest

ENV TM_LICHOST=172.0.0.1 \
    TM_LICPORT=57777 \
    TM_LICPASS=docker

LABEL name="Solution-Soft/Time Machine Sidecar for Kubernetes" \
      vendor="SolutionSoft Systems, Inc" \
      version="1.1" \
      release="1" \
      summary="Time Machine Sidecar for Kubernetes Image" \
      description="Time Machine creates virtual clocks for time shift testing of Applications" \
      url="https://solution-soft.com" \
      maintainer="kzhao@solution-soft.com"

COPY help.1 /
RUN mkdir -p "/licenses"
COPY licenses /licenses

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

COPY dist /dist
COPY entrypoint.sh /

RUN chown root:root /tini && chmod +x /tini \
&&  chown root:root /entrypoint.sh && chmod +x /entrypoint.sh \
&&  chown -R root:root /dist \
&&  yum --disableplugin=subscription-manager -y install sudo iproute tzdata \
&&  yum --disableplugin=subscription-manager clean all \
&&  useradd -g 0 default \
&&  echo "default	 ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-default-user

USER default

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=5m \
    --interval=5m \ 
    CMD ping -c 1 localhost || exit 1

EXPOSE 7800

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
