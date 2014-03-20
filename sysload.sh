#!/bin/sh

# quick and dirty system load script

# Print date
DATE=`/bin/date 2> /dev/null`
echo >> /mail/tmp/sysload.txt
echo "$DATE"  >> /mail/tmp/sysload.txt

## CPU use
MAXUSED=`ps aux|awk 'NR > 0 { s +=$3 }; END {print s}'`
  echo "CPU use: $MAXUSED" >> /mail/tmp/sysload.txt
CPULA=`cat /proc/loadavg 2> /dev/null |awk '{print $1, $2, $3}'`
  echo "CPU avg 1/5/15: $CPULA" >> /mail/tmp/sysload.txt

# RAM use
free -t -m | grep "Mem" | awk '{ print "Total RAM: "$2 " MB";
print "RAM use: "$3" MB";
print "RAM free: "$4" MB";
}' >> /mail/tmp/sysload.txt

free -t -m | grep "Swap" | awk '{ print "Total swap: "$2 " MB";
print "Swap use: "$3" MB";
print "Swap free: "$4" MB";
}' >> /mail/tmp/sysload.txt

echo >> /mail/tmp/sysload.txt
