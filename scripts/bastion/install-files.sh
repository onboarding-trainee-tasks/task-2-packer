#!/bin/bash
set -e

sudo install \
  -m 0644 \
  /tmp/db_init.sql \
  /usr/local/share/db_init.sql

sudo install \
  -m 0755 \
  /tmp/init-database.sh \
  /usr/local/bin/init-database.sh
