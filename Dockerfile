# Prosody XMPP for Cloudron — Prosody 13.0 from the official apt repo.
# Forked from github.com/DerekJarvis/cloudron-prosody (itself a fork of
# SaraSmiseth/prosody). Reworked for: Prosody 13.0 (apt, not source build),
# Debian FHS paths, Lua 5.4, CMD-only (no ENTRYPOINT), simple-JID + Cloudron
# tls/ldap/turn addons.

FROM docker.io/cloudron/base:5.0.0@sha256:04fd70dbd8ad6149c19de39e35718e024417c3e01dc9c6637eaf4a41ec4e596c

# Prosody STABLE point release, pinned exactly. The `prosody` package is the
# stable line (currently 13.0.6); the `prosody-13.0` package is *nightly* builds
# of the 13.0 branch, which we deliberately avoid. Bump this pin to move versions.
ARG PROSODY_VERSION=13.0.6-1~noble1
# Distro codename of the base image above (cloudron/base:5.0.0 = Ubuntu noble).
ARG DISTRO=noble

LABEL org.opencontainers.image.title="prosody-cloudron"
LABEL org.opencontainers.image.description="Prosody 13.0 XMPP server packaged for Cloudron (LDAP, TURN, file upload, MUC)."
LABEL org.opencontainers.image.url="https://prosody.im/"

# --- Prosody 13.0 + runtime Lua libraries from the official Prosody apt repo ---
# The .sources file is deb822 with the signing key inlined (apt >= 2.4).
RUN wget -O /etc/apt/sources.list.d/prosody.sources \
        "https://prosody.im/downloads/repos/${DISTRO}/prosody.sources" \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        prosody=${PROSODY_VERSION} \
        lua-sec \
        lua-expat \
        lua-socket \
        lua-filesystem \
        lua-dbi-sqlite3 \
        lua-ldap \
        lua-unbound \
        lua-readline \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && dpkg-query -W -f='Installed ${Package} ${Version}\n' prosody

# --- Community modules not bundled in Prosody core ---
# (smacks, turn_external, mod_auth_ldap, server_contact_info, csi_simple,
#  carbons, mam, muc_mam, cloud_notify, vcard_muc are all CORE in 13.0 and are
#  NOT copied here — copying cloud_notify/vcard_muc conflicts with the built-ins.)
RUN mkdir -p /usr/local/lib/prosody/custom-modules /usr/src/prosody-modules \
 && wget -O /tmp/prosody-modules.tar.gz https://hg.prosody.im/prosody-modules/archive/tip.tar.gz \
 && tar -xzf /tmp/prosody-modules.tar.gz -C /usr/src/prosody-modules --strip-components=1 \
 && for m in host_status_check http_host_status_check e2e_policy \
             filter_chatstates throttle_presence ; do \
        cp -r "/usr/src/prosody-modules/mod_${m}" /usr/local/lib/prosody/custom-modules/ ; \
    done \
 && rm -rf /usr/src/prosody-modules /tmp/prosody-modules.tar.gz

# Writable runtime dir (Cloudron: only /app/data, /run, /tmp are writable).
RUN mkdir -p /run/prosody && chown prosody:prosody /run/prosody

# https://github.com/prosody/prosody-docker/issues/25 — flush logs immediately.
ENV __FLUSH_LOG=yes

# Static config (Debian path; /etc/prosody is read-only at runtime — fine).
COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua
COPY conf.d/ /etc/prosody/conf.d/

# App code (entrypoint logic + Cloudron env/cert wiring).
COPY start.sh cloudron-env.bash cloudron-cert-setup.bash /app/code/
COPY prosody-check.bash prosody-shell.bash /usr/local/bin/
RUN chmod +x /app/code/start.sh /app/code/*.bash /usr/local/bin/prosody-*.bash

# 5222 c2s (STARTTLS) · 5223 c2s direct-TLS · 5269 s2s · 5280 http
EXPOSE 5222 5223 5269 5280

# CMD only — never ENTRYPOINT (ENTRYPOINT breaks Cloudron debug mode).
CMD ["/app/code/start.sh"]
