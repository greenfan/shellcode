#!/bin/bash
  
hosts=detect_ips.csv
subnets=/tmp/detected_subnets.txt
uniq_nets=/tmp/uniq_subnets.txt
for i in `cat $hosts`
        do
#strip last octet, and escape the period with a trailing backslash
        subnet=$( echo "$i" | sed 's/\.[0-9]*$/\\./')
        echo "$subnet" >> /tmp/detected_subnets.txt
        done

cat "$subnets" | sort | uniq > "$uniq_nets"

for i in `cat $uniq_nets`
        do
#strip off the trailing backslash
        subnet=$(echo "$i" | sed 's/\\/0/g')

#parse through the entire hosts file, count how many hosts are in each unique subnet, and output to a csv
        sub_host_count=$(cat "$hosts" | grep "$i" | wc -l)
        echo ""$subnet","$sub_host_count""

done

#compare yesterday's CSV with todays.
#output all new hosts.
#output all removed hosts.


#automate vectra detect_ips.csv Importation!!!

#cleanup tmp #files
#rm -rf "$hosts" "$subnets" "$uniq_nets
