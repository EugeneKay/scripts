#!/bin/bash
#
# Init script for ZNC Server
#
# chkconfig: 2345 55 25
# description: ZNC Server
#
# processname: znc
#
# You will need to specify ZNC_USER and ZNC_DIR in /etc/sysconfig/znc
#

prog=znc
ZNC_BIN=/usr/bin/znc
ZNC_CONFIG=/etc/sysconfig/$prog

[ -x $ZNC_BIN ] || exit 0

[ -f $ZNC_CONFIG ] && . "$ZNC_CONFIG"

#[ id $ZNC_USER ] || exit 0

[ -d $ZNC_DIR ] || exit 0

# Source function library
. /etc/rc.d/init.d/functions

RETVAL=0

start()
{
	echo -n $"Starting $prog: "
	pids=`pidof dnetc | tr " " "\n"`
	for pid in $pids
	do
		if [ -e /proc/$pid ];
		then
			runs=1
		fi
	done

	if [ $runs ]; then
		echo -n $"already running.";
		success "$prog is already running.";
		echo
		return 0
	fi
	daemon su $ZNC_USER --command=\"$ZNC_BIN -d $ZNC_DIR\"
	# The \" matter, they make su interpret the contents, rather than daemon
	RETVAL=$?
	echo
	return $RETVAL
}

stop()
{
	echo -n $"Shutting down $prog: "
	killproc $ZNC_BIN
	# NOTE: This currently kills ALL running ZNC instances on the machine
	# Please fix this, preferably by checking for pidfile.
	RETVAL=$?
	echo
	rm -f $pidfile
	return $RETVAL
}

reload()
{
	echo -n $"Reloading $prog configuration: "
	killproc $ZNC_BIN -HUP
	RETVAL=$?
	echo
	return $RETVAL
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	reload)
		reload
		;;
	restart)
		stop
		start
		;;
	try-restart)
		if [ -f $pidfile ]; then
			stop
			start
		fi
		;;
	force-reload)
		reload || (stop; start)
		;;
	status)
		status $prog
		RETVAL=$?
		;;
	*)
		echo $"Usage: $0 {start|stop|reload|force-reload|restart|try-restart|status}"
		RETVAL=3
esac

exit $RETVAL


