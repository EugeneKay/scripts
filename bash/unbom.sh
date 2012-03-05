#!/bin/bash
#
# Unbom
#
# Remove Byte-Order-Mark from fies
#
# Copyright 2012 Eugene E. Kashpureff (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

for F in $1
do
	if [[ -f $F && `head -c 3 $F` == $'\xef\xbb\xbf' ]]; then
		# file exists and has UTF-8 BOM
		mv $F $F.bak
		tail -c +4 $F.bombak > $F
		echo "removed BOM from $F"
	fi
done
