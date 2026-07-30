#!/bin/bash
# Map Cloudron addon environment -> Prosody config environment.
# Sourced by start.sh on EVERY boot. Cloudron addon values (CLOUDRON_LDAP_*,
# CLOUDRON_TURN_*) change on every restart, so they are NEVER baked into static
# config — they are read fresh here and consumed by the *.cfg.lua files.

# --- Domain: simple-JID. The app's own domain IS the XMPP VirtualHost. ---
export DOMAIN="${CLOUDRON_APP_DOMAIN}"
export DOMAIN_APP="${CLOUDRON_APP_DOMAIN}"
# Only one federated component subdomain: MUC. PEP covers pubsub; file upload is
# served under the main host; proxy65 is dropped.
export DOMAIN_MUC="${DOMAIN_MUC:-conference.$DOMAIN}"

# Public base URL — Cloudron terminates TLS and reverse-proxies to httpPort.
export HTTP_EXTERNAL_URL="${HTTP_EXTERNAL_URL:-https://$DOMAIN/}"

# --- Registration: OPEN (operator decision). ---
export ALLOW_REGISTRATION="${ALLOW_REGISTRATION:-true}"

# --- Auth: Cloudron LDAP addon, bind mode (core mod_auth_ldap). ---
export AUTHENTICATION="ldap"
export LDAP_SERVER="${CLOUDRON_LDAP_SERVER}:${CLOUDRON_LDAP_PORT}"
export LDAP_BASE="${CLOUDRON_LDAP_USERS_BASE_DN}"
export LDAP_ROOTDN="${CLOUDRON_LDAP_BIND_DN}"
export LDAP_PASSWORD="${CLOUDRON_LDAP_BIND_PASSWORD}"
export LDAP_MODE="bind"
export LDAP_TLS="false"
export LDAP_SCOPE="subtree"
# Cloudron user objects are objectclass=user; match username OR email.
# $user / $host are substituted by mod_auth_ldap at query time.
export LDAP_FILTER="${LDAP_FILTER:-(&(objectclass=user)(|(username=\$user)(mail=\$user)))}"

# --- TURN/STUN: Cloudron turn addon -> XEP-0215 (mod_turn_external). ---
export TURN_SERVER="${CLOUDRON_TURN_SERVER:-}"
export TURN_SECRET="${CLOUDRON_TURN_SECRET:-}"
export TURN_PORT="${CLOUDRON_TURN_PORT:-3478}"
export TURN_TLS_PORT="${CLOUDRON_TURN_TLS_PORT:-5349}"

# --- E2E policy: OMEMO OPTIONAL (operator decision). ---
export E2E_POLICY_CHAT="${E2E_POLICY_CHAT:-optional}"
export E2E_POLICY_MUC="${E2E_POLICY_MUC:-optional}"
export E2E_POLICY_WHITELIST="${E2E_POLICY_WHITELIST:-}"

# --- Transport encryption (TLS) ---
export C2S_REQUIRE_ENCRYPTION="${C2S_REQUIRE_ENCRYPTION:-true}"
export S2S_REQUIRE_ENCRYPTION="${S2S_REQUIRE_ENCRYPTION:-true}"
export S2S_SECURE_AUTH="${S2S_SECURE_AUTH:-true}"

# --- Storage (SQLite in the backed-up /app/data volume) ---
export DB_DRIVER="${DB_DRIVER:-SQLite3}"
export DB_DATABASE="${DB_DATABASE:-prosody.sqlite}"

# --- Logging / admins ---
export LOG_LEVEL="${LOG_LEVEL:-info}"
export PROSODY_ADMINS="${PROSODY_ADMINS:-}"
