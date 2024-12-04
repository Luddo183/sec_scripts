#!/bin/bash

#File permission stuff
chmod 640 /etc/shadow
chown root:root /etc/passwd
chmod 644 /etc/passwd
chown root:root /etc/shadow
chmod o-rwx,g-wx /etc/shadow
chown root:root /etc/group
chmod 644 /etc/group
chown root:shadow /etc/gshadow
chmod o-rwx,g-rw /etc/gshadow
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-
chown root:root /etc/shadow-
chown root:shadow /etc/shadow-
chmod o-rwx,g-rw /etc/shadow-
chown root:root /etc/group-
chmod u-x,go-wx /etc/group-
chown root:root /etc/gshadow-
chown root:shadow /etc/gshadow-
chmod o-rwx,g-rw /etc/gshadow-

#Disable guest account
if [ -f "/etc/lightdm/lightdm.conf" ]; then
    echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
fi

#Secure cron
crontab -r
cd /etc/
/bin/rm -f cron.deny at.deny
echo root >cron.allow
echo root >at.allow
/bin/chown root:root cron.allow at.allow
/bin/chmod 644 cron.allow at.allow
cd ~

#Secure apache2
a2enmod userdir
chown -R root:root /etc/apache2
chown -R root:root /etc/apache
if [ -e /etc/apache2/apache2.conf ]; then
    echo "<Directory />" >> /etc/apache2/apache2.conf
    echo "        AllowOverride None" >> /etc/apache2/apache2.conf
    echo "        Order Deny,Allow" >> /etc/apache2/apache2.conf
    echo "        Deny from all" >> /etc/apache2/apache2.conf
    echo "</Directory>" >> /etc/apache2/apache2.conf
    echo "UserDir disabled root" >> /etc/apache2/apache2.conf
fi
systemctl restart apache2.service

#Remove root login from ssh
sed 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

#Make sure we have pam_pwquality
sudo apt-get install libpam-pwquality

#Password stuff
sed -i '' '/pam_unix.so/s/$/ remember=5 minlen=12/' /etc/pam.d/common-password
sed -i '' 's/retry=3/retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1  ocredit=-1/' /etc/pam.d/common-password
echo "enforce_for_root" >> /etc/pam.d/common-password

sed -i '' 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i '' 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' /etc/login.defs
sed -i '' 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth #Faillock is better, but this is a backup
cp files/faillock /usr/share/pam-configs/faillock
cp files/faillock_notify /usr/share/pam-configs/faillock_notify

pam-auth-update

#Auto updates
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades