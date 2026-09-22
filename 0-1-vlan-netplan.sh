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
        - 192.168.2.$ip/24
      dhcp4: false
      accept-ra: false
      routes:
      - to: \"default\"
        via: \"192.168.2.1\"
      link-local: []" >> /etc/netplan/50-cloud-init.yaml

echo "netplan configuration done"