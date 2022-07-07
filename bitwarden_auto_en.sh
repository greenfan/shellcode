
#!/bin/bash




if [ ! -f /tmp/bitwarden_userids_current ]; then
    echo "user_ids not found!"
fi



echo "Moving current ids to old"
mv /tmp/bitwarden_userids_current  /tmp/bitwarden_userids_old



bw login --apikey 1> /dev/null

eval $(  bw unlock --passwordenv BW_PASSWORD | grep export | cut -c2- ) 1> /dev/null


list_output=$( bw list org-members --organizationid xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | jq  '.' )
memberlist=$( echo "$list_output" | grep id |  sed 's/\ *\"id\":\ \"\(.*\)\",/\1/g' )


echo "$memberlist" > /tmp/bitwarden_userids_current




new_memberlist=$( diff /tmp/bitwarden_userids_old /tmp/bitwarden_userids_current | cut -c3- | tail -n +2 )
echo $new_memberlist
echo -en "Now auto-enrolling... \n \n \n"



for i in $new_memberlist
do
        echo "$i"
        echo "$list_output" | grep -i -B 1 "$i"
done



for i in $new_memberlist
do
        eval $(  bw unlock --passwordenv BW_PASSWORD | grep export | cut -c2- ) 1> /dev/null
        bw confirm org-member "$i" --organizationid xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
done
