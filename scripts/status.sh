#!/usr/bin/env bash
set -Eeuo pipefail
cd /opt/codestra-sentry/upstream
docker compose ps
curl -fsS http://10.40.0.4:19000/_health/
