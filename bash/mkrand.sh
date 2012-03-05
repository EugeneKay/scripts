#!/bin/bash
#
# mkrand
# 
# Generate a set of random files from /dev/urandom. Useful for TrueCrypt or
# anywhere you need a good bit of pseudorandom data and piping it in from /dev
# won't work.
#
# Copyright 2012 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

count=1

while [ ${count} -lt 101 ]
do
        dd if=/dev/urandom of=`printf "%02d" ${count}` bs=1K count=1024
        count=$[$count+1]
done
