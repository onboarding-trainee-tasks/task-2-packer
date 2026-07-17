#!/bin/bash
set -e

cd /tmp

wget https://dl.grafana.com/grafana-enterprise/release/13.1.0/grafana-enterprise_13.1.0_28013217238_linux_amd64.deb
sudo dpkg -i grafana-enterprise_13.1.0_28013217238_linux_amd64.deb

sudo sed -i 's/^;http_port = 3000$/http_port = 5000/' /etc/grafana/grafana.ini

sudo mkdir -p /etc/grafana/provisioning/datasources
sudo mkdir -p /etc/grafana/provisioning/dashboards
sudo mkdir -p /etc/grafana/provisioning/alerting
sudo mkdir -p /var/lib/grafana/dashboards

sudo install -m 0644 /tmp/datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml
sudo install -m 0644 /tmp/provider.yaml /etc/grafana/provisioning/dashboards/provider.yaml
sudo install -m 0644 /tmp/alert-rules.yaml /etc/grafana/provisioning/alerting/alert-rules.yaml

sudo install -o grafana -g grafana -m 0644 /tmp/instances-dashboard.json /var/lib/grafana/dashboards/instances-dashboard.json
sudo install -o grafana -g grafana -m 0644 /tmp/services-dashboard.json /var/lib/grafana/dashboards/services-dashboard.json
sudo install -o grafana -g grafana -m 0644 /tmp/aws-infra-dashboard.json /var/lib/grafana/dashboards/aws-infra-dashboard.json

sudo systemctl enable grafana-server
