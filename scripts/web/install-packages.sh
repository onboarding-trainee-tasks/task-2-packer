#!/bin/bash
set -e

sudo cloud-init status --wait
sudo apt-get update
sudo apt-get install -y curl wget tar unzip jq ca-certificates adduser libfontconfig1
