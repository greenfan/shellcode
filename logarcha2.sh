#!/bin/bash
#
# This file is under source code control.  Do not edit it directly,
# check a copy out using the appropriate SCM. See the `Source' line
# to find the archive.
#
# Shell script to gather syslog data and syslog streams, then generate encrypted tarball.
#
# Cron script to run as frequently as your logrotate daemon
#
# Revision 1.1  2018/1/23 17:30:41  rnd
# Initial revision
#

# Boilerplate definitions for all scripts.

set -u		    # Undefined variables are latent bugs
TOOL=${0//*\//}     # Get the simple name of this script
TOOL_ARGS="$@" # Save args in case other things call 'set'

seconds_from_epoch="$(date +%s)"
dmonth="$(date +%B)"
dday="$(date +%d)"
dyear="$(date +%Y)"
ddate="$dmonth-$dday-$dyear"

#define global variables
archive_dir="/var/archive/data"
log_dir="/var/log/"



#define logs by relative path inside /var/log/
lognames="cisco.log syslog.log"


datarchive="$archive_dir/$ddate/"
#
# Verify that we can access the data archive area
if ! cd /var/archive/data ; then
    echo >&2 "${TOOL}: Cannot access the machine directory."
    exit 1
fi

mkdir "$datarchive"

if ! cd "$datarchive" ; then
    echo >&2 "${TOOL}: Cannot access the latest archive directory."
    exit 1
fi



for i in $( echo "$lognames") ;
	do
	
		tar -jcvf "$datarchive$i.tar.bz2" "$log_dir$i"	
	done 
