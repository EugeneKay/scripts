#!/bin/bash
#
# Shell wrapper for the 'git' binary to hook in custom subcommands
#
# Copyright 2012 Eugene E. Kashpureff Jr (eugene@kashpureff.org)
# License: WTFPL, any version or GNU General Public License, version 3+
#

# Check against list of custom subcommands
case $1 in
"lol")
	git log --graph --all --pretty=tformat:'%x09%cr%x09%C(yellow)%h%C(green)%d%Creset %s' ${@:2}
	;;
"uno")
	git status --untracked=no
	;;
*)
	# Execute the git binary
	/usr/bin/git $*
	;;
esac

# Exit with git's exit code
exit $?
