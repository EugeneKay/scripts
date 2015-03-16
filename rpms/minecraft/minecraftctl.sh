#!/bin/bash

## Function Definitions
mc_readonly() {
	if mc_check
	then
		mc_command "say Setting server read-only..."
		mc_command save-off
		mc_command save-all
		sync
		sleep 10
	fi
}
mc_readwrite() {
	if mc_check
	then
		mc_command save-off
		mc_command "say Setting server read-write..."
	fi
}
mc_backup() {
	mc_readonly
	TIMESTAMP=$(date +%Y-%m-%d_%Hh%M)
	BACKUPFILE="$BACKUPDIR/$WORLD_$TIMESTAMP.tar"
	tar -h -C  "$DATADIR" -cf "$BACKUPFILE" "$WORLD"
	mc_readwrite
	xz -f $BACKUPFILE
}
mc_command() {
	if [ "$user" != "$MCUSER" ]
	then
		sudo -u $MCUSER screen -p 0 -S minecraft -X stuff "`printf \"${1}\r\"`"
	else
		screen -p 0 -S minecraft -X stuff "`printf \"${1}\r\"`"
	fi
}
mc_check() {
	if pgrep -u $MCUSER -f $MCJAR &>/dev/null
	then
		return 0
	else
		return 1
	fi
}
mc_start() {
	cd $DATADIR
	screen -dmS minecraft java -Xmx${MAXHEAP} -Xms${MINHEAP} -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=${THREADS} -XX:+AggressiveOpts -jar ${MCJAR} nogui
}
mc_stop() {
	mc_command save-all
	mc_command stop
}

## Runtime
# Load configuration
. /etc/sysconfig/minecraft || echo "Can't load minecraft settings"
# Executing user
user=$(whoami)

# Command to run
case "$1" in
backup)
	mc_backup
	;;
start)
	mc_check || mc_start
	;;
stop)
	mc_check && mc_stop
	;;
restart)
	mc_check && mc_stop && mc_start
	;;
command)	
	shift 1
	mc_command "${*}"
	;;
*)
	echo "Usage: $0 <backup|start|stop|restart|command> [arguments]"
	;;
esac

# Exit cleanly
exit 0
