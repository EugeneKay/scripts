#!/bin/bash
#
# git-last
#
# Shows the most recent commit for each file/folder in the current directory,
# similar to GitHub's code-browser. Accepts a list of directories to be
# examined
#

# Ensure we're in a git worktree
if [ "$(git rev-parse --is-inside-work-tree)" != "true" ]
then
	exit 1
fi

# Files/directories to list info for
names=$(find $* -mindepth 1 -maxdepth 1 -type d | sort | sed 's/$/\//g' && find $* -mindepth 1 -maxdepth 1 -type f | sort)

# How far to indent the commit info
length=14

# Find length of longest filename
for name in ${names}
do
	if [ ${#name} -gt $length ]
	then
		length=${#name}
	fi
done

# Pad length by 2 to allow for trailing colon
length=$(( $length + 2 ))

# Loop over each dir/file
for name in ${names}
do
	# Skip .git dirs(TODO: make this work better)
	if [ "${name}" == "./.git/" ]
	then	
		continue
	fi
	
	# Show path/filename, padded
	echo -ne ${name}":" | sed 's/\.\///g' | sed -e :a -e "s/^.\{1,${length}\}$/& /;ta"
	
	# Show last commit date, padded
	echo "$(git-log -1 --pretty=tformat:'%cr%x09%h %s [%cn]' -- ${name})"
done

# Exit cleanly
exit 0
