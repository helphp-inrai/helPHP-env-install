#!/bin/bash
### installing packets and sofware for hosts...
owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi

read -p "Enter the network interface : " interface
read -p "Enter the fixed ip " ip

### do the job
echo "auto $interface
iface $interface inet static
address $ip
netmask 255.255.0.0" >> /etc/network/interfaces.d/50-cloud-init

systemctl restart networking

echo "Vrack configuration done"