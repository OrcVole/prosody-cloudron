#!/bin/bash
# Run Prosody's built-in config/cert/DNS checks inside the container:
#   cloudron exec --app xmpp.example.com -- /usr/local/bin/prosody-check.bash
set -e
source /app/code/cloudron-env.bash
exec gosu prosody:prosody prosodyctl check
