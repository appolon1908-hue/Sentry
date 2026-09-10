# Codestra Sentry

Governed deployment wrapper for Sentry self-hosted 26.8.0.

- Target: 37.27.128.39 / private 10.40.0.4
- UI and ingestion: http://10.40.0.4:19000
- Public exposure: disabled pending DNS, TLS, and Keycloak
- Upstream source is pinned to the signed release tag by the deployment script.

Run `sudo ./scripts/deploy.sh`. The upstream deployment and persistent volumes live under `/opt/codestra-sentry`.
