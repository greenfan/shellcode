#!/bin/sh

# 
# Based on original DNS check sequence from Heller's diagnose.sh
# Purpose-adapted by Shawn Bater
# 
# Last update 3 Dec 2013

# Begin DNS Smash

PASS=`echo -e '\E[0;32m'"\033[1mPASS\033[0m"`
INFO=`echo -e '\E[0;34m'"\033[1mINFO\033[0m"`
FAIL=`echo -e '\a\E[0;31m'"\033[1mFAIL\033[0m"`
WARN=`echo -e '\E[1;33m'"\033[1mWARN\033[0m"`

# Here we go!

echo "Smashing DNS..."
echo ""
DNS1=`echo "select value from config where variable = 'system_primary_dns_server';" | mysql config 2> /dev/null | grep -v value`
DNS2=`echo "select value from config where variable = 'system_secondary_dns_server';" | mysql config 2> /dev/null | grep -v value`
TESTLIST=( google.com facebook.com yahoo.com bing.com microsoft.com go.com aol.com cnn.com )
DNSIPS=( 208.67.222.222 208.67.220.220 4.2.2.2 4.2.2.3 8.8.8.8 8.8.4.4 66.93.87.2 199.2.252.10 )
RANDNS=$[($RANDOM % ${#DNSIPS[*]})]
AUTODNS=${DNSIPS[RANDNS]}
IFACELIST=( `ifconfig | grep -e br0 -e eth | awk '{print $1}' | xargs echo` )
if [ "$DNS1" != "" ]; then
    RANDOM=$[($RANDOM % ${#TESTLIST[*]})]
    DIG1=${TESTLIST[RANDOM]}
    LAG1=`dig @$DNS1 ${TESTLIST[${1}]} 2> /dev/null | grep "Query time:" | awk '{print $4}'`
    if [ "$LAG1" == "" ]; then
        echo "$FAIL Primary DNS: $DNS1 Non-Responsive. Trying an OpenDNS server..."
        LAG1A=`dig @$RANDNS ${TESTLIST[${1}]} 2> /dev/null | grep "Query time:" | awk '{print $4}'`
            echo "$INFO OpenDNS: $LAG1A msec" 
    elif [ "$LAG1" -gt "2500" ]; then
        echo "$FAIL Primary DNS: $DNS1 @ $LAG1 msec"
    elif [ "$LAG1" -gt "1000" ]; then
        echo "$WARN Primary DNS: $DNS1 @ $LAG1 msec"
    elif [ "$LAG1" -lt "1000" ]; then
        echo "$PASS Primary DNS: $DNS1 @ $LAG1 msec"
    fi
else
    echo "$WARN Primary DNS not configured... REALLY? Consider using $AUTODNS"
fi
if [ "$VERBOSE" = "true" ]; then
    INT=${#IFACELIST[@]}
    until [ $INT = 0 ]; do
        let INT-=1

        INTIP=`ifconfig | grep ${IFACELIST[INT]} -A6 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
        if [ "$INTIP" != "" ]; then
            echo "$INFO ${IFACELIST[INT]} Internal IP: $INTIP."
        fi
    done
fi
if [ "$DNS2" != "" ]; then
    RANDOM=$[($RANDOM % ${#TESTLIST[*]})]
    DIG2=${TESTLIST[RANDOM]}
    LAG2=`dig @$DNS2 ${TESTLIST[${1}]} 2> /dev/null | grep "Query time:" | awk '{print $4}'`
    if [ "$LAG2" == "" ]; then
        echo "$FAIL Secondary DNS: $DNS2 Non-Responsive, Configuring OpenDNS"
        DNS2A=`config_change system_secondary_dns_server $AUTODNS`
    elif [ "$LAG2" -gt "2500" ]; then
        echo "$FAIL Secondary DNS: $DNS2 @ $LAG2 msec. If this responds slow consistently, reconfigure."
    elif [ "$LAG2" -gt "1000" ]; then
        echo "$WARN Secondary DNS: $DNS2 @ $LAG2 msec"
    elif [ "$LAG2" -lt "1000" ]; then
        echo "$PASS Secondary DNS: $DNS2 @ $LAG2 msec"
    fi
else
    echo "$WARN None present, configuring OpenDNS"
        DNS2B=`config_change system_secondary_dns_server $AUTODNS`
fi
echo ""
echo "$INFO Pwning DNS Cache"
echo ""
    DNSCOFF=`config_change dns_cache No;/home/spyware/code/firmware/current/web/cgi-bin/index.cgi reload 2> /dev/null`
    echo "$PASS DNS Cache off and clearing..."
echo ""
    DNSCON=`config_change dns_cache Yes;/home/spyware/code/firmware/current/web/cgi-bin/index.cgi reload 2> /dev/null`
    echo "$PASS DNS Cache back on."
echo ""
    echo "$INFO DNS Cache service restarting..."
    DNSCACHE=`/etc/init.d/dnscache restart 2> /dev/null` 
    echo "$PASS Done."
echo ""
echo "$INFO Pwning DNS Watch"
    DNSWATCH=`/etc/init.d/dnswatch restart 2> /dev/null`
    echo "$PASS Done."
echo ""
echo "DNS Smash COMPLETE"
## End DNS SMASH
