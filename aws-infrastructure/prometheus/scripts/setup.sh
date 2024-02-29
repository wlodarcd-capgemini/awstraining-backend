#!/bin/bash
# Prepare Prometheus
cd /tmp/prometheus
tar -xzf prometheus*.tar.gz

mkdir /prometheus
mkdir /prometheus/bin
mkdir /prometheus/data
mkdir /prometheus/rules
mkdir /prometheus/config
mkdir /prometheus/download
mkdir /prometheus/logs

DIR=$(ls | grep "prometheus.*amd64$")

cp ./$DIR/prometheus /prometheus/bin
cp ./$DIR/promtool /prometheus/bin
cp -R ./$DIR/console_libraries /prometheus
cp -R ./$DIR/consoles /prometheus
cp ./$DIR/prometheus.yml /prometheus/config

rm -Rf *