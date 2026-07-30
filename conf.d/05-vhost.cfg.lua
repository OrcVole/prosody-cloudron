-- VirtualHost + components.
-- Simple-JID approach: the app's own domain IS the XMPP VirtualHost, so JIDs are
-- user@xmpp.example.com and the connect host is the same on standard ports. No
-- apex cert, no SRV dependency.
--
-- Components collapse to ONE: conference.<domain> (MUC), the only one that needs
-- to be an independent federated entity. PEP on the main host covers pubsub;
-- file upload is served under the main host (mod_http_file_share, no subdomain);
-- proxy65 is dropped (HTTP file upload supersedes it).

local domain = os.getenv("DOMAIN")
local domain_muc = os.getenv("DOMAIN_MUC") or ("conference." .. domain)

-- XEP-0368: direct-TLS c2s on 5223. Cert is the app's primary cert.
c2s_direct_tls_ssl = {
	certificate = "/app/data/certs/" .. domain .. "/fullchain.pem";
	key = "/app/data/certs/" .. domain .. "/privkey.pem";
}
c2s_direct_tls_ports = { 5223 }

-- Cert for Prosody's own HTTPS listener (5281, internal/unused — Cloudron
-- terminates public TLS). Kept valid to avoid warnings.
https_ssl = {
	certificate = "/app/data/certs/" .. domain .. "/fullchain.pem";
	key = "/app/data/certs/" .. domain .. "/privkey.pem";
}

VirtualHost (domain)
	disco_items = {
		{ domain_muc, "Chatrooms" };
	}

	-- XEP-0363 HTTP file upload, served UNDER THE MAIN HOST (no upload subdomain).
	-- mod_http_file_share is in modules_enabled; HTTP endpoint is fronted by
	-- Cloudron TLS at https://<domain>/file_share. Needs no federation cert.
	http_file_share_expires_after = 60 * 60 * 24 * 7 -- one week
	http_file_share_size_limit = tonumber(os.getenv("HTTP_FILE_SHARE_SIZE_LIMIT")) or 100 * 1024 * 1024
	http_file_share_daily_quota = tonumber(os.getenv("HTTP_FILE_SHARE_DAILY_QUOTA")) or (10 * (tonumber(os.getenv("HTTP_FILE_SHARE_SIZE_LIMIT")) or 100 * 1024 * 1024))

-- XEP-0045 Multi-User Chat. The one federated component — needs its own
-- CA-trusted cert via a Cloudron app alias (Phase 3).
Component (domain_muc) "muc"
	name = "Chatrooms"
	restrict_room_creation = false
	max_history_messages = 50
	modules_enabled = {
		"muc_mam"; -- archive room history (core; MUC vCard/avatars are built in)
	}
