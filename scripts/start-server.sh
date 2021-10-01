#!/bin/bash
DL_URL="$(curl -s https://www.teamspeak.com/versions/server.json | jq -r .linux | grep teamspeak.com | tail -1 | cut -d '"' -f 4)"
LAT_V="$(curl -s https://www.teamspeak.com/versions/server.json | jq -r .linux | grep version | head -1 | cut -d '"' -f4)"
if [ -f ${DATA_DIR}/ts3server ]; then
	CUR_V="$(${DATA_DIR}/ts3server version | cut -d " " -f4)"
fi

echo "---Checking if TeamSpeak3 is installed---"
if [ ! -f ${DATA_DIR}/ts3server ]; then
	echo "---TeamSpeak3 not found, downloading...---"
    cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ts3server.tar.bz2 "$DL_URL" ; then
		echo "---Successfully downloaded TeamSpeak3!---"
	else
		echo "---Something went wrong, can't download TeamSpeak3, putting server in sleep mode---"
		sleep infinity
	fi
	tar -xvjf ${DATA_DIR}/ts3server.tar.bz2
	rm ${DATA_DIR}/ts3server.tar.bz2
	mv ${DATA_DIR}/teamspeak3-server_linux_amd64/* ${DATA_DIR}/
	rm -R ${DATA_DIR}/teamspeak3-server_linux_amd64
    CUR_V="$(${DATA_DIR}/ts3server version | cut -d " " -f4)"
else
	echo "---TeamSpeak3 found---"
fi

if [ ! -z "$LAT_V" ]; then
	echo "---Version Check---"
	if [ "$LAT_V" != "$CUR_V" ]; then
		echo "---Version missmatch v$CUR_V installed, installing v$LAT_V---"
		if [ ! -d /tmp/TS3 ]; then
			mkdir -p /tmp/TS3
		fi
		if [ -f ${DATA_DIR}/licensekey.dat ]; then
			cp ${DATA_DIR}/licensekey.dat /tmp/TS3
		fi
		cp ${DATA_DIR}/query_ip_blacklist.txt /tmp/TS3
		cp ${DATA_DIR}/query_ip_whitelist.txt /tmp/TS3
		if [ -f ${DATA_DIR}/serverkey.dat ]; then
			cp ${DATA_DIR}/serverkey.dat /tmp/TS3
		fi
		cp ${DATA_DIR}/ts3server.ini /tmp/TS3
		if [ -f ${DATA_DIR}/ts3db_mariadb.ini ]; then
			cp ${DATA_DIR}/ts3db_mariadb.ini /tmp/TS3
		fi
		if [ -f ${DATA_DIR}/ts3server.sqlitedb ]; then
			cp ${DATA_DIR}/ts3server.sqlitedb /tmp/TS3
		fi
		cp -R ${DATA_DIR}/files /tmp/TS3
		cp -R ${DATA_DIR}/logs /tmp/TS3
		rm -R ${DATA_DIR}/*
		cd ${DATA_DIR}
		if wget -q -nc --show-progress --progress=bar:force:noscroll -O ts3server.tar.bz2 "$DL_URL" ; then
			echo "---Successfully downloaded TeamSpeak3!---"
		else
			echo "---Something went wrong, can't download TeamSpeak3, putting server in sleep mode---"
			sleep infinity
		fi
		tar -xvjf ${DATA_DIR}/ts3server.tar.bz2
		rm ${DATA_DIR}/ts3server.tar.bz2
		mv ${DATA_DIR}/teamspeak3-server_linux_amd64/* ${DATA_DIR}/
		rm -R ${DATA_DIR}/teamspeak3-server_linux_amd64
		cp -R /tmp/TS3/* ${DATA_DIR}
		rm -R /tmp/TS3
		CUR_V="$(${DATA_DIR}/ts3server version | cut -d " " -f4)"
	elif [ "${JENKINS_V}" == "$CUR_V" ]; then
		echo "---Server versions match! Installed: v$CUR_V | Preferred: v${JENKINS_V}---"
	fi
else
	echo "---Couldn't get latest version number, Version check not possible, continuing---"
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

if [ "${ENABLE_TSDNS}" == "true" ]; then
	echo "---Starting TSDNS---"
	cd ${DATA_DIR}/tsdns
	${DATA_DIR}/tsdns/tsdnsserver &
fi

echo "---Starting TeamSpeak3---"
cd ${DATA_DIR}
${DATA_DIR}/ts3server ${EXTRA_START_PARAMS}