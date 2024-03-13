#!/bin/sh

# Starting service-discovery in background
/prometheus/bin/service-discovery.sh &

echo "Starting Prometheus"
/prometheus/bin/prometheus \
    --config.file=/prometheus/config/prometheus.yml \
    --storage.tsdb.path=/prometheus/data  \
    --web.console.libraries=/prometheus/console_libraries \
    --web.console.templates=/prometheus/consoles 2>&1

