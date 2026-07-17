#!/bin/bash
set -e

sudo mkdir -p /etc/systemd/system/ollama.service.d

sudo install \
  -m 0644 \
  /tmp/ollama-override.conf \
  /etc/systemd/system/ollama.service.d/override.conf

sudo mkdir -p /usr/share/ollama/.ollama/models
sudo chown -R ollama:ollama /usr/share/ollama

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama
