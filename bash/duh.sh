#!/bin/sh
#
# Duh
#
# Runs du with a few handy flags and pipes it through some 
if [ $1 ]; then
        DIR=$1
else
        DIR=`pwd`
fi

##
## Functions
##

## Duh
#
#
#
function duh() {
	echo "Directory Sizes for ${DIR}:"
	echo $(du -h --max-depth=1 "$DIR" 2> /dev/null | sort -k 2)
}

duh | less -FSRX

exit $?
