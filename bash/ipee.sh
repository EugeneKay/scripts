#!/bin/bash
#
# I Pee
#
# Adds a /116 worth of IPv6 addresses(eg, from Linode)
#
# Usage: ./ip.sh 2600:3c01::XXXX:Y eth0 -y
#
# Copyright(C) 2016 Eugene E. Kashpureff Jr
# License granted under WTFPL, version 2.
#

prefix=${1}
device=${2}
yes=${3}

# Tight loops, yo
for hex1 in 0 1 2 3 4 5 6 7 8 9 a b c d e f
do
	for hex2 in 0 1 2 3 4 5 6 7 8 9 a b c d e f
	do
		# Where did you come from, where did you go, hex-eyed Joe?
		echo -n "${hex1}${hex2}"
		for hex3 in 0 1 2 3 4 5 6 7 8 9 a b c d e f
		do
			# HELLO YES I PEE
			if [ -n "${yes}" ]
			then
				/sbin/ip -6 addr add ${prefix}${hex1}${hex2}${hex3}/64 dev ${device}
			fi

			# Progress
			echo -n "."

			# Chill for a sec
			sleep 1
		done

		# I can haz newline
		echo ""
	done
done
