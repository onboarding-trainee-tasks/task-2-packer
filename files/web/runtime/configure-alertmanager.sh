#!/bin/bash

set -e

AWS_REGION="$1"
SMTP_SECRET_ARN="$2"

SMTP_SECRET=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SMTP_SECRET_ARN" \
  --query SecretString \
  --output text)

SMTP_USERNAME=$(echo "$SMTP_SECRET" | jq -r '.smtp_username')
SMTP_PASSWORD=$(echo "$SMTP_SECRET" | jq -r '.smtp_password')
SMTP_FROM=$(echo "$SMTP_SECRET" | jq -r '.smtp_from')
SMTP_TO=$(echo "$SMTP_SECRET" | jq -r '.smtp_to')

mkdir -p /etc/alertmanager/secrets
mkdir -p /var/lib/alertmanager

printf '%s' "$SMTP_PASSWORD" \
  > /etc/alertmanager/secrets/smtp_password

chown root:alertmanager \
  /etc/alertmanager/secrets/smtp_password

chmod 640 \
  /etc/alertmanager/secrets/smtp_password

cat > /etc/alertmanager/alertmanager.yaml <<EOF
global:
  resolve_timeout: 5m

  smtp_smarthost: "smtp.gmail.com:587"
  smtp_from: "$SMTP_FROM"
  smtp_auth_username: "$SMTP_USERNAME"
  smtp_auth_password_file: "/etc/alertmanager/secrets/smtp_password"
  smtp_require_tls: true

route:
  receiver: email-default

  group_by:
    - alertname
    - environment
    - severity

  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

receivers:
  - name: email-default

    email_configs:
      - to: "$SMTP_TO"
        send_resolved: true

        headers:
          Subject: '[{{ .Status | toUpper }}] {{ .CommonLabels.alertname }}'
EOF

chown root:alertmanager \
  /etc/alertmanager/alertmanager.yaml

chmod 640 \
  /etc/alertmanager/alertmanager.yaml

systemctl daemon-reload
systemctl enable alertmanager
systemctl restart alertmanager