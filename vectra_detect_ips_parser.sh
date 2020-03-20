#!/bin/bash
hostcount=0
for i in `cat $1`
        do  count=$(cat $2 | sort | grep "$i" | wc -l)
#       printf '%12s0/24 %-12s  %-10s\n' "$i" ""  "$count"
        echo ""$i"0,"$count""
        hostcount=$( expr $hostcount + $count )
        done

echo "Total Active Hosts: $hostcount"
