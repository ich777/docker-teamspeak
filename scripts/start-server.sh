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
echo "---Checking if 'ts3server.ini' is present---"
if [ ! -f ${DATA_DIR}/ts3server.ini ]; then
	echo "---'ts3server.ini' not found downloading...---"
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ts3server.ini https://raw.githubusercontent.com/ich777/docker-teamspeak/master/config/ts3server.ini ; then
		echo "---Successfully downloaded 'ts3server.ini'!---"
	else
		echo "---Something went wrong, can't download 'ts3server.ini', putting server in sleep mode---"
		sleep infinity
	fi
else
	echo "---'ts3server.ini' found---"
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Checking License---"
if [ "${TS3SERVER_LICENSE}" != "accept" ]; then
	echo "---License not accepted---"
	echo 'Please set the environment variable TS3SERVER_LICENSE to "accept" in order to accept the license agreement.
Alternatively, create a file named ".ts3server_license_accepted" in the working directory or start the server with the command line parameter "license_accepted=1".
To view the license agreement set TS3SERVER_LICENSE to "view" in order to print the license to the console.
Alternatively view the file "LICENSE" in your favorite text viewer yourself.'
	echo "---Putting server into sleep mode---"
	sleep infinity
fi

echo "---Starting TeamSpeak3---"
cd ${DATA_DIR}
${DATA_DIR}/ts3server