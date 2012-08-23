#!/bin/bash
#
# git-library
#
# 
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
# git-library currently does nothing. Attempting to run this scriptwill print
# an error message to stdout and exit with an error code of 255.
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
# There are none. Go away.
#


##
## Runtime
##

# Show an error message
echo "This currently does nothing. Why are you using it?" 1>&2

# Exit nastily
exit 255
