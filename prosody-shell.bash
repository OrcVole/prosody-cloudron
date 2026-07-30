#!/bin/bash
# Open the Prosody admin shell inside the container:
#   cloudron exec --app xmpp.example.com -- /usr/local/bin/prosody-shell.bash
set -e
source /app/code/cloudron-env.bash
exec gosu prosody:prosody prosodyctl shell
