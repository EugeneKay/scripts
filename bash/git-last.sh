#!/bin/bash
#
# git-last
#
# Shows the most recent commit for each file/folder in the current directory,
# similar to GitHub's code-browser. Accepts a list of files/directories to be
# examined
#

# Ensure we're in a git worktree
if [ "$(git rev-parse --is-inside-work-tree)" != "true" ]
then
	exit 1
fi

# List files to show info for
for name in $(find -maxdepth 1 $* | sort )
do
	# Skip .git dirs(TODO: make this work better)
	if [ "${name}" == "./.git" ]
	then	
		continue
	fi
	echo -ne ${name}":" | sed 's/\.\///g' | sed -e :a -e 's/^.\{1,16\}$/& /;ta'
	echo $(git-log -1 --oneline -- ${name})
done;
