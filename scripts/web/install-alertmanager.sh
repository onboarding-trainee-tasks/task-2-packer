#!/bin/bash
set -e

cd /tmp

wget https://github.com/prometheus/alertmanager/releases/download/v0.33.1/alertmanager-0.33.1.linux-amd64.tar.gz
tar xzf alertmanager-0.33.1.linux-amd64.tar.gz

sudo useradd \
  --system \
  --no-create-home \
  --shell /usr/sbin/nologin \
  alertmanager || true

sudo install \
  -m 0755 \
  alertmanager-0.33.1.linux-amd64/alertmanager \
  /usr/local/bin/alertmanager

sudo install \
  -m 0755 \
  alertmanager-0.33.1.linux-amd64/amtool \
  /usr/local/bin/amtool

sudo mkdir -p /etc/alertmanager/secrets
sudo mkdir -p /var/lib/alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager

sudo install \
  -m 0644 \
  /tmp/alertmanager.service \
  /etc/systemd/system/alertmanager.service
