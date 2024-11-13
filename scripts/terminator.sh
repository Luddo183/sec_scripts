#!/bin/bash

#Purge bad apps (you might need to press Y)
sudo apt-get purge telnet
sudo apt-get purge ftp
sudo apt-get purge vnc
sudo apt-get purge nfs
sudo apt-get purge apache
sudo apt-get purge netcat
sudo apt-get purge hydra
sudo apt-get purge john
sudo apt-get purge aircrack-ng
sudo apt-get purge fcrackzip
sudo apt-get purge lcrack
sudo apt-get purge ophcrack
sudo apt-get purge pdfcrack
sudo apt-get purge pyrit
sudo apt-get purge rarcrack
sudo apt-get purge sipcrack
sudo apt-get purge irpas
sudo apt-get purge logkeys
sudo apt-get purge zeitgeist
sudo apt-get purge wireshark
sudo apt-get purge aisleriot
sudo apt-get purge vsftpd

#Remove bad system services
systemctl disable --now apache2
systemctl disable --now nginx
systemctl disable --now netcat
systemctl disable --now vsftpd

#Delete mp3s
find / -name "*.mp3" -type f -delete