#!/bin/bash
# /etc/init.d/dnetc
#
# Init script for distributed.net client
#
# chkconfig: 2345 55 25
# description: Distributed.net client
#
# processname: dnetc
#
# You need to specify the follow variables in /etc/sysconfig/dnetc:
#	DNETC_BIN	distributed.net executable(full path)
#	DNETC_USER	User to run as
#	DNETC_INI	Location of settings file
#

prog="dnetc"

[ -x $DNETC_BIN ] || exit 128

[ -f "/etc/sysconfig/${prog}" ] && . "/etc/sysconfig/${prog}" || exit 128

[ -f $DNETC_INI ] || exit 128

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
	daemon su $DNETC_USER --command=\"$DNETC_BIN -quiet -ini $DNETC_INI\"
	# The \" matter, they make su interpret the contents, rather than daemon
	RETVAL=$?
	echo
	return $RETVAL
}

stop()
{
	echo -n $"Shutting down $prog: "
	killproc $DNETC_BIN
	# NOTE: This currently kills ALL running DNETC instances on the machine
	# Please fix this, preferably by checking for pidfile.
	RETVAL=$?
	echo
	rm -f $pidfile
	return $RETVAL
}

reload()
{
	echo -n $"Reloading $prog configuration: "
	killproc $DNETC_BIN -HUP
	RETVAL=$?
	echo
	return $RETVAL
}
flush()
{
        echo -n "Flushing $prog buffers: "
        su $DNETC_USER --command="$DNETC_BIN -quiet -ini $DNETC_INI -update" 2>/dev/null >/dev/null && daemon /bin/true || daemon /bin/false
        echo ""
}
config()
{
        su $DNETC_USER --command="$DNETC_BIN -ini $DNETC_INI -config"
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
	flush)
		flush
		;;
	config)
		config
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
