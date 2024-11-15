Sec_scripts - Collection of Ubuntu security scripts

All scripts should be run with sudo permissions

Runner.sh - Single-file to run all the subscripts. You don't need to use it, just simplifies using these scripts
Scanner.sh - Scans for viruses and other not fun stuff
Terminator.sh - Deletes common 'hacking' packages and 'dangerous' files
Net_hardener.sh - Network security stuff
Pwds_and_perms.sh - Passwords and permissions(files and SSH)
Users.py - Adds and removes users, updates groups

BEFORE RUNNING THE SCRIPTS:
Go to the files directory and do the following:
    - add your users to users.in
    - add your admins to admins.in

To run the scripts, use the following commands:
sudo chmod a+x runner.sh
sudo ./runner.sh

If running scripts individually, just replace runner.sh in the above instructions with the script name

permafix was taken from https://gist.github.com/anoduck/44b152f3f8edfb64b63fcd872ea11672
Only run when you have done everything you can to get points, but you're coming up short
Use the following commands from this folder to run:
sudo chmod a+x permafix/permafix.bash
sudo ./permafix.bash