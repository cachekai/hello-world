#!/bin/bash
#Filename: active_user.sh
#Description: Reporting tool to find out active users

log=/var/log/wtmp

if [[ -n $1 ]]; then 
	log=$1
fi 

printf "%-4s %-10s %-10s %-6s %-8s\n" "Rank" "User" "Start" "Logins" "Usage hours"

#get rig of first 4 logins which were not remote logins 
last -f $log | head -n -4 > /tmp/ulog.$$

cat /tmp/ulog.$$ | cut -d' ' -f1 | sort | uniq > /tmp/users.$$

(
while read user; do
	grep ^$user /tmp/ulog.$$ > /tmp/user.$$
	minutes=0

	while read t; do
		s=$(echo $t | awk -F: '{ print ($1 * 60 ) + $2 }')
		let minutes+=s
	done< <(cat /tmp/user.$$ | awk '{ print $NF}' | tr -d ')(' )
   
    #get the date of first login
	firstlog=$(tail -n 1 /tmp/user.$$ | awk '{ print $5,$6}')
    #get the times of login
	nlogins=$(cat /tmp/user.$$ | wc -l)
	#calculate the final hours of login
	hours=$(echo "$minutes / 60.0" | bc)
	#the $firstlog should be surrounded by quotation marks cuz there is a blank in date
	printf "%-10s %-10s %-6s %-8s\n" $user "$firstlog" $nlogins $hours
done< /tmp/users.$$
) | sort -nrk 4 | awk '{ printf("%-4s %s\n", NR, $0) }'
rm /tmp/users.$$ /tmp/user.$$ /tmp/ulog.$$
