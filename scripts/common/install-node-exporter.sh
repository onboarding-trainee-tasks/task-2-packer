#!/bin/bash
set -e

cd /tmp

wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
tar xzf node_exporter-1.10.2.linux-amd64.tar.gz

sudo install \
  -m 0755 \
  node_exporter-1.10.2.linux-amd64/node_exporter \
  /usr/local/bin/node_exporter

sudo useradd \
  --system \
  --no-create-home \
  --shell /usr/sbin/nologin \
  node_exporter || true

sudo install \
  -m 0644 \
  /tmp/node_exporter.service \
  /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
