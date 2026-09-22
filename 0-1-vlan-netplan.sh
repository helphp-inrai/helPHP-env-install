#!/bin/bash
### installing packets and sofware for hosts...
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi

read -p "Enter the network interface : " interface
read -p "Enter the fixed ip " ip

### do the job

echo "    $interface:
      addresses:
        - $ip/24
      dhcp4: false
      accept-ra: false
      routes:
      - to: \"default\"
        via: \"$ip\"
      link-local: []" >> /etc/netplan/50-cloud-init.yaml

netplan apply
echo "netplan configuration done"