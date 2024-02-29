FROM        amazonlinux:2023.0.20230614.0

EXPOSE      9090

RUN         yum install -y aws-cli && yum install -y tar && yum install -y gzip && yum install -y procps && yum install -y wget

RUN         mkdir -p /tmp/prometheus
RUN         wget -O /tmp/prometheus/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.18.1/prometheus-2.18.1.linux-amd64.tar.gz
RUN         mkdir -p /prometheus/bin
RUN         wget -O /prometheus/bin/service-discovery https://github.com/teralytics/prometheus-ecs-discovery/releases/download/v1.3.1/prometheus-ecs-discovery-linux-amd64
RUN         chmod +x /prometheus/bin/service-discovery

COPY        scripts/setup.sh               /tmp/prometheus
COPY        scripts/prometheus.sh          /prometheus/bin/prometheus.sh
COPY        scripts/config-download.sh     /prometheus/bin/config-download.sh
COPY        scripts/reload-cycle.sh        /prometheus/bin/reload-cycle.sh
COPY        scripts/service-discovery.sh   /prometheus/bin/service-discovery.sh


RUN chmod +x /tmp/prometheus/setup.sh &&\
    chmod +x /prometheus/bin/* &&\
    /tmp/prometheus/setup.sh &&\
    chown -R 1000:1000 /prometheus

USER 1000
ENTRYPOINT [ "sh", "-c", "/prometheus/bin/prometheus.sh" ]
