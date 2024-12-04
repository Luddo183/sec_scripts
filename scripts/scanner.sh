#!/bin/bash

#Get tools
sudo apt-get install chkrootkit rkhunter unhide lynis clamav unhide

#Run tools
unhide brute proc procall procfs quick reverse sys
chkrootkit
rkhunter -c
lynis -c
freshclam
clamscan –r / --remove=yes