import os
import subprocess

HOME_DIR = "/home"

try:
    with open("files/users.in", "r") as f:
        content = f.readlines()
    users = os.listdir(HOME_DIR)
    content_cleaned =  []
    users_cleaned = []
    for c in content:
        c2 = c.strip()
        content_cleaned.append(c2)
    for u in users:
        u2 = u.strip()
        users_cleaned.append(u2)
    for c in content_cleaned:
        if c not in users_cleaned:
            subprocess.run(["sudo", "useradd", c]) 
    for u in users_cleaned:
        if u not in content_cleaned:
            subprocess.run(["sudo", "deluser", "--remove-home", "--remove-all-files", u])
except:
    print("Error. Did you add all the users to users.in?")

subprocess.run(["sudo", "getent", "passwd"])

try:
    a_repeats = input("How many users need to be added to groups?(sudo is the admin group)")
    for i in range(0, int(a_repeats)):
        a_user = input("User name").strip()
        a_group = input("Group name").strip()
        subprocess.run(["sudo", "gpasswd", "-a", a_user, a_group])

    r_repeats = input("How many users need to be removed from groups?(sudo is the admin group)")
    for i in range(0, int(r_repeats)):
        r_user = input("User name").strip()
        r_group = input("Group name").strip()
        subprocess.run(["sudo", "gpasswd", "-d", r_user, r_group])
except:
    print("Error")