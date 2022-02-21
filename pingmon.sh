#!/bin/bash
failed=0

function valid_ip()
{
#Checks to see if the IP entered is a valid IP address. This does not verify that it is the correct IP though.
#Source: Mitch Frazier - https://www.linuxjournal.com/content/validating-ip-address-bash-script
#To do: Check for hostname and resolve it to IP.

    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


if [ -z "$1" ]
   then 
     echo "Missing Target"
     exit 1

# Todo: Check validity of target
	else
		if valid_ip $1 
		then 
	    	echo "Valid IP"
	    else
			echo "Invalid IP. Exiting"
			exit 1
    	fi
fi

echo $1

while [ $failed -le 5 ]
do
	if ping -c 1 $1 &> /dev/null
		then
		  # Ping is succesful
		  echo "Ping Returned"
		  failed=0
		  sleep 10 #Pause for 10 seconds before trying again.
	else
		  # Ping Failed
		  # echo $failed
		  failed=$(( $failed + 1 ))
   	fi

	read -t 0.25 -N 1 input
    if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
		# The following line is for the prompt to appear on a new line.
        echo
        break 
    fi

done
failed=0

echo "Ping failed"
say "Ping Failed"




