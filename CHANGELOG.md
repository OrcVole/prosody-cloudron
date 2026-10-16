[1.0.1]

- Base image cloudron/base 5.0.0 to 6.0.0 (Ubuntu 26.04). Prosody still comes from the official Prosody apt repository (Ubuntu 26.04 carries only 13.0.4), now its resolute suite; Lua stays 5.4.
- Prosody 13.0.6 to 13.0.7: bug fixes only, no security items. Fixes memory leaks in the network layer, a BSD problem, and adds the tls_profile_version option (default unchanged at 5.7).

[1.0.0]

- Initial release: Prosody 13.0.6 (official stable apt package) for Cloudron.
- Cloudron accounts as XMPP accounts via the LDAP addon — no separate user database.
- Real certificates from the Cloudron TLS addon on 5222/5223/5269 (simple-JID design: the app domain is the XMPP host, so no apex-domain certificate is needed).
- Audio/video calls via the Cloudron TURN addon (XEP-0215), including TURN-over-TLS for restrictive networks.
- Multi-user chat on `conference.<domain>` as a Cloudron app alias with its own trusted certificate — federation verified against public servers.
- HTTP file upload (XEP-0363) on the main host; message archive (MAM), carbons, stream management, push notifications, BOSH and WebSocket.
- SQLite storage in Cloudron's backed-up data volume.
- Health check reports real server status (mod_host_status_check routed via http_default_host).
