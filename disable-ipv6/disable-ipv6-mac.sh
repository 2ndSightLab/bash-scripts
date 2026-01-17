#!/bin/sh
IFS=$'\n' # Set Internal Field Separator to handle spaces in service names
net=`networksetup -listallnetworkservices | grep -v asterisk` # Get list of services
for i in $net; do
    echo "Disabling IPv6 on: $i"
    sudo networksetup -setv6off "$i" # Disable IPv6 for each service
done
echo "IPv6 disabled on all services."
exit 0
