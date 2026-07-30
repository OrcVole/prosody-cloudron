-- Prosody main config for the Cloudron package.
-- Per-feature config lives in conf.d/*.cfg.lua. Values come from environment
-- variables that start.sh derives from the Cloudron addons on every boot.

-- Small helper so we don't need the luarocks `stringy` module just to split
-- comma/space separated env vars into Lua lists.
function env_list(value)
	local out = {}
	for item in (value or ""):gmatch("[^,%s]+") do
		out[#out + 1] = item
	end
	return out
end

-- Custom (community) modules copied in by the Dockerfile.
plugin_paths = { "/usr/local/lib/prosody/custom-modules/" }

-- Writable paths (Cloudron: only /app/data, /run, /tmp are writable).
data_path = "/app/data"
certificates = "/app/data/certs"
run_dir = "/run/prosody"
pidfile = "/run/prosody/prosody.pid"

admins = env_list(os.getenv("PROSODY_ADMINS"))

allow_registration = (os.getenv("ALLOW_REGISTRATION") == "true")

c2s_require_encryption = (os.getenv("C2S_REQUIRE_ENCRYPTION") ~= "false")
s2s_require_encryption = (os.getenv("S2S_REQUIRE_ENCRYPTION") ~= "false")
s2s_secure_auth = (os.getenv("S2S_SECURE_AUTH") ~= "false")

-- Authentication: Cloudron LDAP addon via core mod_auth_ldap (bundled in 13.0).
authentication = os.getenv("AUTHENTICATION") or "internal_hashed"
ldap_base = os.getenv("LDAP_BASE")
ldap_server = os.getenv("LDAP_SERVER") or "localhost"
ldap_rootdn = os.getenv("LDAP_ROOTDN") or ""
ldap_password = os.getenv("LDAP_PASSWORD") or ""
ldap_filter = os.getenv("LDAP_FILTER") or "(uid=$user)"
ldap_scope = os.getenv("LDAP_SCOPE") or "subtree"
ldap_tls = (os.getenv("LDAP_TLS") == "true")
ldap_mode = os.getenv("LDAP_MODE") or "bind"
ldap_admin_filter = os.getenv("LDAP_ADMIN_FILTER")

-- STUN/TURN advertised to clients via XEP-0215 (mod_turn_external, core in 13.0).
turn_external_host = os.getenv("TURN_SERVER")
turn_external_secret = os.getenv("TURN_SECRET")
turn_external_port = tonumber(os.getenv("TURN_PORT") or "3478")
-- Also advertise TURN-over-TLS (turns://) so clients on UDP-blocked / 443-only
-- networks can still relay. Verified relay path: 50000-51000/udp open end-to-end.
turn_external_tls_port = tonumber(os.getenv("TURN_TLS_PORT") or "5349")

-- Behind Cloudron's reverse proxy: TLS is terminated by Cloudron and proxied to
-- httpPort (5280) over plain HTTP. Tell Prosody its real public base URL so
-- generated links (file upload, BOSH/websocket) use https://<domain>.
http_external_url = os.getenv("HTTP_EXTERNAL_URL")

-- Route HTTP requests with an unknown Host header to the main vhost. Cloudron's
-- health checker connects by container IP (no vhost Host header), so without
-- this every health probe 404s even though /host_status_check works.
http_default_host = os.getenv("DOMAIN")

log = {
	{ levels = { min = os.getenv("LOG_LEVEL") or "info" }, to = "console" };
}

-- Listen on all interfaces inside the container so Cloudron can reach us.
http_interfaces = { "0.0.0.0", "::" }
https_interfaces = { "0.0.0.0", "::" }
interfaces = { "0.0.0.0", "::" }

Include "conf.d/*.cfg.lua"
