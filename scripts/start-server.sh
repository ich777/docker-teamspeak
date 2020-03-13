#!/bin/bash
DL_URL="$(curl -s https://www.teamspeak.com/versions/server.json | jq -r .linux | grep teamspeak.com | tail -1 | cut -d '"' -f 4)"

echo "---Checking if TeamSpeak3 is installed---"
if [ ! -f ${DATA_DIR}/ts3server ]; then
	echo "---TeamSpeak3 not found, downloading...---"
    cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ts3server.tar.bz2 "$DL_URL"  ; then
		echo "---Successfully downloaded TeamSpeak3!---"
	else
		echo "---Something went wrong, can't download TeamSpeak3, putting server in sleep mode---"
		sleep infinity
	fi
	tar -xvjf ${DATA_DIR}/ts3server.tar.bz2
	rm ${DATA_DIR}/ts3server.tar.bz2
	mv ${DATA_DIR}/teamspeak3-server_linux_amd64/* ${DATA_DIR}/
	rm -R ${DATA_DIR}/teamspeak3-server_linux_amd64
else
	echo "---TeamSpeak3 found---"
fi

echo "---Preparing server---"
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Sleep zZz---"
sleep infinity

echo "---Starting TeamSpeak3---"
cd ${DATA_DIR}
${DATA_DIR}/ts3server