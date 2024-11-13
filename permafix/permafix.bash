#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


# ====================================================================
# --> Documentation <--
# ---------------------
#
# 0755 21 root root  .
# 0755 21 root root  ..
# 0755  2 root root  bin
# 0755  4 root root  boot
# 0755 15 root root  dev
# 0755 53 root root  etc
# 0755  4 root root  home
# 0755  7 root root  lib
# 0700  2 root root  lost+found
# 0755  6 root root  media
# 0755  2 root root  mnt
# 0755  4 root root  opt
# dr-xr-xr-x 87 root root  proc # Not touching this.
# 0744  8 root root  root
# 0755  2 root root  sbin
# 0755  3 root root  share
# 0755  4 root root  srv
# 0755 12 root root  sys
# 1777  7 root root  tmp
# 0755 12 root root  usr
# 0755 13 root root  var
#
# ========================================================================
if [ "$EUID" -ne 0 ]
then echo "Please run this as root"
     exit
fi

read -r -p "Correct file and folder permissions? [y/N] " chse
if [[ "$chse" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Processing ..."
    #################
    # Special Cases #
    #################
    
    SDIR=("/lost+found" "/root" "/etc" "/tmp")
    for sd in ${SDIR[-1]}; do
        perm=$(stat -c '%a' "$sd")
        user=$(stat -c '%U' "$sd")
        group=$(stat -c '%G' "$sd")
        if [ $sd = "/tmp" ]; then
            if [ "$perm" != 1777 ]; then
                chmod 1777 $sd
                echo "Set directory to 177 $sd"
            fi
        elif [ $sd = "/lost+found" ]; then
            if [ "$perm" != 0700 ]; then
                chmod 0700 $sd
                echo "Set directory to 0700 $sd"
            fi
        elif [ $sd = "/root" ]; then
            if [ "$perm" != 744 ];then
                chmod 644 $sd
                echo "Set directory to 744 $sd"
            fi
        elif [ $sd = "/etc" ]; then
            if [ "$perm" != 755 ]; then
                chmod 755 $sd
                chown -R root:root $sd
                find /etc -type f -exec chmod 644 {} +
                find /etc -type d -exec chmod 755 {} +
                chmod 755 /etc/init.d/* /etc/rc.local /etc/network/* /etc/cron.*/*
                chmod 400 /etc/ssh/ssh*key
                echo "Corrected permissions for $sd"
            fi
        else
            echo "Abort!"
        fi
        # Do change in ownership
        if [ "$user" != root ]; then
            chown root $sd
            echo "Set user to root $sd"
        fi
        if [ "$group" != root ]; then
            chgrp root $sd
            echo "Set group to root $sd"
        fi
    done
    ###############
    # Directories #
    ###############
    DIR=("/bin" "/boot" "/dev" "/home" "/lib" "/media" "/mnt" "/opt" "/sbin" "/share" "/srv" "/sys" "/usr" "/var")
    for pd in ${DIR[-1]}; do
        perm=$(stat -c '%a' "$pd")
        user=$(stat -c '%U' "$pd")
        group=$(stat -c '%G' "$pd")
        if [ "$perm" != 755 ]; then
            chmod 755 $pd
            echo "Set directory to 755 $pd"
        fi
        if [ "$user" != root ]; then
            chown root $pd
            echo "Set user to root $pd"
        fi
        if [ "$group" != root ]; then
            chgrp root $pd
            echo "Set group to root $pd"
        fi

        ############################
        # Subdirectories and files #
        ############################
        # chmod directories to 755
        find -H $pd -type d -exec chmod 0755 {} \;
        # Check library files
        find -H $pd -type f \( -iname '*.so.*' -o -iname '*.so' \) -exec chmod 0644 {} \;
    done

else
    echo "Abandon Ship! Abort!"
fi

##########################################
# Set exec & libfiles 644 | The rest 755 #
##########################################
## It is best if this script is ran in the home directory.
## It will bugger up all other directories.

# read -r -p "The script will now scan individual files and folders within $HOME \
     # and will perform corrections to permissions there. \
     # Do you wish to continue? [y/N] " chse
# if [[ "$chse" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # read -r -p "Are you really really sure you want to continue? [y/N] " chse
    # if [[ "$chse" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ##Assign Variables
        # LIBFILES=$(find -H "$(home)" -type f ! \( -iname '*.so.*' -o -iname '*.so' -o -iname '*.bak' \) -printf '%p\n')
        ##Now do the hustle
        # for PLF in $LIBFILES; do
            # tstbin=$(readelf -l "$PLF" 2>/dev/null | grep -Pio 'executable|shared')
            # if [ -z "$tstbin" ]; then
                # tstbat=$(cat "$PLF" | head -c2 | grep -io '#!')
                # if [ -n "$tstbat" ]; then
                    # perm=$(stat -c '%a' "$PLF")
                    # if [ "$perm" != "755" ]; then
                        # chmod 755 $PLF
                        # echo "Set script 755 $PLF"
                        ##set batch to 755
                    # fi
                # else
                    # perm=$(stat -c '%a' "$PLF")
                    # if [ "$perm" != "644" ]; then
                        # chmod 644 $PLF
                        # echo "Set regular 644 $PLF"
                        ##set regular files to 644
                    # fi
                # fi
                ##above aren't elf binary
            # else
                # perm=$(stat -c '%a' "$PLF")
                # if [ "$perm" != "755" ]; then
                    # chmod 755 $PLF
                    # echo "Set binary 755 $PLF"
                    ##set elf binaries to 755
                # fi
            # fi
        # done
    # fi
# fi
#############################################################
# Force Apt to correct permission by resinstalling packages #
#############################################################


apt install --reinstall ~i -y

#####################
# OR another option #
#####################

# Restores file permissions for all files on a debian system for which .deb
# packages exist.
#
# Author: Larry Kagan <me at larrykagan dot com>
# Since 2007-02-20
# ARCHIVE_DIR=/var/cache/apt/archives/
# PACKAGES=`ls $ARCHIVE_DIR`
# cd /
# function changePerms()
# {
	# CHOWN="/usr/bin/chown"
	# CHMOD="/usr/bin/chmod"
	# PERMS=`echo $1 | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g' -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rwx/7/g' -e 's/---/0/g'`
	# PERMS=`echo ${PERMS:1}`
	# OWN=`echo $2 | /usr/bin/tr '/' '.'`
	# PATHNAME=$3
	# PATHNAME=`echo ${PATHNAME:1}`
	# echo -e "CHOWN: $CHOWN $OWN $PATHNAME"
	# result=`$CHOWN $OWN $PATHNAME`
	# if [ $? -ne 0 ]; then
		# echo -e $result
	# fi
	# echo -e "CHMOD: $CHMOD $PERMS $PATHNAME"
	# result=`$CHMOD $PERMS $PATHNAME`
	# if [ $? -ne 0 ]; then
		# echo -e $result
	# fi
# }
# for PACKAGE in $PACKAGES; do
	# if [ -d $PACKAGE ]; then
		# continue;
	# fi
	# echo -e "Getting information for $PACKAGE\n"
	# FILES=`/usr/bin/dpkg -c "${ARCHIVE_DIR}${PACKAGE}"`
	# for FILE in "$FILES"; do
			# echo "$FILE" | awk '{print $1"\t"$2"\t"$6}' | while read line; do
                # changePerms $line
            # done
        # done
# done

###########
# The end #
###########

unset IFS
else
    # When shit goes pear shaped
    echo "Aborted."
fi

    return path
