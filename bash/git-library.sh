#!/bin/bash
#
# git-library
#
# A git plugin which serves a similar purpose to submodule, but which saves a
# checkout of the included sub-repo into your worktree, rather than a reference
# to it.
#
# Copyright 2012 Eugene E. Kashpureff Jr (eugene@kashpureff.org)
# License: GNU General Public License, version 3+
#


##
## Documentation
##

## Installation
#
# To install git-library, copy this file to somewhere in your PATH. It is
# suggested to use ~/bin/. If this directory does not exist, create it. If it is
# not in your PATH you will need to add it. Consult your shell's documentation
# for the exact method to accomplish this, but the following works in bash:
#
#	$ PATH+=":~/bin"
#
# This file should be named "git-library" when installed, NOT "git-library.sh".
# If you do this wrong then git will be very angry with you and invoking
# `git library` will not work.

## Usage
#
# git-library currently does nothing. Attempting to run this script will print
# an error message to stderr and exit with an error code of 255.
#
#	git library add [-b <branch>] [-l|--local] [[-f|--force] [-c|--clean]
#		[-n|--no-commit] <repository> [<path>]
#	git library delete [-f|--force] [-n|--no-commit] [<path>]
#	git library update [-N|--no-fetch] [-f|--force] [-c|--clean] [-n|--no-commit] [<path>]
#	git library init [-N|--no-fetch] [-f|--force] [<path>]
#	git library set [-b <branch>] [<repository>] [<path>]
#	git library status [<path>]
#
# add
#	Add a new library to your repository at the given path. This will create
#	a clone of the given <repository> in .git/libraries/ using the <path>
#	given(or detected relative to the repo-root), then checkout a copy of
#	the repository to <path> in the work-tree.
#
#	You can use -b to chose a non-default branch to use, otherwise the
#	default branch of the source repository will be used(often "master").
#	This is extremely useful for projects which maintain a separate "stable"
#	branch from their in-development version.
#
#	This command will add a set of configuration entries to .gitlibraries in
#	your repository root, creating it if necessary, which point to the repo
#	and <path>. You can override this behaviour by using --local, which will
#	instead set these options in your repo's .git/config file. 
#
#	The <path> must be clean from any tracked or untracked files(preferably
#	a non-existant directory). If any files/directories are present, the
#	operation is aborted unless the --force option is specified. No merging
#	of conflicts is attempted. The --clean option can be used to delete any
#	files found in the new location, including removing untracked files from
#	the repository.
#
#	The default behaviour is to create a commit automatically of <path> and
#	any changes made to .gitlibraries. You can specify the --no-commit flag
#	to forego this commit. <path> and .gitlibraries will not be added to the
#	index; you must do this manually before commiting.
#
# delete
#	Delete the library at <path> or the current directory and remove the
#	reference to the library from the .gitlibraries or .git/config files.
#
# update
#	Update the library located at <path> or the current directory to the
#	latest commit on the branch it tracks. This must be done in a 'clean'
#	repo state - you an use 'git stash' to save your work before doing an
#	update.
#
#	New commits are normally fetched for the library. You can disable this
#	with the --no-fetch flag. Use of this is normally a no-op, because your
#	library should be at the tip commit already. If you have changed the
#	branch which the library is set to track then this will check it out in
#	place of the current one.
#
#	If changes have been made to files inside of the library they will be
#	unceremoniously and mercilessly blown away.
#
# init
#	Initialize & fetch the given(or all) libraries found in the library
#	specifications. This is used when setting up a repo with libraries that
#	you have just cloned, and wish to update libraries in. If you are simply
#	trying to get a copy of a repo then there is no need to run this command
#	as all files are already included as part of the parent repo's history.
#	
#	Specifying the --force flag will cause the library(ies) git repo to be
#	rm -rf'ed and a fresh init+fetch to be performed. The --no-fetch flag
#	will skip the fetch step in case you need to change the refspec or
#	otherwise modify the repo before doing a fetch.
#
# set
#	Change one or more properties of a library. 
#
#	The branch which is being tracked may be altered using --branch.
#
#	The URL of the repository which new commits are fetched from can be
#	edited by specifying a new remote spec.
#
# status
#	Print some basic information about the library located at <path> or the
#	current directory. If you are not inside of a library then all libraries
#	in the repository will be shown.
#

## Configuration
#
# There are currently no configuration options for this script. Why are you
# still reading this docs section? Come back when this actually does something.
#

## TODO
#
# 1) Make this script work
# 2) ???
# 3) Profit!
#


##
## Function Definitions
##
#
function gl_help() {
	## Show basic help for git-library
	echo "usage: git library <command> [<args>]

Valid subcommands:

	add	Add a new library to your repository
	delete	Delete an existing library
	help	Show this quick help listing
	update	Update a library to the newest commit
	init	Clone the upstream repos locally for updating, etc
	set	Change settings for a library
	status	Show information about libraries

See the git-library source for more detailed usage on specific commands."

}
function gl_repo_info() {
	## Load runtime info

	# worktree, if it exists
	gl_git_tree="$(git rev-parse --show-toplevel 2>/dev/null)"
	
	# Top of .git/ dir, if it exists
	gl_git_repo="$(git rev-parse --git-dir 2>/dev/null)"
	
	return 0;
}

function gl_add_lib() {
	## Add a library
	echo "Add a library"
}

function gl_update_lib() {
	## Update a library
	echo "Update a library"
}

function gl_init_lib() {
	## Init a library
	echo "Init a library"
}

##
## Runtime
##

# Load repo information
gl_repo_info

if [ -z "${gl_git_repo}" ]
then
	echo "Error: git repository not found."
	exit 255
fi

# Subcommand to be executed
subcommand="$1"

# Remove subcommand off begin of args array
shift 1

case "${subcommand}" in
"add")
	gl_add_lib
	gl_init_lib
	gl_update_lib
	exit 255
	;;
"delete")
	echo "Subcommand 'delete' has not been written yet."
	exit 255
	;;
"help")
	gl_help
	exit 0
	;;
"init")
	gl_init_lib
	gl_update_lib
	exit 255
	;;
"update")
	gl_update_lib
	exit 255
	;;
"status")
	echo "Subcommand 'status' has not been written yet."
	exit 255
	;;
*)
	gl_help
	exit 0
	;;
esac
	



# Exit cleanly
exit 0
