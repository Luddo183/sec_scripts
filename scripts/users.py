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

r_admins = subprocess.run(["getent", "group", "sudo"], check=True, capture_output=True).stdout
r_admins = r_admins.decode("utf-8")
r_admins = r_admins[r_admins.rfind(":")+1:].split(",")
with open("files/admins.in", "r") as f:
        c_admins = f.readlines()
r_adm_cleaned =  []
c_adm_cleaned = []
for c in c_admins:
    c2 = c.strip()
    c_adm_cleaned.append(c2)
for r in r_admins:
    r2 = r.strip()
    r_adm_cleaned.append(r2)
for c in c_adm_cleaned:
    if c not in r_adm_cleaned:
        subprocess.run(["sudo", "gpasswd", "-a", c, "sudo"]) 
for r in r_adm_cleaned:
    if r not in c_adm_cleaned:        
        subprocess.run(["sudo", "gpasswd", "-d", r, "sudo"])

try:
    a_repeats = input("How many users need to be added to groups?")
    for i in range(0, int(a_repeats)):
        a_user = input("User name").strip()
        a_group = input("Group name").strip()
        subprocess.run(["sudo", "gpasswd", "-a", a_user, a_group])

    r_repeats = input("How many users need to be removed from groups?")
    for i in range(0, int(r_repeats)):
        r_user = input("User name").strip()
        r_group = input("Group name").strip()
        subprocess.run(["sudo", "gpasswd", "-d", r_user, r_group])
except:
    print("Error")