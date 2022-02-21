#!/bin/bash
# Exit Codes:
# Exit 1: No arguments passed in.
# Exit 2: Not a valid IP or resolvable hostname
# Exit 3: Unknown error to do with the host command, used to resolve the hostname.
# Exit 9: Something when wrong with the host command

#--------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------

target=$1
ping_sleep=5 #Number of seconds between successful pings
failed_pings=4 #Number of failed pings in a row before logging the target down
failed=0
dnsserver="8.8.8.8"  # Specify DNS server

#--------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------


function valid_ip()
{
# Checks to see if the IP entered is a valid IP address. This does not verify that it 
# is the correct IP though.
# Source: Mitch Frazier - https://www.linuxjournal.com/content/validating-ip-address-bash-script
# To do: 

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
#------------- End function valid_ip -------------
}

function get_ipaddr()
{
# Function to convert the hostname to an IP using the host command.
# Spurce: https://linuxhint.com/resolve_hostname_ip_address_bash_script/
# To do:

  local ip_address=""
  local query_type="A"
  local hostname=$1. # Need to make it a FQDN, so we add a .
  # Use host command for DNS lookup operations
  host -t ${query_type}  ${hostname} &>/dev/null ${dnsserver}
    if [ "$?" -eq "0" ]; then
      # get ip address
      ip_address="$(host -t ${query_type} ${hostname} ${dnsserver}| awk '/has.*address/{print $NF; exit}')"
      echo $ip_address
    else
      exit 3
    fi
    
    return 0
#------------- End function get_ipaddress -------------
}

#--------------------------------------------------------------------------------
# End of Functions
#--------------------------------------------------------------------------------


if [ -z "$target" ] # Check yo make sure that an ip or hostname is specified.
   then 
     echo "ERROR: Missing Target"
     exit 1

	else 
		echo "INFO: Checking to see if the target is a valid IP."
		if valid_ip $target; then # Target appears to be a valid IP
		    address=$target
	    	echo "Valid IP: " $target  
	    else # Target is not a valid IP or a hostname was used
		    echo "WARNING: Does not appear to be an IP, tryingt to resolve to an IP."
			address=$(get_ipaddr $target) 
    		if [ -n "${address}" ]; then # Hostname was converted to an IP successfully
    			echo "INFO: Valid HostName: " $target " resolves to: " $address
    		else # Target was not resolveable and/or the was not an IP address
    			echo "ERROR: Address: " $target " is not a vaiid IP or a resolveable hostname"
    			exit 2
    		fi
    	fi
fi

# If we get this far, then we have a valid IP work with.

echo 
echo "Pinging: " $address
echo 
while [ $failed -le $failed_pings ]
do
	if ping -c 1 -t 2 $address &> /dev/null
		then
		  # Ping is succesful	
		  echo $(date +"%T") "Ping Returned"
		  failed=0
		  sleep $ping_sleep #Pause for 10 seconds before trying again.
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




