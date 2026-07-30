# Notes for Prosody developers — from packaging Prosody 13.0 for a managed platform

Observations from packaging Prosody 13.0.6 for [Cloudron](https://www.cloudron.io/)
(a self-hosting platform: readonly filesystem, managed TLS/LDAP/TURN, reverse proxy,
health-checked containers). Offered as friendly upstream feedback — everything here
has a workaround, documented in this repo; these are the places where a doc note or
small feature would help the next platform packager.

## 1. Config-sandbox noise for env-driven configs

Prosody 13's config sandbox logs a deprecation warning for every `os.getenv` /
`tonumber` call ("replace `os` with `Lua.os`"). A containerised config that reads its
values from environment variables emits dozens of warning lines per boot. A documented,
warning-free idiom for env-driven configuration would help every container packager.

## 2. HTTP host routing vs platform health checks

Platform health checkers typically probe by **container IP**, with no vhost Host
header. Prosody routes HTTP by Host header, so every such probe 404s even when the
server is healthy — the platform then either flaps the app or (worse) silently treats
any TCP answer as healthy. The fix is one line — `http_default_host` — but it is easy
to miss and the failure is invisible. First-class guidance for "Prosody as a backend
service behind a managed proxy" (health route, `http_default_host`,
`http_external_url`, trusted proxies) would help. Related: the de-facto health
endpoint (`mod_http_host_status_check`) still lives in community modules.

## 3. SASL with bind-mode LDAP surprises users

With bind-mode LDAP auth Prosody correctly offers only PLAIN (no reusable secret ⇒ no
SCRAM), but many clients ship with PLAIN disabled and then show a generic
wrong-password error. A clearer client-facing error ("server offers only PLAIN;
enable cleartext-over-TLS") — or a doc note packagers can link users to — would cut
support load considerably.

## 4. Managed coturn on a different hostname works great — document it

`mod_turn_external` (XEP-0215 with TURN REST `use-auth-secret` credentials) against a
platform-managed coturn that fronts on a *different* hostname than the JID domain
works out of the box, including TURN-over-TLS. A short doc example of exactly this
shape would help packagers on any managed platform.

## 5. What's now core (13.0) vs community — a packager-facing list

Many modules older guides copy from the community repo are core in 13.0 (`smacks`,
`turn_external`, `mam`, `carbons`, `csi_simple`, `muc_mam`, `server_contact_info`,
`auth_ldap`, `cloud_notify`, `vcard_muc`) — and copying the community `cloud_notify` /
`vcard_muc` now **conflicts** with the built-ins. A canonical "core vs community as of
this release" list aimed at packagers would prevent a whole class of upgrade bugs.

---

Context for all of the above: this package runs Prosody from the official stable apt
packages on Ubuntu, config driven entirely by environment variables derived from
platform addons at boot. Scores 91% on compliance.conversations.im. Details in the
[README](../README.md) and the configs in this repo.
