#!/bin/bash
#
# Env Setup
#
# Environment setup-er script, for quickly loading a standard shell environment
# onto new systems. Designed to be placed at an easily-remembered(and typed)
# URL. Example script exists as http://eugenekay.com/env, and is invoked via:
#
# $ curl eugenekay.com/env | bash
#
# Thus downloading & invoking this script, which chainloads all $files located
# inside http://eugenekay.com/bash/. SSH authorized_keys are loaded in a "smart"
# manner, including support for SELinux-aware systems which would otherwise
# throw permissions errors.
#
# NOTE: DO NOT RUN WITHOUT MODIFICATION, unless you want to give me a shell on
# your machine.
#

## Settings
# Source server
server="http://eugenekay.com/bash"
# Places to create
dirs=".ssh"
# Files to grab
files=".bashrc .screenrc .vimrc .ssh/authorized_keys"

# Sanity checks
if [ ! -d ${HOME} ] || [ ! -w ${HOME} ]
then
	echo "Homedir(${HOME}) does not exist or not writable"
	exit 255
fi

# Create places
for dir in ${dirs}
do
	mkdir -p "${dir}"
done

# Grab files
for file in ${files}
do
	curl "${server}/${file}" 2>/dev/null > ${HOME}/${file}
done

# Check for SELinux
if [ "$(/usr/sbin/getenforce)" == "Enforcing" ]
then
	/sbin/restorecon ${HOME} -r
fi

# Strip permissions
chmod go-rwx ${HOME} -R
chmod u-x ${HOME}/.ssh/*
