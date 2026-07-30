Prosody is a modern XMPP communication server. It aims to be easy to set up and configure, and efficient with system resources.

This package gives you a private chat and calls server where **every account is one of your existing Cloudron users** (via the LDAP addon). JIDs are simply `user@<app-domain>` — no apex-domain certificate and no mandatory SRV records.

**Features**

* 1:1 chat, group chat (MUC), multi-device sync, message history (MAM), file/image sharing (XEP-0363), and 1:1 audio/video calls.
* Real certificates on the XMPP ports from the Cloudron TLS addon; calls work through NAT via the Cloudron TURN addon, including TURN-over-TLS.
* Server-to-server federation, with the group-chat component getting its own trusted certificate as a Cloudron app alias.
* Works with standard clients: Conversations (Android), Gajim, Dino, Kaidan (desktop), and others.
* End-to-end encryption (OMEMO/OTR/PGP) encouraged but optional, for the widest client compatibility.
* SQLite storage in Cloudron's backed-up data volume.

Prosody is a backend service — configure it with an XMPP client, not a browser.
