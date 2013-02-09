#!/bin/bash
#
# Shell wrapper for the 'git' binary to hook in custom subcommands
#
# Copyright 2012 Eugene E. Kashpureff Jr (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

# Path to the `git` binary
GIT=$(which git)

# Sanity check
if [ ! -f ${GIT} ]
then
	echo "Error: git binary not found" >&2
	exit 255
fi

# Command to be executed
command=$1

# Remove command from $@ array
shift 1

# Check command against list of supported commands
case $command in
"config")
	if [ "$1" = "--global" ]
	then
		shift 1
		${GIT} config "--file=${HOME}/.gitconfig.local" "$@"
	else
		${GIT} config "$@"
	fi
	;;
"lol")
	$GIT log --graph --all --date-order --pretty=tformat:'%x09%cr%x09%C(yellow)%h%C(green)%d%Creset %s' "$@"
	;;
"uno")
	$GIT status --untracked=no "$@"
	;;
"unstage")
	$GIT reset HEAD "$@"
	;;
*)
	# Execute the git binary
	$GIT ${command} "$@"
	;;
esac

# Exit with git's exit code
exit $?
