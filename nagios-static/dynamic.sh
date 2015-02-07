#!/bin/bash
# nagios-static/dynamic.sh
# EugeneKay/scripts
#
# Generate dynamic files from nagios CGI
#

CURL="/usr/bin/curl --stderr /dev/null"
USER="--user username:password"
GM="/usr/bin/gm"
NAGIOS_CGI="http://status.example.com//nagios/cgi-bin"
GRAPH_CGI="http://status.example.com/nagiosgraph/cgi-bin"
PERIODS=("5400" "118800" "3024000" "34560000")
DYNAMIC="/data/html/kashpureff/status.example.com/dynamic"

# Build status map
${CURL} ${USER} "${NAGIOS_CGI}/statusmap.cgi?createimage" | $GM convert -trim - ${DYNAMIC}/map.png

# Build status page
${CURL} ${USER} "${NAGIOS_CGI}/status.cgi" | sed -f status.sed | sed "s/<a href='status.cgi.*\/a>//g" > ${DYNAMIC}/status.html

# Get list of hosts
hosts=$(${CURL} ${USER} "${NAGIOS_CGI}/status.cgi?style=hostdetail" | grep showhost\.cgi | sed -r "s/.*host=(.*)' TARGET.*/\1/g")

# Cycle through hosts
for host in ${hosts}
do
	# Create host page
	${CURL} ${USER} "${GRAPH_CGI}/showhost.cgi?host=${host}&period=hour,day,month" | sed -f graph.sed > ${DYNAMIC}/graph-${host}.html

	# Get list of services
	services=$(${CURL} ${USER} "${GRAPH_CGI}/showhost.cgi?host=${host}&period=hour" | grep graph_title | sed -r "s/.*service=([a-zA-Z0-9\-]*)&db=.*/\1/g")

	# Cycle through services
	for service in ${services}
	do
		# Cycle through periods
		for period in ${PERIODS[@]}
		do
			# Grab graph
			${CURL} ${USER} "${GRAPH_CGI}/showgraph.cgi?host=${host}&service=${service}&rrdopts=%20-snow-${period}%2-enow-0" > ${DYNAMIC}/graph-${host}-${service}-${period}.png
		done
	done
done
