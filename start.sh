#!/bin/bash
# Cloudron entrypoint for Prosody. Invoked via CMD (NOT ENTRYPOINT, which breaks
# Cloudron debug mode). Runs as root: wires addon env + certs, fixes ownership,
# then drops privileges to the `prosody` user with gosu.
set -e

echo "==> prosody-cloudron starting"

# 1. Map Cloudron addon env -> Prosody env (fresh every boot; never cached).
source /app/code/cloudron-env.bash

# 2. Lay out TLS certs from the Cloudron tls addon.
source /app/code/cloudron-cert-setup.bash

# 3. Ensure writable state dirs exist and are owned by the prosody user.
mkdir -p /app/data/certs /run/prosody
chown -R prosody:prosody /app/data /run/prosody

echo "==> Prosody $(dpkg-query -W -f='${Version}' prosody 2>/dev/null) | DOMAIN=${DOMAIN}"

# 4. Non-fatal config sanity check (logged, never blocks startup).
gosu prosody:prosody prosodyctl check config 2>&1 | sed 's/^/[check] /' || \
	echo "[check] prosodyctl reported issues (continuing)"

# 5. Run Prosody in the foreground as the unprivileged prosody user.
echo "==> launching prosody"
exec gosu prosody:prosody prosody -F
