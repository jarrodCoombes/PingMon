#!/bin/bash
# Exit 1: No arguments passed in.
#Exit 2: Not a valid IP or resolvable hostname
#Exit 3: Unknown error to do with the host command, used to resolve the hostname.



failed=0

dnsserver="8.8.8.8"  # Specify DNS server


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
    echo "Does not appear to be an IP, tryingt to resolve to an IP."
    return $stat
}


function get_ipaddr 
{
# function to get IP address
  ip_address=""
  query_type="A"
  hostname="${1}." #added the . to make it a FQDN
  # use host command for DNS lookup operations
  host -t ${query_type}  ${hostname} &>/dev/null ${dnsserver}
    if [ "$?" -eq "0" ]; then
      # get ip address
      ip_address="$(host -t ${query_type} ${hostname} ${dnsserver}| awk '/has.*address/{print $NF; exit}')"
    else
      echo "An unknown error has occured"
      exit 3
    fi
# display ip
 echo $ip_address
}



if [ -z "$1" ]
   then 
     echo "Missing Target"
     exit 1

	else
		if valid_ip $1 
		then 
	    	echo "Valid IP: " $1
	    else
			address="$(get_ipaddr ${1})"
			echo $1 " = " $address
			if [ "$?" -eq "0" ]; then
    			if [ -n "${address}" ]; then
    				echo "The adress of the Hostname ${1} is: $address"
    			else
    				echo "Address: " $1 " is not a vaiid IP or a resolveable hostname"
    				exit 2
    			fi
  			else
    			echo "An error occurred"
  			fi
    	fi
fi

while [ $failed -le 4 ]
do
	if ping -c 1 -t 1 $1 &> /dev/null
		then
		  # Ping is succesful
		  echo "Ping Returned"
		  failed=0
		  sleep 10 #Pause for 10 seconds before trying again.
	else
		  # Ping Failed
		  # echo $failed
		  failed=$(( $failed + 1 ))
		  echo "Failed: " $failed
   	fi


done
failed=0

echo "Ping failed"
say "Ping Failed"




