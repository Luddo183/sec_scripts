#!/bin/bash

chmod a+x scanner.sh
chmod a+x pwds_and_perms.sh
chmod a+x net_hardener.sh
chmod a+x terminator.sh

./pwds_and_perms.sh
sudo python3 users.py
./net_hardener.sh
./terminator.sh
./scanner.sh

sudo apt-get update && sudo apt-get upgrade