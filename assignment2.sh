#!/bin/bash

#This script is meant to make modifications to an ubuntu server and report its actions to the user

#This section will change the ip address in the netplan file and etc/hosts

sed -i 's/192.168.16.200/192.168.16.21/' 10-lxc.yaml 
sed -i 's/192.168.16.200/192.168.16.21/' /etc/hosts

#this section installs apache2 and squid

sudo apt update --quiet -y
sudo apt install apache2 -y
sudo apt install squid -y

#This section enables and configures the firewall

sudo ufw enable

sudo ufw allow in on eth1 to any port 22
sudo ufw allow 80
sudo ufw allow 3128

#This section will create the specified user accounts

#First, making the dennis account

sudo adduser dennis sudo

sudo -u dennis ssh-keygen -t rsa -b 2048 -f "/home/dennis/.ssh/id_rsa" -N ""
sudo -u dennis cp /home/dennis/.ssh/id_rsa.pub /home/dennis/.ssh/authorized_keys
sudo -u dennis ssh-keygen -t ed25519 -b 2048 -f "/home/dennis/.ssh/id_ed25519" -N ""
sudo -u dennis cp /home/dennis/.ssh/id_ed25519.pub /home/dennis/.ssh/authorized_keys

echo "AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI" >> /home/dennis/.ssh/authorized_keys

#Making an array for the rest of the usernames

listOfUsers=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

#Making the rest of the users in a for loop

for username in "${listOfUsers[@]}"; do
    home_dir="/home/$username"
    sudo useradd -m -d "$home_dir" -s /bin/bash "$username"
    cd "$home_dir"
    sudo -u "$username" ssh-keygen -t rsa -b 2048 -f "$home_dir/.ssh/id_rsa" -N ""
    sudo -u "$username" cp "$home_dir"/.ssh/id_rsa.pub "$home_dir"/.ssh/authorized_keys
    sudo -u "$username" ssh-keygen -t ed25519 -b 2048 -f "$home_dir/.ssh/id_ed25519" -N ""
    sudo -u "$username" cp "$home_dir"/.ssh/id_ed25519.pub "$home_dir"/.ssh/authorized_keys
    echo "'$username' was added."
done