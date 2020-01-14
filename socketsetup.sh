#!/bin/bash
#to use this script properly, schedule it in cron, and setup ssh public key authentication
#count number of ssh reverse tunnels running
pids=$(pgrep ssh -a | grep R | awk '{print $1}')
nums=$(pgrep ssh -a | grep R | awk '{print $1}'| wc -w)
if [ "$nums" -ne 0 ]
        then
                if [ "$nums" -ge "2" ]
                then kill -9 "$pids"
                elif [ "$nums" -eq "1" ]
                then exit 0
                fi
fi
screen -dm ssh -o ServerAliveInterval=60 -R 7001:localhost:22 -p 1234 jumpacct@yourbastionhost.com
