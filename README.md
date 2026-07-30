# Prosody (XMPP) for Cloudron

[Prosody 13.0](https://prosody.im/) packaged as a [Cloudron](https://www.cloudron.io/) app: a private
chat and calls server where every account is one of your existing Cloudron users.

- **Cloudron accounts are your XMPP accounts** (LDAP addon) — no separate user database.
- **Simple JIDs:** `user@xmpp.example.com` — the app's own domain is the XMPP host, so there is
  no apex-domain certificate problem and SRV records are optional.
- **Real certificates** on 5222/5223/5269 from the Cloudron TLS addon, auto-renewed.
- **Audio/video calls** through NAT via the Cloudron TURN addon (XEP-0215), including TURN-over-TLS.
- **Federation** — server-to-server with CA-trusted certs; the MUC component
  `conference.<domain>` gets its own certificate as a Cloudron app alias.
- HTTP file upload (XEP-0363), message archive (MAM), carbons, stream management,
  push notifications (XEP-0357), BOSH and WebSocket.
- Prosody **13.0.6** pinned from the official Prosody apt repository (stable, not nightly),
  SQLite storage in Cloudron's backed-up data volume.

## Installing

From the Cloudron App Store (community section), or from source:

```bash
cd prosody-cloudron
cloudron build                          # build and push the image
cloudron install --location xmpp        # install at xmpp.<your-domain>
```

### After install

Add the group-chat component as an app alias so federation gets a real certificate:

```bash
cloudron configure --app xmpp.example.com --alias-domains conference.xmpp.example.com
```

Then point an XMPP client (Conversations, Gajim, Dino, Kaidan, …) at your domain and log in
with your Cloudron username (or email) and password. If login fails as if the password were
wrong, enable SASL PLAIN / "allow cleartext auth" in the client — safe here, since c2s
requires TLS before authentication.

See [POSTINSTALL.md](POSTINSTALL.md) for the provider-firewall ports needed for federation
and calls, and the optional SRV records.

## Diagnostics

```bash
cloudron logs -f --app xmpp.example.com
cloudron exec  --app xmpp.example.com -- /usr/local/bin/prosody-check.bash
cloudron exec  --app xmpp.example.com -- /usr/local/bin/prosody-shell.bash
```

Visiting the app's web address in a browser is not how you use it — Prosody is a backend
service; configure it with an XMPP client.

## Layout

- `Dockerfile`, `CloudronManifest.json` — the image and the Cloudron app contract.
- `prosody.cfg.lua`, `conf.d/` — Prosody configuration; values come from environment
  variables derived from the Cloudron addons on every boot.
- `start.sh`, `cloudron-env.bash`, `cloudron-cert-setup.bash` — wire the Cloudron
  `ldap`/`tls`/`turn` addons into Prosody at each start.

## For Prosody developers

Packaging Prosody for a managed platform surfaced a handful of places where upstream
docs or small features would help the next packager — collected in
[docs/notes-for-prosody-developers.md](docs/notes-for-prosody-developers.md).

## Credits

Forked from [DerekJarvis/cloudron-prosody](https://github.com/DerekJarvis/cloudron-prosody),
itself a fork of [SaraSmiseth/prosody](https://github.com/SaraSmiseth/prosody). The Cloudron
packaging was reworked for Prosody 13.0 (official apt packages), Debian FHS paths, Lua 5.4,
and the Cloudron tls/ldap/turn addons. Thanks also to the Prosody project, the Cloudron team,
and the long-running Cloudron forum thread on XMPP packaging that mapped this territory first.
