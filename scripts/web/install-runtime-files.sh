#!/bin/bash
set -e

sudo mkdir -p /usr/local/share/alertmanager

sudo install \
  -m 0755 \
  /tmp/configure-alertmanager.sh \
  /usr/local/bin/configure-alertmanager.sh

sudo install \
  -m 0755 \
  /tmp/start-open-webui.sh \
  /usr/local/bin/start-open-webui.sh

sudo systemctl daemon-reload
