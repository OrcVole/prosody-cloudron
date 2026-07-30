## Prosody is running 🎉

**Logging in**

- Point an XMPP client (Conversations on Android, Gajim/Dino/Kaidan on desktop) at your domain.
- Your JID is `user@$CLOUDRON-APP-FQDN` — log in with your **Cloudron username (or email) and password**.
- If login fails as if the password were wrong, enable **SASL PLAIN / "allow cleartext auth"** in your
  client. This is safe here: the connection always requires TLS first.
- Prosody is a backend service — there is no web UI to open in a browser.

**Group chat (recommended)**

Add the multi-user chat component as an app alias so it gets its own trusted certificate:

```
cloudron configure --app $CLOUDRON-APP-FQDN --alias-domains conference.$CLOUDRON-APP-FQDN
```

On a Cloudron-managed DNS zone this creates the DNS record and provisions the certificate automatically.

**Federation and calls — check your provider firewall**

Cloudron's own firewall opens the app's ports, but if your server sits behind a cloud
security group or provider firewall, these must be reachable from the internet:

- **5222, 5223, 5269 (TCP)** — client and server-to-server XMPP.
- **3478 and 5349 (TCP+UDP)** plus the **TURN relay range (UDP, 50000–51000 by default)** — required
  for audio/video calls through NAT.

**Optional DNS SRV records** (not required — the JID domain is the connect host on standard
ports — but they help other servers and clients discover yours):

```
_xmpp-client._tcp.$CLOUDRON-APP-FQDN.            300 IN SRV 0 5 5222 $CLOUDRON-APP-FQDN.
_xmpps-client._tcp.$CLOUDRON-APP-FQDN.           300 IN SRV 0 5 5223 $CLOUDRON-APP-FQDN.
_xmpp-server._tcp.$CLOUDRON-APP-FQDN.            300 IN SRV 0 5 5269 $CLOUDRON-APP-FQDN.
_xmpp-server._tcp.conference.$CLOUDRON-APP-FQDN. 300 IN SRV 0 5 5269 $CLOUDRON-APP-FQDN.
```

Project homepage: https://prosody.im — Package: https://github.com/OrcVole/prosody-cloudron
