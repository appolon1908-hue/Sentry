#!/usr/bin/env bash
set -Eeuo pipefail
readonly PUBLIC_DOCKER_CONFIG=/var/lib/codestra/docker-public
install -d -m 0700 "$PUBLIC_DOCKER_CONFIG"
if [[ ! -f "$PUBLIC_DOCKER_CONFIG/config.json" ]]; then
  printf '%s\n' '{"auths":{}}' > "$PUBLIC_DOCKER_CONFIG/config.json"
  chmod 0600 "$PUBLIC_DOCKER_CONFIG/config.json"
fi
export DOCKER_CONFIG="$PUBLIC_DOCKER_CONFIG"
readonly ROOT=/opt/codestra-sentry
readonly UPSTREAM="$ROOT/upstream"
readonly RELEASE=26.8.0
readonly PUBLIC_URL=https://sentry.codestra.co
readonly HEALTH_URL=http://10.40.0.4:19000
install -d -m 0750 "$ROOT"
if [[ ! -d "$UPSTREAM/.git" ]]; then
  git clone --depth 1 --branch "$RELEASE" https://github.com/getsentry/self-hosted.git "$UPSTREAM"
else
  git -C "$UPSTREAM" fetch --depth 1 origin "refs/tags/$RELEASE:refs/tags/$RELEASE"
  git -C "$UPSTREAM" checkout --detach "$RELEASE"
fi
cd "$UPSTREAM"
# config.yml is managed below; restore its pinned upstream base before validation.
git checkout -- sentry/config.yml
git diff --exit-code
export SENTRY_BIND=10.40.0.4:19000
if [[ ! -f .codestra-installed ]]; then
  ./install.sh --skip-user-creation --no-report-self-hosted-issues --no-apply-automatic-config-updates
  touch .codestra-installed
fi
set_env() {
  local key="$1" value="$2"
  if grep -q "^$key=" .env 2>/dev/null; then
    sed -i "s|^$key=.*|$key=$value|" .env
  else
    printf '\n%s=%s\n' "$key" "$value" >> .env
  fi
}
set_env SENTRY_BIND 10.40.0.4:19000
set_env SENTRY_EVENT_RETENTION_DAYS 30
sed -i "s|^# system.url-prefix:.*|system.url-prefix: '$PUBLIC_URL'|" sentry/config.yml
docker compose up -d
for _ in $(seq 1 60); do
  curl -fsS "$HEALTH_URL/_health/" >/dev/null && exit 0
  sleep 10
done
docker compose ps
exit 1
