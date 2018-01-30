#!/bin/bash


COIN="bgold"
COINLONG="bitcoingold"

COIN_DIR="$HOME/.${COINLONG}"
COIN_CONF="$COIN_DIR/${COIN}.conf"
USER="$COIN"
SUDO="sudo -iu ${COIN}"

usage() {
	[ -z "$1" ] || echo "$1"
	echo "Usage: docker run -v /path/to/${COIN}-config-dir:$COIN_DIR [-d|-it] <dockerimage>"
	echo "If you specify a non-existing <${COIN}-config-dir> it will be created and populated."
	exit -1
}

die() {
	echo "Error: $1"
	exit -1
}

start_coind() {
	PIDOF="$(pidof $COIN_DIR/${COIN}d)" 
	PIDFILE="$(cat $COIN_DIR/${COIN}d.pid 2>/dev/null)" 
	[ ! -z "$PIDOF" ] && return 0
	[ -z "$PIDOF" ] && [ ! -z "$PIDFILE" ] && die "PID file exists, might belong to an old process or you are sharing your $COIN config dir which is not recommended. Fix it. Aborting." 

	$SUDO ${COIN}d -printtoconsole
}

feedback_loop() {
	echo "Started "
	while true; do echo -n .;sleep 20;done
	echo "Ending."
}
			
[[ "$1" =~ "(-h|--help|)$" ]] && usage

[ ! -d "$COIN_DIR" ] && usage "Error: No coin conf/data dir found, make sure to mount a directory on $COIN_DIR"

chown -R $COIN $COIN_DIR

[ ! -r "$COIN_CONF" ] && {
	$SUDO ${COIN}d -daemon 2>&1|grep '^rpc' >> $COIN_CONF
	$SUDO cat >> $COIN_CONF << "EOF"
pcallowip=127.0.0.1
staking=1
server=1
listen=1
daemon=1
logtimestamps=1
maxconnections=256
#masternode=1
#masternodeprivkey=
EOF
} 

[ -r "$COIN_CONF" ] || die "No config file found, did you or some process move it? Rerun me."
start_coind
feedback_loop
