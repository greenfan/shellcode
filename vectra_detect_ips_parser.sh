#!/bin/bash
hosts=detect_ips.csv
date=$( date +%m-%d-%Y)
subnets=/tmp/detected_subnets.txt
uniq_nets=/tmp/uniq_subnets.txt
for i in `cat $hosts`
        do
#strip last octet, and escape the period with a trailing backslash
        subnet=$( echo "$i" | sed 's/\.[0-9]*$/\\./')
        echo "$subnet" >> /tmp/detected_subnets.txt
        done

cat "$subnets" | sort | uniq > "$uniq_nets"
#check to see if this has already run today
if [ -f "vectrasubnetstats_"$date".csv" ]; then echo "Exiting with error, today's file exists." && exit 1
fi
for i in `cat $uniq_nets`
        do
#strip off the trailing backslash
        subnet=$(echo "$i" | sed 's/\\/.0/g')

#parse through the entire hosts file, count how many hosts are in each unique subnet, and output to a csv
        sub_host_count=$(cat "$hosts" | grep "$i" | wc -l)
        echo ""$subnet","$sub_host_count"" >> "vectrasubnetstats_"$date".csv"
done     
#compare yesterday's CSV with todays.
cat detect_ips.csv | sort 1> todayshosts.csv
cat old_detect_ips.csv | sort 1> yesterdayshosts.csv
    
echo "new hosts" 
diff todayshosts.csv yesterdayshosts.csv | grep ^"<"
echo "hosts no longer present"
diff todayshosts.csv yesterdayshosts.csv | grep ^">"
    
cp todayshosts.csv "hosts_"$date"".csv
rm -rf todayshosts.csv yesterdayshosts.csv

#automate vectra detect_ips.csv Importation!!!

#cleanup tmp #files
#rm -rf "$hosts" "$subnets" "$uniq_nets"
