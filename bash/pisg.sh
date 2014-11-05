#!/bin/bash
# bash/pisg
# eugenekay/scripts
#
# Shitty wrapper around pisg to handle stdout/err and logging.
#
# License: WTFPLv2+
#

LOGGER=$(which logger)
PERL=$(which perl)

${LOGGER} "Beginning pisg run..."

${PERL} -w ${HOME}/.pisg/pisg-0.73/pisg -co ${HOME}/.pisg.cfg &>/dev/null
return=$?
if [ "${return}" -ne "0" ]
then
	${LOGGER} "pisg run encountered an error. Return code was ${return}"
else
	${LOGGER} "pisg run completed successfully."
fi
exit 0

