#!/bin/bash
##
## DNS Pre-Commit Hook
##
#
# Increments serial number automatically before commit. Working copy must be the
# same as the staged copy(this will be fixed eventually)
#
# Copyright 2011 K and H Research Company (support@khresear.ch)
# License: WTFPL, any version or GNU General Public License, version 3+
#

# Temporary directory name
TEMP=".tmp"
# New serial number, usually date-based
SERIAL=$(date +"%s")
echo "New serial: ${SERIAL}"

# Create temp dir & script lock
if mkdir "${TEMP}"
then
	echo $$ > "${TEMP}/.pid"
else
	echo "Error: Unable to acquire script lock"
	exit 1
fi

# Remove lock on exit, even if abnormal
trap "rm -rf ${TEMP}; exit" INT TERM EXIT

# Get list of changed files
files=$(git diff-index --name-status --cached HEAD | grep -v ^D | cut -c3-)

# Loop through each file
for file in ${files}
do
	
	# Check that file really is a file, not a symlink or such
	if [ ! -f $file ]
	then
		echo "Error: $file is not a file?"
		exit 1
	fi
	
	# Grep out the old serial number. This regex should be tightened!
	oldser=($(egrep -ho "[0-9]{10}" $file))
	
	# Really ugly and stupid hack to deal with grep <v2.6 limiting our regex
	oldser=${oldser[0]}
	
	# Check that we actually got a valid serial back
	if [[ $oldser != [0-9]* ]]
	then
		continue
	fi
	
	# Check that the new serial is higher than the old one
	if [ $oldser -gt $SERIAL ]
	then
		echo "Error: Old serial from $file is higher than $SERIAL."
		echo "Check your system's clock or fix the serial manually."
		exit 1
	fi
	
	# Increment the serial
	sed -i "s/$oldser/$SERIAL/g" $file
	
	# Add the new file to the index
	git add ${file}
	
done

# Remove script lock
rm ${TEMP} -rf

# Clean up variables
unset SERIAL TEMP files

# Exit cleanly
exit 0
