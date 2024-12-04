#!/bin/bash

#Purge bad apps
badPackages=(aisleriot aircrack-ng sipcrack rarcrack logkeys pyrit pdfcrack ophcrack fcrackzip lcrack cups john "cups-*" "*-cups" ftp vsftp vsftpd gnome-mahjongg gnome-mines gnome-sudoku remmina "remmina*" samba sambashare "samba-*" tcpdump telnet tcpd netcat nc netcat "netcat*" smbd snmpd avahi "avahi-*" slapd ldap "ldap-*" nfs nfs-common nfs-kernel-server rsync talk irc nfs-server "nfs-*" irpas wireshark vsftpdrpcbind bind9 apache dovecot smbd squid snmpd inetutiles-inetd vnc hydra zeitgeist)
for package in $badPackages
do
    apt purge $package -y
done
apt purge --autoremove

#Remove bad system services
badServices=(nginx nc netcat vsftpd)
for service in $badServices
do
    systemctl stop --now $service
    systemctl disable --now $service
done

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
#find / -name '*.gif' -type f -delete
#find / -name '*.png' -type f -delete
#find / -name '*.jpg' -type f -delete
#find / -name '*.jpeg' -type f -delete