#!/bin/bash
set -e

cd /tmp

wget https://github.com/prometheus/prometheus/releases/download/v3.13.0/prometheus-3.13.0.linux-amd64.tar.gz
tar xzf prometheus-3.13.0.linux-amd64.tar.gz

sudo install \
  -m 0755 \
  prometheus-3.13.0.linux-amd64/prometheus \
  /usr/local/bin/prometheus

sudo mkdir -p /etc/prometheus/rules
sudo mkdir -p /var/lib/prometheus

sudo install \
  -m 0644 \
  /tmp/prometheus.yml \
  /etc/prometheus/prometheus.yml

sudo install \
  -m 0644 \
  /tmp/service-rules.yml \
  /etc/prometheus/rules/service-rules.yml

sudo install \
  -m 0644 \
  /tmp/prometheus.service \
  /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl enable prometheus
