#!/bin/bash

echo "Starting Service Discovery with Filter ${DISCOVERY_FILTER}"

/prometheus/bin/service-discovery -config.write-to /prometheus/discovered.yml \
 -config.scrape-interval 1m0s \
 -config.scrape-times 0 \
 -config.filter-label ${DISCOVERY_FILTER} 2>&1