#!/usr/bin/env bash
set -Eeuo pipefail
readonly ROOT=/opt/codestra-sentry
readonly UPSTREAM="$ROOT/upstream"
readonly RELEASE=26.8.0
install -d -m 0750 "$ROOT"
if [[ ! -d "$UPSTREAM/.git" ]]; then
  git clone --depth 1 --branch "$RELEASE" https://github.com/getsentry/self-hosted.git "$UPSTREAM"
else
  git -C "$UPSTREAM" fetch --depth 1 origin "refs/tags/$RELEASE:refs/tags/$RELEASE"
  git -C "$UPSTREAM" checkout --detach "$RELEASE"
fi
cd "$UPSTREAM"
git diff --exit-code
export SENTRY_BIND=10.40.0.4:19000
if [[ ! -f .codestra-installed ]]; then
  ./install.sh --skip-user-creation
  touch .codestra-installed
fi
grep -q '^SENTRY_BIND=' .env 2>/dev/null && sed -i 's/^SENTRY_BIND=.*/SENTRY_BIND=10.40.0.4:19000/' .env || printf '\nSENTRY_BIND=10.40.0.4:19000\n' >> .env
docker compose up -d
for _ in $(seq 1 60); do
  curl -fsS http://10.40.0.4:19000/_health/ >/dev/null && exit 0
  sleep 10
done
docker compose ps
exit 1
