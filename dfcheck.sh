#!/bin/bash
# FilesystemsComparison Rdwyer

if ls | grep "old.df" > /dev/null
then 
	echo "old filesystem output exists."
else 
	echo "no df output exists, created one" `df -h > old.df` 
fi
#Create recent df output
`df -h > new.df`
less old.df | awk ' { if (NR > 1 ) printf  ( " %2s %12s \n", $5, $6 ) }' > old2.df
less new.df | awk ' { if (NR > 1 ) printf ( " %2s %12s \n", $5, $6 ) }' > new2.df 
`paste old2.df new2.df | tr -d '%' > filesystems.txt`
#Paritions that have been reduced in size
#echo "" ; echo ­"  Partitions that have shrunk by 5% or more:"; echo ""
echo "" ; echo "Partitions that have been reduced in size by at least 5%:";echo ""

shrunk=$(awk ' $3 - $1 > -99 && $3 -$1 < -5 { print $0 } ' filesystems.txt)
if
 [ "$shrunk" ]
then
	echo "$shrunk"
else
	echo "none"
fi
#Partitions that have grown in size
echo "" ; echo "Partitions that have grown by at least 5%:";echo ""
grown=$(awk ' $1 - $3 > -99 &&  $1 -$3 < -5  { print $0 } ' filesystems.txt)
if 
[ "$grown" ]
then 
	echo "$grown"
else
	echo "none"
fi
#Paritions that are above 10% full
echo "" ; echo  "Partitions that are over 10% full at this time:"
 tr '%'  ' '< new2.df |awk ' { if ($1 >  10) print $0 } ' | sed 's/\( *[0-9]*\)\( *\)\(.*\)/\1%    \3/'

rm -rf old2.df new2.df filesystems.txt new.df
