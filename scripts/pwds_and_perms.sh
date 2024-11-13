#!/bin/bash

#Run unhide
sudo apt-get unhide
unhide brute proc procall procfs quick reverse sys

#File permission stuff
#apt-get install --reinstall ~ #Will re-install all packages
#chmod 640 /etc/shadow #From TR2 CPXVII

#Remove root login from ssh
sed 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

#Make sure we have pam_pwquality
sudo apt-get install libpam-pwquality

#Password stuff
sed 's/auth [success=2 default=ignore] pam_unix.so nullok/auth [success=2 default=ignore] pam_unix.so/' /etc/pam.d/common-auth 
sed 's/PASS_MIN_DAYS 0/PASS_MIN_DAYS 2/' /etc/login.defs
sed 's/password requisite pam_pwquality.so retry=3/password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1  ocredit=-1/' /etc/pam.d/common-password
echo "enforce_for_root" >> /etc/pam.d/common-password

cp files/faillock /usr/share/pam-configs/faillock
cp files/faillock_notify /usr/share/pam-configs/faillock_notify

sudo pam-auth-update