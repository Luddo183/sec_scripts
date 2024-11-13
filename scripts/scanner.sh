#!/bin/bash

#Get tools
sudo apt-get install chkrootkit rkhunter unhide lynis clamav

#Run tools
chkrootkit
rkhunter -c
lynis -c
freshclam
clamscan –r / --remove=yes