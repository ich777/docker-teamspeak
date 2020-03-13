#!/bin/bash
DL_URL="$(curl -s https://www.teamspeak.com/versions/server.json | jq -r .linux | grep teamspeak.com | tail -1 | cut -d '"' -f 4)"

echo "---Preparing server---"
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Sleep zZz---"
sleep infinity