# Integration contract

Middleware reaches Sentry only over the private vSwitch.

- Base URL: `http://10.40.0.4:19000`
- Health: `GET /_health/`
- SDK DSNs: create per application after the first administrator is created.
- Required application tags: `service`, `environment`, `release`, `tenant`, and `request_id`.
- Alerts must route to Middleware and Alertmanager without embedding credentials in Git.
- Public ingress remains blocked until DNS, TLS, and Keycloak SSO are certified.
