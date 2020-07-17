# TeamSpeak3 Server in Docker optimized for Unraid
This container will download and install TeamSpeak3 Server.

FIRST RUN: at first run the token will be displayed in the log (also don't forget to accept the license in the template).

UPDATE NOTICE: The container will check on every start/restart if there is a newer version of the server available and install it.



## Env params
| Name | Value | Example |
| --- | --- | --- |
| TS3SERVER_LICENSE | Set to 'accept' if you agree the license agreement (you can find the license after the first start of the container in the main directory of the container or you can set it also to 'view' to read it in the terminal - without quotes). | accept |
| EXTRA_START_PARAMS | Only if needed (eg: 'inifile=${DATA_DIR}/ts3server.ini') | *empty* |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name TeamSpeak3-Server -d \
	-p 9987:9987/udp \
   	-p 10011:10011 \
   	-p 30033:30033 \
	--env 'TS3SERVER_LICENSE=accept' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /mnt/cache/appdata/teamspeak3:/teamspeak \
	ich777/teamspeak
```


This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/