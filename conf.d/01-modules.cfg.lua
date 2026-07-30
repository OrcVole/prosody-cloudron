-- Globally enabled modules. In Prosody 13.0 many modules that older packages
-- pulled from the community repo are now CORE (smacks, turn_external,
-- server_contact_info, mam, carbons, csi_simple, muc_mam, bosh, websocket,
-- mod_auth_ldap). Community modules are copied to plugin_paths by the Dockerfile.

modules_enabled = {
	-- Core / required
	"roster";        -- XEP-0237 roster
	"saslauth";      -- client/server authentication
	"tls";           -- STARTTLS on c2s/s2s
	"dialback";      -- s2s dialback
	"disco";         -- service discovery

	-- Recommended
	"blocklist";     -- XEP-0191 blocking
	"private";       -- XEP-0049 private XML storage
	"vcard4";        -- XEP-0292 vCard4 over PEP
	"vcard_legacy";  -- XEP-0054 compatibility
	"pep";           -- XEP-0163 personal eventing
	"mam";           -- XEP-0313 message archive
	"carbons";       -- XEP-0280 message carbons (multi-device)
	"smacks";        -- XEP-0198 stream management (core in 13.0)
	"csi_simple";    -- XEP-0352 client state indication

	-- Niceties / discovery
	"version";
	"uptime";
	"time";
	"ping";
	"register";          -- in-band registration (open registration)
	"announce";          -- server announcements
	"server_contact_info"; -- XEP-0157 (core)
	"admin_adhoc";       -- XEP-0050 admin commands
	"admin_shell";       -- prosodyctl shell for debugging

	-- HTTP-facing (served on httpPort 5280, fronted by Cloudron TLS)
	"http";
	"bosh";            -- XEP-0206 BOSH
	"websocket";       -- RFC 7395 XMPP-over-WebSocket
	"http_file_share"; -- XEP-0363 upload, on the main host (no upload subdomain)

	-- Real-time media signalling
	"turn_external"; -- XEP-0215 external STUN/TURN (core in 13.0)

	-- Cloudron health check (community)
	"host_status_check";
	"http_host_status_check";

	-- Community extras
	"cloud_notify";       -- XEP-0357 push notifications
	"e2e_policy";         -- advertise/encourage E2E encryption
	"filter_chatstates";  -- drop "is typing" for inactive clients
	"throttle_presence";  -- CSI presence throttling
}

modules_disabled = {
	-- "offline";
}
