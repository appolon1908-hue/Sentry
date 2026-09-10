# Codestra Sentry

Governed deployment wrapper for Sentry self-hosted 26.8.0.

- Target: 37.27.128.39 / private 10.40.0.4
- Public UI and ingestion: https://sentry.codestra.co
- Private listener: http://10.40.0.4:19000
- Event retention: 30 days
- Upstream source is pinned to release 26.8.0 by the deployment script.
- Administrator credentials are stored only at `/etc/codestra/secrets/sentry.env` with mode 0600.

Run `sudo ./scripts/deploy.sh`. The upstream deployment and persistent volumes live under `/opt/codestra-sentry`.
