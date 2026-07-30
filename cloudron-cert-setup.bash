#!/bin/bash
# Lay out TLS material from the Cloudron `tls` addon into the per-domain layout
# Prosody expects (certs/<domain>/{fullchain,privkey}.pem).
#
# The tls addon provides the app's PRIMARY cert (auto-renewed) at:
#   /etc/certs/tls_cert.pem  and  /etc/certs/tls_key.pem
#
# Component subdomains (conference., pubsub.) get their own CA-trusted certs
# once added as Cloudron app *aliases* (Phase 3). The exact on-disk filename for
# alias certs is verified in Phase 3; until a dedicated cert is present we fall
# back to the primary cert so every host still loads.
#
# Sourced by start.sh on every boot. Never cached.

CERT_SRC="/etc/certs"
CERT_DST="/app/data/certs"
PRIMARY_CERT="${CERT_SRC}/tls_cert.pem"
PRIMARY_KEY="${CERT_SRC}/tls_key.pem"

mkdir -p "${CERT_DST}"

install_cert() {
	# $1 domain  $2 src_cert  $3 src_key
	local domain="$1" src_cert="$2" src_key="$3"
	[[ -f "${src_cert}" && -f "${src_key}" ]] || return 1
	mkdir -p "${CERT_DST}/${domain}"
	cp -L "${src_cert}" "${CERT_DST}/${domain}/fullchain.pem"
	cp -L "${src_key}"  "${CERT_DST}/${domain}/privkey.pem"
	return 0
}

# Primary VirtualHost.
if ! install_cert "${DOMAIN}" "${PRIMARY_CERT}" "${PRIMARY_KEY}"; then
	echo "[cert-setup] WARNING: primary cert ${PRIMARY_CERT} not found yet."
fi

# MUC is the only federated component: prefer its dedicated alias cert if one
# exists (Phase 3), else fall back to the primary cert so the host still loads.
for sub in "${DOMAIN_MUC}"; do
	if [[ -f "${CERT_SRC}/${sub}.cert" && -f "${CERT_SRC}/${sub}.key" ]]; then
		install_cert "${sub}" "${CERT_SRC}/${sub}.cert" "${CERT_SRC}/${sub}.key"
	elif [[ -f "${CERT_SRC}/${sub}/tls_cert.pem" ]]; then
		install_cert "${sub}" "${CERT_SRC}/${sub}/tls_cert.pem" "${CERT_SRC}/${sub}/tls_key.pem"
	else
		install_cert "${sub}" "${PRIMARY_CERT}" "${PRIMARY_KEY}"
	fi
done

chown -R prosody:prosody "${CERT_DST}" 2>/dev/null || true
find "${CERT_DST}" -name privkey.pem -exec chmod 0640 {} \; 2>/dev/null || true
