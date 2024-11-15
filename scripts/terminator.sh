#!/bin/bash

#Purge bad apps
sudo apt-get purge telnet -y
sudo apt-get purge ftp -y 
sudo apt-get purge vnc -y
sudo apt-get purge nfs -y
sudo apt-get purge apache -y
sudo apt-get purge netcat -y
sudo apt-get purge hydra -y
sudo apt-get purge john -y 
sudo apt-get purge aircrack-ng -y
sudo apt-get purge fcrackzip -y
sudo apt-get purge lcrack -y
sudo apt-get purge ophcrack -y
sudo apt-get purge pdfcrack -y
sudo apt-get purge pyrit -y
sudo apt-get purge rarcrack -y
sudo apt-get purge sipcrack -y
sudo apt-get purge irpas -y
sudo apt-get purge logkeys -y
sudo apt-get purge zeitgeist -y
sudo apt-get purge wireshark -y
sudo apt-get purge aisleriot -y
sudo apt-get purge vsftpd -y

echo "Deleting unauthorized default packages"
# fakeroot? sane? sane-utils? ppp?
badDefaults=(aisleriot cups "cups-*" "*-cups" ftp vsftp vsftpd gnome-mahjongg gnome-mines gnome-sudoku remmina "remmina*" samba sambashare "samba-*" tcpdump telnet tcpd netcat nc netcat "netcat*" smbd snmpd avahi "avahi-*" slapd ldap "ldap-*" nfs nfs-common nfs-kernel-server rsync talk irc nfs-server "nfs-*" rpcbind bind9 apache2 dovecot smbd squid snmpd inetutiles-inetd)
for package in $badDefults
do
    apt purge $package -y
done
apt purge --autoremove
apt list --installed | cut -d/ -f1 > installed
diff defaults installed | grep ">"
echo "List of nondefault packages"

#Remove bad system services
systemctl disable --now apache2
systemctl disable --now nginx
systemctl disable --now netcat
systemctl disable --now vsftpd

#Delete non-work files
find / -name '*.mp3' -type f -delete
find / -name '*.mov' -type f -delete
find / -name '*.mp4' -type f -delete
find / -name '*.avi' -type f -delete
find / -name '*.mpg' -type f -delete
find / -name '*.mpeg' -type f -delete
find / -name '*.flac' -type f -delete
find / -name '*.m4a' -type f -delete
find / -name '*.flv' -type f -delete
find / -name '*.ogg' -type f -delete
find /home -name '*.gif' -type f -delete
find /home -name '*.png' -type f -delete
find /home -name '*.jpg' -type f -delete
find /home -name '*.jpeg' -type f -delete

ls -alR /home/*/*
echo "List of all files in the home directory"