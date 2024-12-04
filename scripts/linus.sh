#Start by securing crucial files
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


#Secure cron
crontab -r
cd /etc/
/bin/rm -f cron.deny at.deny
echo root >cron.allow
echo root >at.allow
/bin/chown root:root cron.allow at.allow
/bin/chmod 644 cron.allow at.allow
cd ~


#Make sure we have pam_pwquality
sudo apt-get install libpam-pwquality

#Password time
sed -i '' '/pam_unix.so/s/$/ remember=5 minlen=12/' /etc/pam.d/common-password
sed -i '' 's/retry=3/retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1  ocredit=-1/' /etc/pam.d/common-password
echo "enforce_for_root" >> /etc/pam.d/common-password

sed -i '' 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' etc/login.defs
sed -i '' 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' etc/login.defs
sed -i '' 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' etc/login.defs

echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth #Faillock is better, but this is a backup
cp files/faillock /usr/share/pam-configs/faillock
cp files/faillock_notify /usr/share/pam-configs/faillock_notify

pam-auth-update


#Get UFW
apt install ufw -y
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
ufw logging on

read -p "Is SSH required(Y/N)? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sed 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    ufw allow OpenSSH
    systemctl restart sshd
else
    systemctl stop --now sshd
    systemctl disable --now shd
    apt purge openssh -y
    apt purge "openssh-*" -y
fi

read -p "Is a guest user required(Y/N)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Leaving guest alone"
else
    if [ -f "/etc/lightdm/lightdm.conf" ]; then
        echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
    fi
fi

read -p "Is Apache required(Y/N)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
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
else
    systemctl stop --now apache2
    systemctl disable --now apache2
    apt purge apache2 -y
fi


#Rules
sysctl -w kernel.core_uses_pid=1
sysctl -w kernel.ctrl-alt-del=0
sysctl -w kernel.sysrq=0
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.all.bootp_relay=0
sysctl -w net.ipv4.conf.all.forwarding=0
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.all.mc_forwarding=0
sysctl -w net.ipv4.conf.all.proxy_arp=0
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.tcp_timestamps=0
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.default.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_source_route=0


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

sudo apt update && sudo apt upgrade